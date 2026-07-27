# API Security — Reference

## Rate Limiting

### Endpoints That MUST Have Rate Limiting
```
CRITICAL (no rate limit = critical vulnerability):
- POST /auth/login
- POST /auth/register
- POST /auth/password-reset
- POST /auth/verify-otp / /auth/verify-2fa
- POST /auth/refresh-token

HIGH (missing rate limit = high vulnerability):
- Any endpoint accepting file uploads
- Any endpoint sending emails/SMS
- Any search endpoint (prevent enumeration)
- Any expensive computation endpoint

MEDIUM:
- All authenticated API endpoints (prevent abuse)
```

### Detection
```bash
# Find auth endpoints
grep -rn "login\|register\|password.reset\|verify.otp\|refresh.token" \
  --include="*.py" --include="*.ts" . | grep -v test | grep -v node_modules

# Check if rate limiting is applied near these endpoints
grep -rn "RateLimiter\|rate_limit\|slowapi\|throttle\|limiter\." \
  --include="*.py" --include="*.ts" . | grep -v test | grep -v node_modules

# If login route found but no rate limiter near it → flag
```

### Safe Implementation (FastAPI/SlowAPI)
```python
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

@router.post("/auth/login")
@limiter.limit("5/minute")  # 5 attempts per minute per IP
async def login(request: Request, data: LoginSchema):
    ...
```

---

## Mass Assignment

### What It Is
User sends extra fields in request body that get applied to the object without filtering.

```python
# VULNERABLE
@router.put("/users/me")
async def update_profile(data: dict, user = Depends(get_current_user)):
    await User.filter(id=user.id).update(**data)
# Attack: {"name": "Alice", "role": "admin", "is_active": true, "credits": 9999}

# SAFE — use Pydantic model with explicit fields
class ProfileUpdateSchema(BaseModel):
    name: Optional[str]
    bio: Optional[str]
    avatar_url: Optional[str]
    # role, is_admin, credits are NOT here

@router.put("/users/me")
async def update_profile(data: ProfileUpdateSchema, user = Depends(get_current_user)):
    await User.filter(id=user.id).update(**data.dict(exclude_none=True))
```

### Detection
```bash
# Find dict/json passed directly to ORM update
grep -rn "\.update(\*\*\|\.update(data\|\.update(body\|\.update(payload" \
  --include="*.py" . | grep -v test

grep -rn "findByIdAndUpdate.*req\.body\b" \
  --include="*.ts" --include="*.js" . | grep -v test | grep -v node_modules
```

---

## SSRF (Server-Side Request Forgery)

### What It Is
Server makes HTTP request to URL controlled by attacker → attacker reaches internal services.

```python
# VULNERABLE
@router.post("/fetch-url")
async def fetch_url(url: str = Body(...)):
    response = requests.get(url)  # attacker controls target!
    return response.text

# Attack payloads:
# http://169.254.169.254/latest/meta-data/  → AWS instance metadata
# http://localhost:6379  → Redis (if accessible)
# http://internal-service.company.local/admin  → internal services
# file:///etc/passwd  → local file read (some libraries)
```

### SSRF Mitigations to Verify
```python
from urllib.parse import urlparse
import ipaddress

ALLOWED_SCHEMES = {"http", "https"}
BLOCKED_HOSTS = {"localhost", "127.0.0.1", "0.0.0.0", "169.254.169.254"}

def validate_url(url: str) -> bool:
    parsed = urlparse(url)
    if parsed.scheme not in ALLOWED_SCHEMES:
        return False
    # Check for private IP ranges
    try:
        ip = ipaddress.ip_address(parsed.hostname)
        if ip.is_private or ip.is_loopback or ip.is_link_local:
            return False
    except ValueError:
        pass  # hostname, not IP — additional DNS resolution check needed
    if parsed.hostname in BLOCKED_HOSTS:
        return False
    return True
```

### Detection
```bash
grep -rn "requests\.get(\|requests\.post(\|httpx\.get(\|fetch(\|axios\.get(" \
  --include="*.py" --include="*.ts" . | grep -v node_modules | grep -v test \
  | grep -v "https://\|settings\.\|config\.\|BASE_URL\|API_URL"
# Any remaining results where URL has variable input → SSRF candidate
```

---

## Object/User Enumeration

### ID Enumeration
```
Sequential integer IDs: /api/users/1, /api/users/2, /api/users/3
→ Attacker iterates to find all users/resources

Mitigations:
1. Use UUIDs for user-facing identifiers
2. Scope all queries to authenticated user's context
3. Return 404 (not 403) for resources that don't belong to user
   (403 reveals existence, 404 doesn't)
```

### Username/Email Enumeration
```
VULNERABLE responses:
- "User not found" vs "Invalid password" → reveals valid emails
- /forgot-password returns "Email sent" only for valid users
- /register returns "Email already taken" vs "Registration successful"

SAFE responses:
- Login: always "Invalid credentials" (never specify which part is wrong)
- Forgot password: "If this email is registered, you'll receive a link"
- Register: allow (don't reveal email exists, or use verification flow)
```

### Detection
```bash
# Find login/register/reset endpoints and check their error responses
grep -rn "not found\|does not exist\|invalid.*email\|user.*not.*exist" \
  --include="*.py" --include="*.ts" . | grep -v test | grep -v node_modules
```

---

## API Versioning & Deprecated Endpoints

### Attack: Old API Version Without Security Patches
```
/api/v1/users  → might lack auth checks added in v2
/api/v2/users  → properly secured

Check:
- Are all API versions behind the same auth middleware?
- Are deprecated versions decommissioned?
```

### Detection
```bash
grep -rn "v1\|v2\|v3\|/api/" --include="*.py" --include="*.ts" . | grep -v test \
  | grep "router\|route\|endpoint"
```

---

## HTTP Method Override

```
Some apps support:
- X-HTTP-Method-Override header
- _method=DELETE in form body

Attack: regular user sends GET request with X-HTTP-Method-Override: DELETE
→ might bypass method-based access controls

Check if app processes these headers and if same auth rules apply
```

---

## Webhook Security

```python
# VULNERABLE — anyone can trigger your webhook
@router.post("/webhooks/stripe")
async def stripe_webhook(data: dict):
    process_payment(data)  # no signature verification!

# SAFE — verify HMAC signature
import hmac, hashlib

@router.post("/webhooks/stripe")
async def stripe_webhook(request: Request):
    payload = await request.body()
    sig_header = request.headers.get("stripe-signature")
    
    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, settings.STRIPE_WEBHOOK_SECRET
        )
    except ValueError:
        raise HTTPException(400, "Invalid payload")
    except stripe.error.SignatureVerificationError:
        raise HTTPException(400, "Invalid signature")
    
    process_event(event)
```

### Detection
```bash
grep -rn "webhook\|Webhook" --include="*.py" --include="*.ts" . | grep -v test | grep -v node_modules
# → Check nearby code for signature verification
```

---

## CWE References
- CWE-307: Improper Restriction of Excessive Authentication Attempts
- CWE-915: Mass Assignment
- CWE-918: SSRF
- CWE-203: Observable Discrepancy (enumeration)
- CWE-345: Insufficient Verification of Data Authenticity (webhooks)
