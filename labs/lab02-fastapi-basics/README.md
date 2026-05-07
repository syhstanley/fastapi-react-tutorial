# Lab 02 — FastAPI Routes & Pydantic Schemas

## What You'll Learn
- How Pydantic models validate request and response data
- The difference between input schemas and output schemas
- How FastAPI routers keep code organized
- How to use in-memory storage as a temporary data store

## Background

### Pydantic Models

FastAPI uses Pydantic for data validation. You define classes that inherit from `BaseModel`, and FastAPI automatically:
- Validates incoming JSON request bodies
- Rejects invalid data with a 422 error
- Serializes Python objects to JSON in responses

### Request vs Response Schemas

It's common to have two types of schemas per resource:

- **Create schema** — what the client sends. No `id` (the server assigns it).
- **Response schema** — what the server returns. Includes `id` and any server-generated fields.

```python
class TransactionCreate(BaseModel):
    amount: float
    category: str
    # ... other fields the client provides

class TransactionResponse(TransactionCreate):
    id: int  # server-assigned
```

`TransactionResponse` inherits from `TransactionCreate`, so it has all the same fields plus `id`.

### FastAPI Routers

As your app grows, putting all routes in `main.py` becomes unwieldy. `APIRouter` lets you define routes in separate files:

```python
# routers/transactions.py
from fastapi import APIRouter

router = APIRouter()

@router.get("/")
def list_transactions():
    return []
```

```python
# main.py
from routers import transactions

app.include_router(
    transactions.router,
    prefix="/transactions",
    tags=["transactions"]
)
```

The `prefix` is prepended to all routes in the router. So `GET /` in the router becomes `GET /transactions` in the final app.

The `tags` group the routes in Swagger UI.

### In-Memory Storage

For this lab, store transactions in a Python list at module level. This is intentionally temporary — data resets on every server restart. You'll fix this in Lab 03.

```python
# module-level — persists as long as the server is running
_transactions: list[dict] = []
_next_id: int = 1
```

## Project Structure After This Lab

```
backend/
├── pyproject.toml
├── main.py
├── schemas.py          ← new (given to you in SPEC.md)
└── routers/
    └── transactions.py ← new (you implement this)
```

## Tips

- Use Swagger UI (`/docs`) to test your endpoints — it's easier than curl for development
- `from_attributes = True` in `TransactionResponse.Config` is needed for Lab 03 when you start returning SQLAlchemy objects
- Enums in Pydantic: `TransactionType` restricts the `type` field to only `"income"` or `"expense"` — any other value returns a 422 error automatically
- The `description` field has a default value (`""`), so it's optional in requests
