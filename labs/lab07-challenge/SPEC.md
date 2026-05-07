# Lab 07 — Spec

## Feature 1: Month Filter

### Backend

Update `GET /transactions` to accept an optional query parameter `month` in `YYYY-MM` format (e.g. `2026-05`).

- If `month` is provided: return only transactions whose `date` falls within that calendar month
- `month` and `category` filters must work simultaneously when both are provided
- Existing behavior when `month` is not provided must be unchanged

### Frontend

Add a month filter to the UI.

- User can select or enter a month to filter by
- The displayed transaction list updates accordingly
- Month and category filters must work together
- There is a way to clear the month filter (show all months)

---

## Feature 2: Edit Transaction

### Backend

Add `PUT /transactions/{id}`:
- Accepts a full `TransactionCreate` request body
- Updates the transaction with the given `id` in the database
- Returns the updated transaction as `TransactionResponse`
- Returns HTTP 404 if no transaction with that `id` exists
- Must not change the `id` or `created_at` fields

### Frontend

Add an edit flow to the transaction list:
- Each row has a way to enter edit mode (e.g. an Edit button, or clicking the row)
- Entering edit mode shows a form pre-filled with the transaction's current values
- Submitting the form sends `PUT /transactions/{id}` with the updated values
- The list updates to reflect the changes immediately

---

## Requirements

- All existing functionality from Labs 01–06 must continue to work
- Edited transactions must persist after a browser refresh
- The `id` and `created_at` of edited transactions must remain unchanged
- Month and category filters must be combinable
