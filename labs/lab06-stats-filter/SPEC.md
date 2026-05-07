# Lab 06 — Spec

## Backend

### 1. New endpoint: `GET /transactions/summary`

Add this route to `backend/routers/transactions.py`. It must be defined **before** any route with a path parameter (e.g. `/{id}`), otherwise FastAPI will try to match "summary" as an id.

The endpoint returns:
```json
{
  "total_income": 0.0,
  "total_expense": 0.0,
  "balance": 0.0
}
```

Calculations:
- `total_income` = sum of `amount` for all transactions where `type == "income"` (default `0.0` if none)
- `total_expense` = sum of `amount` for all transactions where `type == "expense"` (default `0.0` if none)
- `balance` = `total_income - total_expense`

Use SQLAlchemy's `func.sum()` for the aggregation.

### 2. Category filter on `GET /transactions`

Update `GET /transactions` to accept an optional query parameter `category` (type `str`, default `None`).

- If `category` is provided: return only transactions where `category` exactly matches the parameter value
- If `category` is not provided: return all transactions (existing behavior unchanged)

## Frontend

### 1. Summary bar

Fetch `GET http://localhost:8000/transactions/summary` on page load and after every add or delete operation.

Display the three values somewhere visible on the page:
- Total Income
- Total Expense
- Balance

### 2. Category filter dropdown

Add a `<select>` element above the transaction list.

- Options: `"All"` as the first option, followed by each unique category from the current transaction list
- When a category is selected: display only transactions matching that category
- When `"All"` is selected: display all transactions
- The filtering is client-side — no new API call is needed when changing the filter

## Requirements

- Summary numbers update correctly when transactions are added or deleted
- `GET /transactions?category=food` returns only food transactions
- `GET /transactions?category=nonexistent` returns `[]`
- Category dropdown only shows categories that exist in the current transaction list
- Balance can be negative
