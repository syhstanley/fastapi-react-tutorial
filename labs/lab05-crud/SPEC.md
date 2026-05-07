# Lab 05 — Spec

## Backend

Add a new route to `backend/routers/transactions.py`:

**`DELETE /{transaction_id}`**
- Path parameter: `transaction_id` (integer)
- If no transaction with that id exists: return HTTP 404 with `{"detail": "Transaction not found"}`
- If found: delete it from the database and return HTTP 204 (no body)

## Frontend

### Add Transaction Form

Add a form to the page. It can be in `App.jsx` or a new file `TransactionForm.jsx` — your choice.

The form must have these fields:
- Amount — number input
- Type — select element with options `"income"` and `"expense"`
- Category — text input
- Description — text input (optional)
- Date — date input
- A submit button

On form submit:
- Send `POST http://localhost:8000/transactions` with the form data as JSON
- `amount` must be sent as a number (not a string)
- Clear all form fields on success
- Refresh the transaction list to show the new entry

### Delete Button

Add a Delete button to each row in the transaction list.

On click:
- Send `DELETE http://localhost:8000/transactions/{id}` where `{id}` is the transaction's id
- Remove the transaction from the displayed list on success

## Requirements

- After adding a transaction and refreshing the browser, the transaction is still there (persisted)
- After deleting a transaction and refreshing the browser, it is gone
- Deleting a non-existent id returns HTTP 404 from the backend
- The form must clear after a successful submit
- The list must update immediately after add or delete (without a manual browser refresh)
