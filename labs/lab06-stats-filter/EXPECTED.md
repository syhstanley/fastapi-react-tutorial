# Lab 06 — Expected Results

## Setup: Add varied test data

```bash
curl -X POST http://localhost:8000/transactions -H "Content-Type: application/json" \
  -d '{"amount": 3000.0, "type": "income", "category": "salary", "date": "2026-05-01"}'

curl -X POST http://localhost:8000/transactions -H "Content-Type: application/json" \
  -d '{"amount": 50.0, "type": "expense", "category": "food", "date": "2026-05-02"}'

curl -X POST http://localhost:8000/transactions -H "Content-Type: application/json" \
  -d '{"amount": 30.0, "type": "expense", "category": "food", "date": "2026-05-10"}'

curl -X POST http://localhost:8000/transactions -H "Content-Type: application/json" \
  -d '{"amount": 1000.0, "type": "expense", "category": "rent", "date": "2026-05-05"}'
```

## Test: Summary Endpoint

```bash
curl http://localhost:8000/transactions/summary
```
Expected:
```json
{"total_income": 3000.0, "total_expense": 1080.0, "balance": 1920.0}
```

## Test: Category Filter

```bash
curl "http://localhost:8000/transactions?category=food"
```
Expected: array with 2 transactions (the two food expenses)

```bash
curl "http://localhost:8000/transactions?category=rent"
```
Expected: array with 1 transaction

```bash
curl "http://localhost:8000/transactions?category=doesnotexist"
```
Expected: `[]`

```bash
curl "http://localhost:8000/transactions"
```
Expected: all 4 transactions (no filter)

## Browser Check

1. Page loads → summary bar shows Income: 3000.0, Expense: 1080.0, Balance: 1920.0
2. Category dropdown contains: All, salary, food, rent
3. Select `food` → list shows 2 food transactions only
4. Select `rent` → list shows 1 rent transaction only
5. Select `All` → list shows all 4 transactions
6. Add a new transaction → summary bar updates immediately
7. Delete a transaction → summary bar updates immediately

## Checklist

- [ ] `GET /transactions/summary` returns correct totals
- [ ] Balance = total_income - total_expense (verify the math manually)
- [ ] `GET /transactions?category=food` returns only food transactions
- [ ] `GET /transactions?category=doesnotexist` returns `[]`
- [ ] Summary bar displays correct values on page load
- [ ] Summary bar updates after adding a transaction
- [ ] Summary bar updates after deleting a transaction
- [ ] Category dropdown shows unique categories from current data
- [ ] Selecting a category in the dropdown filters the displayed list
- [ ] Selecting "All" shows all transactions
