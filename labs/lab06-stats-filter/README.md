# Lab 06 — Summary Stats & Category Filter

## What You'll Learn
- How to aggregate data in SQLAlchemy (sum, count)
- How to add optional query parameters to FastAPI routes
- How to filter and derive data from React state

## Background

### SQLAlchemy Aggregation

SQLAlchemy can run aggregate functions (SUM, COUNT, AVG) directly in the database query:

```python
from sqlalchemy import func

# Sum all expense amounts
total = db.query(func.sum(Transaction.amount)).filter(
    Transaction.type == "expense"
).scalar()
# .scalar() returns a single value (or None if no rows match)
# Use `or 0` to handle the None case:
total_expense = db.query(func.sum(Transaction.amount)).filter(
    Transaction.type == "expense"
).scalar() or 0.0
```

### FastAPI Optional Query Parameters

Define an optional query parameter by giving it a default value of `None`:

```python
@router.get("/")
def list_transactions(
    category: str = None,
    db: Session = Depends(get_db)
):
    query = db.query(Transaction)
    if category:
        query = query.filter(Transaction.category == category)
    return query.all()
```

When called as `GET /transactions?category=food`, `category` will be `"food"`.
When called as `GET /transactions`, `category` will be `None`.

### Route Order Matters

If you later have `GET /{id}` and you add `GET /summary`, FastAPI will try to match "summary" as an `id`. To avoid this, define `GET /summary` **before** `GET /{id}` in your router file.

### Derived State in React

Instead of storing a filtered list in separate state, compute it from existing state:

```jsx
const [transactions, setTransactions] = useState([])
const [selectedCategory, setSelectedCategory] = useState('')

// Derived — computed on every render, no useState needed
const filteredTransactions = selectedCategory
  ? transactions.filter(t => t.category === selectedCategory)
  : transactions

// Unique categories for the dropdown
const categories = [...new Set(transactions.map(t => t.category))]
```

This is simpler than keeping a separate filtered list in state.

## Tips

- The summary endpoint is a completely new route — not a modification of `GET /transactions`
- Re-fetch the summary whenever you add or delete a transaction (so the numbers stay current)
- Balance can be negative (more expenses than income)
- The "All" option in the category dropdown should clear the filter and show all transactions
