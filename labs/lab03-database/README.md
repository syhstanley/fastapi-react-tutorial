# Lab 03 — SQLite + SQLAlchemy

## What You'll Learn
- What an ORM is and why use it instead of raw SQL
- The difference between SQLAlchemy models and Pydantic schemas
- How to wire up a SQLite database to FastAPI
- How FastAPI's `Depends` system works for shared resources

## Background

### ORM vs Raw SQL

An ORM (Object-Relational Mapper) lets you interact with a database using Python objects and methods instead of writing SQL strings.

**Without ORM:**
```python
cursor.execute(
    "INSERT INTO transactions (amount, type, category) VALUES (?, ?, ?)",
    (50.0, "expense", "food")
)
conn.commit()
```

**With SQLAlchemy ORM:**
```python
transaction = Transaction(amount=50.0, type="expense", category="food")
db.add(transaction)
db.commit()
```

Both do the same thing — SQLAlchemy just handles the SQL generation.

### SQLAlchemy Models vs Pydantic Schemas

These look similar but are different things:

| | SQLAlchemy Model | Pydantic Schema |
|--|-----------------|-----------------|
| Lives in | `models.py` | `schemas.py` |
| Purpose | Defines DB table structure | Defines API shape |
| Inherits from | `Base` | `BaseModel` |
| Used by | Database queries | FastAPI routes |

You'll have both in your app. FastAPI converts between them automatically when you have `from_attributes = True` in your Pydantic schema (which is already in your `schemas.py` from Lab 02).

### SQLAlchemy Session and Depends

Each database operation needs a "session" — think of it as an open connection to the database. FastAPI's `Depends` system provides a session to each route handler and automatically closes it when the request is done:

```python
# database.py
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# routers/transactions.py
@router.get("/")
def list_transactions(db: Session = Depends(get_db)):
    return db.query(Transaction).all()
```

### SQLite

SQLite stores the entire database in a single file — no separate database server needed. The file is created automatically the first time you connect to it. You can inspect it with the `sqlite3` command-line tool.

## Project Structure After This Lab

```
backend/
├── pyproject.toml
├── main.py
├── schemas.py
├── models.py        ← new
├── database.py      ← new
├── db/
│   └── budget.db    ← created at runtime (not committed to git)
└── routers/
    ├── __init__.py
    └── transactions.py
```

## Tips

- `Base.metadata.create_all(bind=engine)` creates tables if they don't exist — safe to call every time the server starts
- SQLAlchemy column types: `Integer`, `Float`, `String`, `Date`, `DateTime`
- For `created_at`, use `default=datetime.utcnow` — note: no parentheses. You're passing the function itself, not calling it. SQLAlchemy calls it each time a new row is inserted.
- After `db.add(obj)` and `db.commit()`, call `db.refresh(obj)` to load the auto-generated `id` back into the object
- Add `db/` to your `.gitignore` — don't commit database files
