# Cryptography — Reference

## Password Hashing

### Vulnerable Patterns
```python
# CRITICAL — storing plaintext passwords
user.password = password

# CRITICAL — reversible encoding (not hashing)
user.password = base64.encode(password)

# HIGH — broken hash algorithms for passwords
import hashlib
user.password = hashlib.md5(password.encode()).hexdigest()
user.password = hashlib.sha1(password.encode()).hexdigest()
user.password = hashlib.sha256(password.encode()).hexdigest()  # fast = crackable
# MD5/SHA1/SHA256 without salt/iteration: ~10 billion hashes/second on GPU

# SAFE — use purpose-built password hashing
from passlib.context import CryptContext
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
hashed = pwd_context.hash(password)
verified = pwd_context.verify(password, hashed)

# Also safe: argon2, scrypt, pbkdf2 with 100k+ iterations
```

### Detection
```bash
grep -rn "hashlib\.md5\|hashlib\.sha1\|hashlib\.sha256\|\.hexdigest()" \
  --include="*.py" . | grep -v test | grep -v fixture | grep -v checksum | grep -v verify

grep -rn "base64\.encode\|b64encode" \
  --include="*.py" . | grep -i "password\|passwd\|secret" | grep -v test
```

---

## Symmetric Encryption

### Vulnerable Patterns
```python
# HIGH — ECB mode (blocks encrypted independently → reveals patterns)
from Crypto.Cipher import AES
cipher = AES.new(key, AES.MODE_ECB)

# HIGH — CBC without authentication (padding oracle attacks)
cipher = AES.new(key, AES.MODE_CBC, iv)
# Without HMAC → attacker can flip bits in ciphertext

# SAFE — use AES-GCM (authenticated encryption)
from Crypto.Cipher import AES
cipher = AES.new(key, AES.MODE_GCM)
ciphertext, tag = cipher.encrypt_and_digest(data)
# Includes authentication tag → prevents tampering

# BEST — use high-level library (Fernet, NaCl)
from cryptography.fernet import Fernet
key = Fernet.generate_key()
f = Fernet(key)
token = f.encrypt(data)
plaintext = f.decrypt(token)
```

### Detection
```bash
grep -rn "AES\.MODE_ECB\|MODE_ECB\|AES\.new(" \
  --include="*.py" . | grep -v test

grep -rn "DES\b\|3DES\|RC4\|Blowfish" \
  --include="*.py" --include="*.ts" . | grep -v test | grep -v node_modules
```

---

## Asymmetric Encryption / RSA

### Vulnerable RSA Patterns
```python
# HIGH — RSA PKCS#1 v1.5 padding (vulnerable to padding oracle / BLEICHENBACHER)
from Crypto.Cipher import PKCS1_v1_5
cipher = PKCS1_v1_5.new(public_key)
# Use OAEP instead

# HIGH — short key size
key = RSA.generate(1024)  # broken in 2010, factored with modern hardware
# Minimum: 2048 bits, Recommended: 4096 bits

# SAFE
from Crypto.Cipher import PKCS1_OAEP
cipher = PKCS1_OAEP.new(public_key)
```

---

## Timing Attacks

### Vulnerable String Comparison
```python
# VULNERABLE — early-exit comparison leaks timing info
if token == expected_token:  # Python string == has timing side channel
    grant_access()

if hmac.digest != computed_hmac:  # same problem
    raise InvalidSignature

# SAFE — constant-time comparison
import hmac
if hmac.compare_digest(token, expected_token):
    grant_access()

# Also safe (Python 3.6+)
import secrets
if secrets.compare_digest(provided, expected):
    grant_access()
```

### Detection
```bash
grep -rn "== token\|== secret\|== api_key\|== signature\|== hmac\|== hash" \
  --include="*.py" . | grep -v test | grep -v compare_digest
```

---

## Random Number Generation

### Predictable vs Cryptographically Secure
```python
# VULNERABLE — predictable, DO NOT use for:
# - password reset tokens
# - session IDs
# - CSRF tokens
# - API keys
import random
token = random.randint(100000, 999999)  # predictable!
token = random.choice(string.ascii_letters) * 32  # predictable!

# SAFE — use secrets module (Python 3.6+)
import secrets
token = secrets.token_urlsafe(32)   # 256 bits of entropy
otp = secrets.randbelow(1000000)    # cryptographically random 6-digit code
api_key = secrets.token_hex(32)     # 64-char hex string
```

```javascript
// VULNERABLE
Math.random()  // predictable, not cryptographically secure

// SAFE
crypto.randomUUID()                          // Node.js / browser
crypto.randomBytes(32).toString('hex')       // Node.js
window.crypto.getRandomValues(new Uint8Array(32))  // browser
```

### Detection
```bash
grep -rn "random\.randint\|random\.choice\|random\.random()\|Math\.random()" \
  --include="*.py" --include="*.ts" --include="*.js" . | grep -v test | grep -v node_modules
# → Check if used for security-sensitive tokens/codes
```

---

## Key Management

### Hardcoded Keys
```python
# VULNERABLE
SECRET_KEY = "hardcoded-jwt-secret"
ENCRYPTION_KEY = b"1234567890123456"

# SAFE
SECRET_KEY = os.environ["SECRET_KEY"]
ENCRYPTION_KEY = base64.b64decode(os.environ["ENCRYPTION_KEY"])
```

### Weak JWT Secrets
```python
# Minimum JWT secret length: 256 bits (32 bytes) for HS256
# Common weak secrets: "secret", "password", app name, "jwt_secret"
# Test: can it be cracked with hashcat using a wordlist?

# SAFE — generate strong secret
python3 -c "import secrets; print(secrets.token_hex(32))"
```

### Key Rotation
- JWT secrets: rotation mechanism must exist (revoke old sessions when rotated)
- API keys: can be revoked individually without affecting other keys
- Encryption keys: old data must be re-encrypted with new key

---

## TLS / HTTPS

```python
# Check SSL verification is not disabled
import requests
# VULNERABLE
requests.get(url, verify=False)  # disables TLS cert verification — MITM possible
# SAFE
requests.get(url)  # verify=True by default

# VULNERABLE in httpx
httpx.get(url, verify=False)
```

```bash
# Detection
grep -rn "verify=False\|ssl_verify.*False\|rejectUnauthorized.*false\|NODE_TLS_REJECT_UNAUTHORIZED=0" \
  --include="*.py" --include="*.ts" --include="*.js" \
  . | grep -v test | grep -v node_modules
```

---

## CWE References
- CWE-916: Use of Password Hash With Insufficient Computational Effort
- CWE-327: Use of Broken Cryptographic Algorithm (MD5, SHA1, DES, RC4, ECB)
- CWE-330: Use of Insufficiently Random Values
- CWE-326: Inadequate Encryption Strength (short keys)
- CWE-208: Timing Attack (non-constant-time comparison)
- CWE-321: Hardcoded Cryptographic Key
- CWE-295: Improper Certificate Validation (verify=False)
