# Access Control — Reference (IDOR, BFLA, Privilege Escalation)

## IDOR (Insecure Direct Object Reference)

### What It Is
User A can access/modify User B's resources by changing an ID in the request.

### Detection Pattern
```bash
# Find all endpoints with ID parameters in path or query
grep -rn "/{.*_id}\|/{.*id}\|/{\w*Id}" --include="*.py" --include="*.ts" . | grep -v test

# Find all database fetches by ID without user scope
grep -rn "\.get(id=\|\.filter(id=\|findById\|getById" \
  --include="*.py" --include="*.ts" . | grep -v test
```

### Vulnerable vs Safe Pattern
```python
# VULNERABLE
@router.get("/documents/{doc_id}")
async def get_doc(doc_id: int, user = Depends(get_current_user)):
    return await Document.get(id=doc_id)  # IDOR!

# SAFE — scope every query to requesting user
@router.get("/documents/{doc_id}")
async def get_doc(doc_id: int, user = Depends(get_current_user)):
    doc = await Document.get_or_none(id=doc_id, owner_id=user.id)
    if not doc:
        raise HTTPException(status_code=404)  # 404 not 403 — don't reveal existence
    return doc
```

### Test Cases to Verify
```
1. Login as User A, note resource ID (e.g., /api/orders/42)
2. Login as User B (different account)
3. Access /api/orders/42 as User B
   → 404 or 403 = SECURE
   → 200 with User A's data = VULNERABLE

4. Test indirect references: /api/me/orders returns orders, but also try
   /api/users/{user_a_id}/orders as User B

5. Test via different HTTP methods:
   GET /api/profile/42 → might be protected
   PUT /api/profile/42 → might not be
```

### ID Enumeration Prevention
```python
# Use UUIDs instead of sequential integers for user-facing IDs
# Sequential: id=42 → attacker tries 41, 43, 44...
# UUID: id=550e8400-e29b-41d4-a716-446655440000 → not enumerable

# If must use sequential IDs: always scope to owner (see above)
```

---

## BFLA (Broken Function Level Authorization)

### What It Is
Regular user can call admin-only functions/endpoints.

### Common Patterns
```
Attack vectors:
1. Admin API endpoints not protected with role check
   GET /api/admin/users → accessible without admin role
   POST /api/admin/users/{id}/ban → regular user can ban anyone

2. Role passed in request body (not from token)
   POST /api/actions {"action": "delete_user", "role": "admin"}

3. HTTP method override
   Regular user can GET /api/reports (allowed)
   Regular user POST/DELETE /api/reports → should be admin-only, but might not be

4. Hidden admin endpoints not in docs but still accessible
```

### Detection
```bash
# Find admin-only route patterns
grep -rn "/admin\|/internal\|/superuser\|/management" \
  --include="*.py" --include="*.ts" . | grep -v test

# Check if admin routes have proper role verification
grep -rn "is_admin\|role.*admin\|require_role\|has_permission\|check_admin" \
  --include="*.py" --include="*.ts" . | grep -v test
```

### Safe Pattern
```python
# FastAPI role check dependency
def require_admin(user: User = Depends(get_current_user)):
    if user.role != "admin":
        raise HTTPException(status_code=403)
    return user

@router.delete("/admin/users/{user_id}")
async def delete_user(user_id: int, admin = Depends(require_admin)):
    ...
```

---

## Privilege Escalation

### Vertical (Regular → Admin)
```python
# VULNERABLE — user can self-promote
@router.patch("/users/me")
async def update_profile(data: UserUpdate, user = Depends(get_current_user)):
    await user.update(**data.dict())  # if UserUpdate contains role field

# Attack: PATCH /users/me {"role": "admin"}
```

### Horizontal (User A → User B's same-level access)
See IDOR section above — this is horizontal privilege escalation.

### Path Traversal as Privilege Escalation
```python
# VULNERABLE — access files outside allowed directory
@router.get("/files/{filename}")
async def get_file(filename: str):
    return FileResponse(f"/app/uploads/{filename}")
# Attack: GET /files/../../etc/passwd

# SAFE
from pathlib import Path
UPLOAD_DIR = Path("/app/uploads").resolve()

@router.get("/files/{filename}")
async def get_file(filename: str):
    file_path = (UPLOAD_DIR / filename).resolve()
    if not str(file_path).startswith(str(UPLOAD_DIR)):
        raise HTTPException(400, "Invalid path")
    return FileResponse(file_path)
```

---

## Multi-Tenant / Organization Isolation

### The Silent IDOR in Multi-Tenant Apps
```python
# VULNERABLE — user from Org A accesses Org B's data
@router.get("/projects/{project_id}")
async def get_project(project_id: int, user = Depends(get_current_user)):
    return await Project.get(id=project_id)  # no org check!

# Attack: enumerate project IDs from another organization

# SAFE — always scope to organization
@router.get("/projects/{project_id}")
async def get_project(project_id: int, user = Depends(get_current_user)):
    return await Project.get(id=project_id, organization_id=user.organization_id)
```

### Detection
```bash
# In multi-tenant apps, check EVERY database query for tenant scoping
grep -rn "\.get(\|\.filter(\|\.find(" --include="*.py" . | grep -v "organization_id\|tenant_id\|user_id" | grep -v test
# Findings here are CANDIDATES for missing tenant isolation
```

---

## CWE References
- CWE-639: IDOR — Authorization Bypass Through User-Controlled Key
- CWE-285: Improper Authorization (BFLA)
- CWE-269: Improper Privilege Management
- CWE-22: Path Traversal (as access control bypass)
- CWE-923: Multi-Tenant Isolation
