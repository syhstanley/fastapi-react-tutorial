# Lab 04 — Spec

## Backend

Add CORS middleware to `backend/main.py`:
- Allow requests from `http://localhost:5173`
- Allow all HTTP methods (`"*"`)
- Allow all headers (`"*"`)

Add it **before** `app.include_router(...)` calls.

## Frontend

### Create `frontend/src/TransactionList.jsx`

A component that:

1. Uses `useState` to store an array of transactions (initial value: `[]`)
2. Uses `useEffect` to fetch `GET http://localhost:8000/transactions` when the component mounts
3. Stores the fetched data in state
4. Renders a list showing, for each transaction:
   - Date
   - Category
   - Type (`income` or `expense`)
   - Amount
5. Shows the total count of transactions (e.g. `"3 transactions"`)
6. Shows a message like `"No transactions yet."` when the list is empty

### Update `frontend/src/App.jsx`

Import and render `<TransactionList />` so it appears on the main page.
You can remove the default Vite boilerplate (counter, logos) — replace it with your component.

## Requirements

- Data is fetched automatically on page load — no button needed
- The list renders correctly with 0, 1, or many transactions
- No CORS errors in the browser console
- The Network tab shows a successful request to `http://localhost:8000/transactions`
