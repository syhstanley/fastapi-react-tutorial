# Lab 07 — Expected Results

## Setup: Add data across multiple months

```bash
curl -X POST http://localhost:8000/transactions -H "Content-Type: application/json" \
  -d '{"amount": 3000.0, "type": "income", "category": "salary", "date": "2026-05-01"}'

curl -X POST http://localhost:8000/transactions -H "Content-Type: application/json" \
  -d '{"amount": 50.0, "type": "expense", "category": "food", "date": "2026-05-15"}'

curl -X POST http://localhost:8000/transactions -H "Content-Type: application/json" \
  -d '{"amount": 2800.0, "type": "income", "category": "salary", "date": "2026-04-01"}'

curl -X POST http://localhost:8000/transactions -H "Content-Type: application/json" \
  -d '{"amount": 40.0, "type": "expense", "category": "food", "date": "2026-04-20"}'
```

## Test: Month Filter

```bash
curl "http://localhost:8000/transactions?month=2026-05"
```
Expected: 2 transactions (the two May entries)

```bash
curl "http://localhost:8000/transactions?month=2026-04"
```
Expected: 2 transactions (the two April entries)

```bash
curl "http://localhost:8000/transactions?month=2026-05&category=food"
```
Expected: 1 transaction (May + food only)

```bash
curl "http://localhost:8000/transactions?month=2026-03"
```
Expected: `[]`

## Test: Edit Endpoint

```bash
# Edit transaction id=1 (adjust id as needed)
curl -X PUT http://localhost:8000/transactions/1 \
  -H "Content-Type: application/json" \
  -d '{"amount": 3500.0, "type": "income", "category": "salary", "date": "2026-05-01"}'
```
Expected: returns transaction with updated `amount: 3500.0`, same `id`, same `created_at`

```bash
curl -X PUT http://localhost:8000/transactions/99999 \
  -H "Content-Type: application/json" \
  -d '{"amount": 1.0, "type": "expense", "category": "test", "date": "2026-05-01"}'
```
Expected: HTTP 404

## Checklist

- [ ] `GET /transactions?month=2026-05` returns only May 2026 transactions
- [ ] `GET /transactions?month=2026-04` returns only April 2026 transactions
- [ ] `GET /transactions?month=2026-05&category=food` combines both filters correctly
- [ ] `GET /transactions?month=2026-03` returns `[]`
- [ ] `PUT /transactions/{id}` updates the transaction and returns updated data
- [ ] `PUT /transactions/99999` returns HTTP 404
- [ ] Editing does not change `id` or `created_at`
- [ ] Refresh browser after edit → changes are persisted
- [ ] Edit form shows current values pre-filled
- [ ] Month filter UI exists and works in the browser
- [ ] Month and category filters work together in the UI
- [ ] All Lab 01–06 functionality still works
