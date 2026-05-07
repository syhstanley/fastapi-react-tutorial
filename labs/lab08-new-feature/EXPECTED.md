# Lab 08 — Expected Results

## Swagger UI

Open `http://localhost:8000/docs`.

Expected: Two distinct groups of endpoints are visible — one for `transactions` (from previous labs) and one for your new budget-related endpoints.

## Budget CRUD

The exact API paths are yours to design. Verify that all four operations work:

**Create a budget limit:**
Send a POST request to your budget endpoint with a category and a monthly limit amount.
Expected: Returns the created budget object with an auto-assigned id.

**List all budgets:**
Send a GET request to your budget endpoint.
Expected: Returns an array of all budget limits.

**Update a budget:**
Send a PUT request with a budget id. Change the monthly limit amount.
Expected: Returns the updated budget object.

**Delete a budget:**
Send a DELETE request with a budget id.
Expected: HTTP 204, no body.

## Extended Summary

After setting a budget limit for "food" ($500) and having $80 of food expenses this month:

```bash
curl http://localhost:8000/transactions/summary
```

Expected response structure (exact field names are your design choice):
```json
{
  "total_income": 3000.0,
  "total_expense": 1080.0,
  "balance": 1920.0,
  "budgets": [
    {
      "category": "food",
      "monthly_limit": 500.0,
      "current_month_spending": 80.0
    }
  ]
}
```

## Persistence Check

Add a budget limit, restart the server, then list budgets.
Expected: the budget limit is still there.

## Regression Check

All endpoints from Labs 01–07 must still work correctly:

- [ ] `GET /transactions` returns transactions
- [ ] `POST /transactions` creates a transaction
- [ ] `DELETE /transactions/{id}` deletes a transaction
- [ ] `PUT /transactions/{id}` updates a transaction
- [ ] `GET /transactions/summary` returns totals (now extended with budget info)
- [ ] Category filter (`?category=`) still works
- [ ] Month filter (`?month=`) still works

## Checklist

- [ ] Swagger UI shows two separate router groups
- [ ] Can create a budget limit via API
- [ ] Can list all budget limits
- [ ] Can update a budget limit
- [ ] Can delete a budget limit (204)
- [ ] `GET /transactions/summary` includes budget vs. actual spending data
- [ ] Budget data persists after server restart
- [ ] All Lab 01–07 functionality still works
