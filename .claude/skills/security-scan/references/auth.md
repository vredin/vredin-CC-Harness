# Authentication & Authorization — Reference

## Authentication Bypass

### Brute Force
```bash
# Test: no rate limiting on login
for i in {1..100}; do
  curl -s -X POST /api/auth/login \
    -d '{"email":"victim@test.com","password":"guess'$i'"}' \
    -H "Content-Type: application/json" | grep -v "Invalid"
done
# If all 100 succeed without 429 → VULNERABLE
```

**Check:** Rate limit on login, register, password-reset, OTP verification.
**Safe threshold:** 5-10 attempts per IP per minute, then lockout/captcha.

### 2FA Bypass
```
Attack vectors:
1. Skip MFA step: complete step 1 (password), then directly call authenticated endpoint
   → Check: does session/token get issued BEFORE MFA verification?

2. Reuse OTP: submit valid OTP twice
   → Check: is OTP invalidated after first use?

3. OTP bruteforce: 6-digit = 1,000,000 combinations
   → Check: is OTP attempt count limited?

4. Response manipulation: change {"mfa_required": true} → false in response
   → Check: is MFA state validated server-side, not trusted from client?

5. Old OTP: submit OTP from 10 minutes ago
   → Check: is OTP expiry enforced (standard: 30-60 seconds for TOTP)?
```

### Password Reset Weaknesses
```
1. Predictable token: timestamp-based, sequential, short (< 32 bytes)
   Test: request reset twice, compare tokens for patterns

2. No expiry: old reset links still work after 24h
   Test: request reset, wait 24h, use link

3. User enumeration: different response for valid/invalid email
   "Reset link sent" vs "User not found" → reveals valid emails
   SAFE: always return "If this email exists, you'll receive a link"

4. Host header injection in reset email:
   Send: Host: attacker.com
   If reset link uses Host header → attacker receives reset link
```

### Detection — Unprotected Routes
```bash
# Find all routes
grep -rn "@app\.\|@router\.\|@bp\." --include="*.py" . | grep -v test

# Find routes WITH auth
grep -rn "Depends(get_current_user\|@login_required\|authenticate\|require_auth" \
  --include="*.py" . | grep -v test

# Compare: routes without auth dependency = CANDIDATES for missing auth check
```

---

## JWT Security

### Algorithm Confusion Attack
```python
# Attacker changes alg from RS256 to HS256
# Then signs with the PUBLIC KEY as the HMAC secret
# Server verifies with public key → signature is valid

# VULNERABLE server code
jwt.decode(token, key, algorithms=["RS256", "HS256"])  # accepts both!

# SAFE
jwt.decode(token, public_key, algorithms=["RS256"])  # explicit, single algorithm
```

### `alg: none` Attack
```python
# Attacker crafts token with algorithm "none" and no signature
header = base64({"alg": "none", "typ": "JWT"})
payload = base64({"sub": "admin", "role": "superuser"})
token = f"{header}.{payload}."  # empty signature

# VULNERABLE — library accepts alg:none
# SAFE — explicitly exclude "none" from allowed algorithms
```

### Weak Secret Brute Force
```bash
# If HS256 used, crack weak secrets
hashcat -a 0 -m 16500 <JWT> wordlist.txt
# Common weak secrets: "secret", "password", app name, domain name
```

### Missing Expiry
```python
# Check: does token have exp claim?
import jwt
decoded = jwt.decode(token, options={"verify_exp": False})
print(decoded.get("exp"))  # None = no expiry = tokens valid forever
```

### Detection
```bash
grep -rn "jwt\.\|PyJWT\|jsonwebtoken\|decode.*algorithm" \
  --include="*.py" --include="*.ts" . | grep -v test | grep -v node_modules
```

---

## Session Security

### Session Fixation
```
Attack:
1. Attacker gets session ID (from public endpoint, or from Set-Cookie before login)
2. Victim logs in using that session ID
3. Attacker's session ID is now authenticated

Fix: always regenerate session ID on login
```

### Session Not Invalidated on Logout
```bash
# Test:
1. Login → save session cookie/JWT
2. Logout
3. Use saved cookie/JWT → should return 401

# If still returns 200 → VULNERABLE (common with stateless JWT)
# Fix: JWT blocklist for logout, or short expiry + refresh token rotation
```

### Insecure Cookie Flags
```
Required cookie flags:
- HttpOnly: prevents JS access (mitigates XSS cookie theft)
- Secure: HTTPS only
- SameSite=Strict or Lax: CSRF protection

Check:
grep -rn "set_cookie\|response\.cookies\|httponly\|samesite" \
  --include="*.py" --include="*.ts" . | grep -v test
```

---

## Authorization (AuthZ)

### Ownership Check Pattern (the right way)
```python
# VULNERABLE — checks auth but not ownership
@router.get("/invoices/{invoice_id}")
async def get_invoice(invoice_id: int, user: User = Depends(get_current_user)):
    return await Invoice.get(id=invoice_id)  # any user can access any invoice!

# SAFE — checks both auth AND ownership
@router.get("/invoices/{invoice_id}")
async def get_invoice(invoice_id: int, user: User = Depends(get_current_user)):
    invoice = await Invoice.get(id=invoice_id, user_id=user.id)  # scoped to user
    if not invoice:
        raise HTTPException(404)
    return invoice
```

### Privilege Escalation via Mass Assignment
```python
# VULNERABLE
@router.put("/users/{user_id}")
async def update_user(user_id: int, data: dict, user = Depends(get_current_user)):
    await User.filter(id=user_id).update(**data)  # attacker can set role="admin"

# SAFE — explicit allowed fields
class UserUpdateSchema(BaseModel):
    name: str
    bio: str
    # role is NOT here — cannot be updated by user
```

### Detection
```bash
# Find places where user updates their own data — check for role/privilege fields
grep -rn "\.update\(\|\.save(\|\.patch(" --include="*.py" . | grep -v test
grep -rn "findByIdAndUpdate\|\.update(" --include="*.ts" . | grep -v test | grep -v node_modules
```

---

## CWE References
- CWE-287: Improper Authentication
- CWE-307: Brute Force (missing lockout)
- CWE-345: JWT Algorithm Confusion
- CWE-613: Insufficient Session Expiration
- CWE-620: Unverified Password Change
- CWE-640: Weak Password Recovery
- CWE-269: Improper Privilege Management
- CWE-284: Improper Access Control
