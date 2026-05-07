# Lab 02 — Spec

## Given: Schema Definitions

Copy the following exactly into `backend/schemas.py`. Do not modify it.

```python
from pydantic import BaseModel
from datetime import date
from enum import Enum


class TransactionType(str, Enum):
    income = "income"
    expense = "expense"


class TransactionCreate(BaseModel):
    amount: float
    type: TransactionType
    category: str
    description: str = ""
    date: date


class TransactionResponse(TransactionCreate):
    id: int

    class Config:
        from_attributes = True
```

## Your Tasks

### 1. Create `backend/routers/__init__.py`

Create an empty file at `backend/routers/__init__.py` (makes `routers` a Python package).

### 2. Create `backend/routers/transactions.py`

Implement a router with two routes. Define them as `GET /` and `POST /` — the `/transactions` prefix is added in `main.py`.

**`GET /`**
- Returns a list of all stored transactions
- Return type: `list[TransactionResponse]`
- Returns `[]` when no transactions exist

**`POST /`**
- Accepts a `TransactionCreate` request body
- Assigns an auto-incremented integer `id` (starting from 1)
- Stores the transaction
- Returns the stored transaction as `TransactionResponse`

Use a module-level list and counter to store data. Data does not need to survive a server restart.

### 3. Update `backend/main.py`

Mount the transactions router with:
- `prefix="/transactions"`
- `tags=["transactions"]`

Keep the existing `GET /health` endpoint.

## Requirements

- `GET /transactions` returns `[]` on a fresh server start
- `POST /transactions` returns the transaction with `id: 1` for the first transaction, `id: 2` for the second, etc.
- Sending invalid data (e.g. `type: "unknown"`) must return HTTP 422 (this is automatic — you don't need to add validation code)
- Swagger UI must show both endpoints grouped under the `transactions` tag
