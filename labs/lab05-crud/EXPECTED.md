# Lab 05 — Expected Results

## Test: Add via Form

1. Fill in all form fields on the page
2. Click Submit
3. The new transaction appears in the list immediately
4. The form clears after submit

**Refresh the browser** — the transaction is still there.

## Test: Delete

1. Click Delete on any transaction in the list
2. The transaction disappears immediately

**Verify in the database:**
```bash
sqlite3 backend/db/budget.db "SELECT * FROM transactions;"
```
The deleted transaction should not appear.

**Refresh the browser** — the transaction is still gone.

## Test: Backend DELETE — Not Found

```bash
curl -X DELETE http://localhost:8000/transactions/99999 -v
```
Expected:
- HTTP status: **404**
- Body: `{"detail":"Transaction not found"}`

## Test: Backend DELETE — Success

```bash
# Add a transaction first
curl -X POST http://localhost:8000/transactions \
  -H "Content-Type: application/json" \
  -d '{"amount": 10.0, "type": "expense", "category": "test", "date": "2026-05-01"}'

# Note the id in the response, then delete it (replace 1 with actual id)
curl -X DELETE http://localhost:8000/transactions/1 -v
```
Expected:
- HTTP status: **204**
- No response body

## Checklist

- [ ] Form submits and new transaction appears in list immediately
- [ ] Form clears after successful submit
- [ ] Refresh after adding → transaction persists
- [ ] Delete button removes transaction from list immediately
- [ ] Refresh after deleting → transaction is gone
- [ ] `DELETE /transactions/99999` returns HTTP 404
- [ ] `DELETE /transactions/{valid_id}` returns HTTP 204 with no body
- [ ] Database reflects additions and deletions (verify with sqlite3)
