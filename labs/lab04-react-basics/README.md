# Lab 04 — React Basics & Fetching Data

## What You'll Learn
- How React components and JSX work
- How `useState` manages component data
- How `useEffect` triggers side effects like data fetching
- What CORS is and how to fix it in FastAPI

## Background

### React Components

A React component is a JavaScript function that returns JSX — an HTML-like syntax that React turns into DOM elements.

```jsx
function TransactionList() {
  return (
    <div>
      <h2>Transactions</h2>
      <p>Nothing here yet.</p>
    </div>
  )
}

export default TransactionList
```

Use it in another component like an HTML element: `<TransactionList />`

### useState

`useState` stores a value in the component. When the value changes, React re-renders the component with the new value.

```jsx
import { useState } from 'react'

function TransactionList() {
  const [transactions, setTransactions] = useState([])  // initial value is []

  // transactions = current value
  // setTransactions = function to update it
}
```

### useEffect

`useEffect` runs code after the component renders. The second argument (`[]`) controls when it runs:
- `[]` — run once when the component first appears (mounts)
- `[someValue]` — run whenever `someValue` changes
- no second argument — run after every render

```jsx
import { useState, useEffect } from 'react'

function TransactionList() {
  const [transactions, setTransactions] = useState([])

  useEffect(() => {
    fetch('http://localhost:8000/transactions')
      .then(res => res.json())
      .then(data => setTransactions(data))
  }, [])  // [] = run once on mount

  return <div>{transactions.length} transactions</div>
}
```

### CORS

Browsers enforce a security policy: a page at `http://localhost:5173` cannot make requests to `http://localhost:8000` unless the server explicitly allows it. This is called CORS (Cross-Origin Resource Sharing).

Without CORS configuration, you'll see this error in the browser console:
```
Access to fetch at 'http://localhost:8000/transactions' from origin
'http://localhost:5173' has been blocked by CORS policy
```

FastAPI provides middleware to fix this:

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_methods=["*"],
    allow_headers=["*"],
)
```

This must be added **before** `app.include_router(...)` calls.

## Project Structure After This Lab

```
frontend/
├── src/
│   ├── App.jsx              ← modified
│   └── TransactionList.jsx  ← new
└── ...
```

## Tips

- If you see "Failed to fetch" in the console: make sure the backend is running
- If you see a CORS error: check that `CORSMiddleware` is added in `main.py` before the routers
- JSX requires a single root element — wrap multiple elements in a `<div>` or `<>` (React Fragment)
- To render a list in JSX, use `.map()`:

```jsx
{transactions.map(t => (
  <div key={t.id}>{t.category}: {t.amount}</div>
))}
```

The `key` prop helps React track list items — use `t.id`.
