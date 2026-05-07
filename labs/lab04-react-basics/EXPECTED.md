# Lab 04 — Expected Results

## Setup: Add test data via curl

Before testing the frontend, add some transactions:

```bash
curl -X POST http://localhost:8000/transactions \
  -H "Content-Type: application/json" \
  -d '{"amount": 3000.0, "type": "income", "category": "salary", "date": "2026-05-01"}'

curl -X POST http://localhost:8000/transactions \
  -H "Content-Type: application/json" \
  -d '{"amount": 50.0, "type": "expense", "category": "food", "date": "2026-05-02"}'
```

## Browser Check

Open `http://localhost:5173`

Expected: the page shows a list with your 2 transactions, each displaying date, category, type, and amount. Total count shows "2 transactions".

## Network Tab Check

1. Open DevTools (F12 or right-click → Inspect)
2. Go to the **Network** tab
3. Refresh the page
4. Find the request to `http://localhost:8000/transactions`
5. Click on it — Status should be **200**
6. The **Response** tab should show the JSON array

## Console Check

Open DevTools → **Console** tab.

Expected: No red errors. Specifically, no messages containing "CORS", "blocked", or "Failed to fetch".

## Empty State Check

Stop the backend, clear all transactions from the DB (or use a fresh DB), restart, then open the frontend.

Expected: Page shows "No transactions yet." (or similar) instead of crashing.

## Checklist

- [ ] Transaction list renders on page load with correct data
- [ ] Each transaction shows date, category, type, and amount
- [ ] Total count is displayed and matches the actual number of transactions
- [ ] Network tab shows `GET /transactions` with status 200
- [ ] No CORS errors in the console
- [ ] Empty state shows a message, not a blank page or error
