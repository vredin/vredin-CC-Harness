# Business Logic Security — Reference

## Race Conditions

### Double-Spend / Double-Action Attack
```python
# VULNERABLE — classic TOCTOU (Time-of-Check to Time-of-Use)
async def redeem_coupon(coupon_code: str, user_id: int):
    coupon = await Coupon.get(code=coupon_code)
    if coupon.used:                          # CHECK
        raise HTTPException(400, "Already used")
    await process_discount(user_id)
    await coupon.update(used=True)           # USE
    # Attacker sends 10 concurrent requests:
    # All pass the CHECK before any UPDATE completes → coupon redeemed 10 times

# SAFE — atomic database operation (optimistic locking)
async def redeem_coupon(coupon_code: str, user_id: int):
    updated_count = await Coupon.filter(code=coupon_code, used=False).update(used=True)
    if updated_count == 0:
        raise HTTPException(400, "Already used")
    await process_discount(user_id)

# SAFE — database-level locking (pessimistic)
async with database.transaction():
    coupon = await Coupon.select_for_update().get(code=coupon_code)
    if coupon.used:
        raise HTTPException(400, "Already used")
    coupon.used = True
    await coupon.save()
    await process_discount(user_id)
```

### Balance Race Condition
```python
# VULNERABLE — balance manipulation via concurrent requests
async def withdraw(user_id: int, amount: float):
    user = await User.get(id=user_id)
    if user.balance >= amount:               # CHECK
        user.balance -= amount               # USE (not atomic)
        await user.save()
    # Attacker sends concurrent withdrawals → balance goes negative

# SAFE — atomic SQL update
from tortoise.expressions import F
result = await User.filter(id=user_id, balance__gte=amount).update(
    balance=F('balance') - amount
)
if result == 0:
    raise HTTPException(400, "Insufficient funds")
```

### Detection
```bash
# Find TOCTOU patterns: check then act
grep -rn "\.get(\|\.filter(" --include="*.py" . | grep -v test > /tmp/gets.txt
grep -rn "\.update(\|\.save(\|\.delete(" --include="*.py" . | grep -v test > /tmp/updates.txt
# Look for files where get + update appear without transaction/select_for_update
```

---

## Price & Value Manipulation

### Negative Values
```python
# VULNERABLE
@router.post("/cart/add")
async def add_to_cart(item_id: int, quantity: int):
    # quantity = -5 → removes from cart, but if coupled with payment:
    # total_price = sum(item.price * item.quantity for item in cart)
    # total_price becomes negative → attacker gets paid!

# SAFE
if quantity <= 0:
    raise HTTPException(400, "Quantity must be positive")
if quantity > 1000:  # reasonable upper bound
    raise HTTPException(400, "Quantity too large")
```

### Price from Client (Never Trust)
```python
# VULNERABLE — trusting price sent by client
@router.post("/checkout")
async def checkout(items: list[CartItemWithPrice]):
    total = sum(item.price * item.quantity for item in items)
    # Attacker sends items with price=0.01 instead of actual price

# SAFE — always calculate price server-side
@router.post("/checkout")
async def checkout(items: list[CartItemRequest]):
    # items only contains product_id and quantity
    total = 0
    for item in items:
        product = await Product.get(id=item.product_id)  # price from DB
        total += product.price * item.quantity
    charge(total)
```

### Integer Overflow
```python
# VULNERABLE — large numbers causing overflow in older Python, or in frontend
quantity = 2**63  # in JS: Number.MAX_SAFE_INTEGER + 1 causes issues

# SAFE — validate reasonable bounds
from pydantic import Field

class OrderItem(BaseModel):
    quantity: int = Field(gt=0, le=10_000)
    product_id: int = Field(gt=0)
```

---

## Workflow Bypass

### Step Skipping
```
Example: 3-step checkout flow
1. Add items to cart
2. Enter payment details (validate card)
3. Confirm purchase

Attack: skip step 2, directly call step 3 endpoint
→ Order placed without payment

Fix: each step must validate previous step was completed
    Store state server-side (session/DB), never trust client state
```

### Status Transition Manipulation
```python
# VULNERABLE — any status transition allowed
@router.patch("/orders/{order_id}")
async def update_order_status(order_id: int, status: str):
    await Order.filter(id=order_id).update(status=status)
# Attacker: sets status from "pending" to "delivered" → skips payment

# SAFE — enforce valid transitions
VALID_TRANSITIONS = {
    "pending": ["payment_processing", "cancelled"],
    "payment_processing": ["paid", "failed"],
    "paid": ["shipped"],
    "shipped": ["delivered"],
    "failed": ["pending"],
}

@router.patch("/orders/{order_id}")
async def update_order_status(order_id: int, new_status: str, user = Depends(get_current_user)):
    order = await Order.get(id=order_id, user_id=user.id)
    if new_status not in VALID_TRANSITIONS.get(order.status, []):
        raise HTTPException(400, f"Cannot transition from {order.status} to {new_status}")
    await order.update(status=new_status)
```

---

## Time-Based Attacks

### Coupon/Promo Expiry Bypass
```python
# VULNERABLE — trusting client-sent timestamp
@router.post("/apply-promo")
async def apply_promo(code: str, timestamp: int):
    if timestamp < promo.expiry:  # trusting client time!
        apply_discount()

# SAFE — always use server time
from datetime import datetime, timezone
now = datetime.now(timezone.utc)
if now > promo.expiry:
    raise HTTPException(400, "Promo expired")
```

### Time-of-Check Window Exploitation
```
Scenario: access token valid for 1 hour
Attack: use token at 59:59 (just before expiry)
        server validates: "valid" (checked at 59:59)
        server processes request: takes 2 minutes
        request completes: using expired token at 62:00

Fix: validate token at the moment of processing, not just at entry
```

---

## Referral / Bonus Abuse

```
Self-referral: user refers themselves with different email
Multi-account: create multiple accounts to redeem signup bonus repeatedly
Circular referral: A refers B, B refers A → both get bonus

Detection checks:
- Same IP address registering multiple accounts
- Same payment method used across accounts
- Email patterns (attacker+1@gmail.com = attacker@gmail.com)
- Device fingerprinting consistency
```

---

## CWE References
- CWE-362: Race Condition (TOCTOU)
- CWE-841: Improper Enforcement of Behavioral Workflow
- CWE-20: Improper Input Validation (negative quantities, price manipulation)
- CWE-190: Integer Overflow
- CWE-613: Insufficient Session Expiration (workflow state)
