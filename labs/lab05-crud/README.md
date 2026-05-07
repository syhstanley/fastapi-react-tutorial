# Lab 05 — Full CRUD (Add & Delete)

## What You'll Learn
- How to build a controlled form in React
- How to make POST and DELETE requests from the frontend
- How to implement a DELETE endpoint in FastAPI
- How to refresh the UI after a mutation

## Background

### Controlled Forms in React

A "controlled" form means React state drives every input's value. When the user types, you update state. On submit, you read from state.

```jsx
const [amount, setAmount] = useState('')
const [category, setCategory] = useState('')

<input
  type="number"
  value={amount}
  onChange={(e) => setAmount(e.target.value)}
/>
```

This is different from "uncontrolled" forms where you read values from the DOM directly.

### Sending a POST request from React

```jsx
const handleSubmit = async (e) => {
  e.preventDefault()  // prevents the browser from reloading the page

  const response = await fetch('http://localhost:8000/transactions', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      amount: parseFloat(amount),  // convert string → number
      type,
      category,
      description,
      date,
    }),
  })

  if (response.ok) {
    // clear form and refresh list
  }
}
```

### Sending a DELETE request

```jsx
const handleDelete = async (id) => {
  await fetch(`http://localhost:8000/transactions/${id}`, {
    method: 'DELETE',
  })
  // refresh list
}
```

### DELETE Endpoint in FastAPI

```python
from fastapi import HTTPException

@router.delete("/{transaction_id}", status_code=204)
def delete_transaction(transaction_id: int, db: Session = Depends(get_db)):
    transaction = db.query(Transaction).filter(Transaction.id == transaction_id).first()
    if not transaction:
        raise HTTPException(status_code=404, detail="Transaction not found")
    db.delete(transaction)
    db.commit()
```

Status code 204 means "success, no content" — the response body is empty.

### Refreshing the UI After Mutations

The simplest approach: re-fetch the full list after every add or delete.

```jsx
const fetchTransactions = async () => {
  const res = await fetch('http://localhost:8000/transactions')
  setTransactions(await res.json())
}

// Call fetchTransactions() in useEffect (on mount) AND after each mutation
```

## Tips

- `e.preventDefault()` in the form submit handler is required — without it, the browser reloads the page
- `amount` from a form input is always a string. Convert it: `parseFloat(amount)` or `Number(amount)`
- The date input (`<input type="date" />`) gives you `"2026-05-01"` format — exactly what the API expects
- DELETE responses have no body (204 No Content) — don't call `.json()` on them
- After a successful delete, you can either re-fetch from server OR filter the item out of local state
