# Lab 03 — Expected Results

## Test: Persistence

**Step 1: Add a transaction**
```bash
curl -X POST http://localhost:8000/transactions \
  -H "Content-Type: application/json" \
  -d '{"amount": 100.0, "type": "income", "category": "salary", "date": "2026-05-01"}'
```

**Step 2: Restart the server**
```
Ctrl+C
uv run uvicorn main:app --reload
```

**Step 3: Fetch transactions**
```bash
curl http://localhost:8000/transactions
```
Expected: the transaction you added is still there (not `[]`)

## Test: Database file exists

```bash
ls backend/db/
```
Expected: `budget.db` file exists

## Test: Inspect database directly

```bash
sqlite3 backend/db/budget.db
```
Then inside the sqlite3 prompt:
```sql
SELECT * FROM transactions;
.quit
```
Expected: your transaction(s) appear as rows in the table

## Test: Multiple restarts

Add 3 transactions, restart the server twice, then `GET /transactions`.
Expected: all 3 transactions are still present.

## Checklist

- [ ] Add transaction, restart server, `GET /transactions` still returns it
- [ ] `db/budget.db` file exists after first startup
- [ ] `sqlite3 db/budget.db` → `SELECT * FROM transactions;` shows the data
- [ ] Response JSON format is identical to Lab 02 (same fields)
- [ ] `created_at` column exists in the database (visible in sqlite3)
- [ ] Server starts without errors after adding `Base.metadata.create_all`
