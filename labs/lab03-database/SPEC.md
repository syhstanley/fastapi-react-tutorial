# Lab 03 — Spec

## 1. Add dependency

```bash
uv add sqlalchemy
```

## 2. Create `backend/database.py`

This module sets up the database connection. It must define:

- An SQLite engine connecting to `db/budget.db` (create the `db/` directory programmatically if it doesn't exist)
- A `SessionLocal` session factory using `sessionmaker`
- A `Base` declarative base (from `declarative_base()`)
- A `get_db` generator function that:
  - Creates a new session
  - Yields it (so route handlers can use it)
  - Closes the session in a `finally` block (so it always closes, even on error)

## 3. Create `backend/models.py`

Define a `Transaction` SQLAlchemy model with `__tablename__ = "transactions"` and these columns:

| Column | SQLAlchemy Type | Notes |
|--------|----------------|-------|
| id | Integer | primary_key=True, index=True |
| amount | Float | nullable=False |
| type | String | nullable=False |
| category | String | nullable=False |
| description | String | default="" |
| date | Date | nullable=False |
| created_at | DateTime | default=datetime.utcnow (no parentheses) |

Import `Base` from `database.py`. The model class must inherit from `Base`.

## 4. Update `backend/main.py`

Add these two lines near the top of `main.py` (before any routes), to create the database tables on startup:

```python
from database import engine
from models import Base

Base.metadata.create_all(bind=engine)
```

## 5. Update `backend/routers/transactions.py`

Replace the in-memory list with real database operations. Both routes must accept `db: Session = Depends(get_db)`.

**`GET /`**
- Query all `Transaction` rows from the database
- Return them as `list[TransactionResponse]`

**`POST /`**
- Create a new `Transaction` ORM object from the request body
- `db.add(transaction)`, `db.commit()`, `db.refresh(transaction)`
- Return the transaction as `TransactionResponse`

Remove the module-level list and counter variables — they are no longer needed.

## 6. Create `.gitignore`

Create `backend/.gitignore` with:
```
db/
.venv/
__pycache__/
*.pyc
```

## Requirements

- Data must persist across server restarts
- `db/budget.db` must be created automatically on first startup
- The request/response JSON format must be identical to Lab 02 (same fields, same types)
- `GET /transactions` and `POST /transactions` must still work exactly as before
