#!/bin/bash
# Lab 05 — Full CRUD (Add & Delete)
# Adds form for creating transactions and delete buttons

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_DIR="$REPO_ROOT/budget-tracker"
BACKEND="$PROJECT_DIR/backend"
FRONTEND="$PROJECT_DIR/frontend"

echo "📦 Lab 05: Adding full CRUD operations..."

# Check if Lab 04 was completed
if [ ! -f "$FRONTEND/src/TransactionList.jsx" ]; then
    echo "❌ Lab 04 not completed. Run: bash $REPO_ROOT/scripts/init/lab04-init.sh"
    exit 1
fi

cd "$BACKEND"

# Update transactions router to include DELETE endpoint
cat > routers/transactions.py << 'EOF'
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from schemas import TransactionCreate, TransactionResponse
from models import Transaction
from database import get_db

router = APIRouter(prefix="/transactions", tags=["transactions"])

@router.get("/")
def get_transactions(db: Session = Depends(get_db)) -> list[TransactionResponse]:
    transactions = db.query(Transaction).all()
    return [TransactionResponse.from_orm(t) for t in transactions]

@router.post("/")
def create_transaction(
    transaction: TransactionCreate,
    db: Session = Depends(get_db)
) -> TransactionResponse:
    db_transaction = Transaction(**transaction.model_dump())
    db.add(db_transaction)
    db.commit()
    db.refresh(db_transaction)
    return TransactionResponse.from_orm(db_transaction)

@router.delete("/{transaction_id}")
def delete_transaction(transaction_id: int, db: Session = Depends(get_db)):
    transaction = db.query(Transaction).filter(Transaction.id == transaction_id).first()
    if not transaction:
        raise HTTPException(status_code=404, detail="Transaction not found")
    db.delete(transaction)
    db.commit()
    return {"message": "Transaction deleted"}
EOF

echo "✅ Backend updated with DELETE endpoint"

cd "$FRONTEND/src"

# Update TransactionList.jsx to include delete button and refresh
cat > TransactionList.jsx << 'EOF'
import { useState, useEffect } from 'react';

export default function TransactionList() {
  const [transactions, setTransactions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchTransactions = async () => {
    try {
      const res = await fetch('http://localhost:8000/transactions');
      const data = await res.json();
      setTransactions(data);
      setError(null);
    } catch (err) {
      setError(err.message);
    }
  };

  useEffect(() => {
    fetchTransactions();
  }, []);

  const handleDelete = async (id) => {
    try {
      await fetch(`http://localhost:8000/transactions/${id}`, {
        method: 'DELETE',
      });
      setTransactions(transactions.filter(t => t.id !== id));
    } catch (err) {
      setError(err.message);
    }
  };

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Error: {error}</p>;
  if (transactions.length === 0) return <p>No transactions yet.</p>;

  return (
    <ul>
      {transactions.map(t => (
        <li key={t.id}>
          {t.date} - {t.category}: ${t.amount} ({t.type}) - {t.description}
          <button onClick={() => handleDelete(t.id)}>Delete</button>
        </li>
      ))}
    </ul>
  );
}
EOF

# Create TransactionForm component
cat > TransactionForm.jsx << 'EOF'
import { useState } from 'react';

export default function TransactionForm({ onTransactionAdded }) {
  const [formData, setFormData] = useState({
    amount: '',
    type: 'expense',
    category: '',
    description: '',
    date: new Date().toISOString().split('T')[0],
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      const res = await fetch('http://localhost:8000/transactions', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          ...formData,
          amount: parseFloat(formData.amount),
        }),
      });

      if (!res.ok) throw new Error('Failed to add transaction');

      const newTransaction = await res.json();
      onTransactionAdded(newTransaction);

      // Clear form
      setFormData({
        amount: '',
        type: 'expense',
        category: '',
        description: '',
        date: new Date().toISOString().split('T')[0],
      });
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <div>
        <label>Amount: </label>
        <input
          type="number"
          step="0.01"
          name="amount"
          value={formData.amount}
          onChange={handleChange}
          required
        />
      </div>
      <div>
        <label>Type: </label>
        <select name="type" value={formData.type} onChange={handleChange}>
          <option value="income">Income</option>
          <option value="expense">Expense</option>
        </select>
      </div>
      <div>
        <label>Category: </label>
        <input
          type="text"
          name="category"
          value={formData.category}
          onChange={handleChange}
          required
        />
      </div>
      <div>
        <label>Description: </label>
        <input
          type="text"
          name="description"
          value={formData.description}
          onChange={handleChange}
          required
        />
      </div>
      <div>
        <label>Date: </label>
        <input
          type="date"
          name="date"
          value={formData.date}
          onChange={handleChange}
          required
        />
      </div>
      <button type="submit" disabled={loading}>
        {loading ? 'Adding...' : 'Add Transaction'}
      </button>
      {error && <p style={{ color: 'red' }}>{error}</p>}
    </form>
  );
}
EOF

# Update App.jsx to include form
cat > App.jsx << 'EOF'
import { useState } from 'react';
import TransactionForm from './TransactionForm';
import TransactionList from './TransactionList';
import './App.css';

function App() {
  const [refreshKey, setRefreshKey] = useState(0);

  const handleTransactionAdded = (newTransaction) => {
    // Trigger re-render of TransactionList
    setRefreshKey(prev => prev + 1);
  };

  return (
    <div className="App">
      <h1>Budget Tracker</h1>
      <TransactionForm onTransactionAdded={handleTransactionAdded} />
      <h2>Transactions</h2>
      <TransactionList key={refreshKey} />
    </div>
  );
}

export default App;
EOF

echo "✅ Lab 05 Complete!"
echo ""
echo "Changes made:"
echo "   - TransactionForm.jsx (form to add transactions)"
echo "   - Updated TransactionList.jsx (added delete button)"
echo "   - Updated App.jsx (integrated form)"
echo "   - Updated backend routers/transactions.py (DELETE endpoint)"
echo ""
echo "Features:"
echo "   - Create new transactions"
echo "   - Delete transactions"
echo "   - Form clears after submission"
echo "   - List updates immediately without page refresh"
echo ""
echo "Test: http://localhost:5173"
