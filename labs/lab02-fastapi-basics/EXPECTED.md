# Lab 02 — Expected Results

## Test: Empty list

```bash
curl http://localhost:8000/transactions
```
Expected:
```json
[]
```

## Test: POST first transaction

```bash
curl -X POST http://localhost:8000/transactions \
  -H "Content-Type: application/json" \
  -d '{"amount": 50.0, "type": "expense", "category": "food", "description": "lunch", "date": "2026-05-01"}'
```
Expected:
```json
{"amount": 50.0, "type": "expense", "category": "food", "description": "lunch", "date": "2026-05-01", "id": 1}
```

## Test: POST second transaction

```bash
curl -X POST http://localhost:8000/transactions \
  -H "Content-Type: application/json" \
  -d '{"amount": 3000.0, "type": "income", "category": "salary", "date": "2026-05-01"}'
```
Expected: response includes `"id": 2` and `"description": ""`

## Test: GET all transactions

```bash
curl http://localhost:8000/transactions
```
Expected: JSON array with 2 transactions

## Test: Invalid type

```bash
curl -X POST http://localhost:8000/transactions \
  -H "Content-Type: application/json" \
  -d '{"amount": 10.0, "type": "unknown", "category": "food", "date": "2026-05-01"}'
```
Expected: HTTP 422 (Unprocessable Entity)

## Test: Restart confirms in-memory

Restart the server (`Ctrl+C`, then `uv run uvicorn main:app --reload`), then:
```bash
curl http://localhost:8000/transactions
```
Expected: `[]` — data is gone, confirming it was in-memory only

## Checklist

- [ ] `GET /transactions` returns `[]` on fresh server start
- [ ] First `POST /transactions` returns transaction with `"id": 1`
- [ ] Second `POST /transactions` returns transaction with `"id": 2`
- [ ] `GET /transactions` returns both transactions after two POSTs
- [ ] Swagger UI at `/docs` shows endpoints under `transactions` tag
- [ ] Invalid `type` value returns HTTP 422
- [ ] Restart server → `GET /transactions` returns `[]`
