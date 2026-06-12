#!/bin/bash
# Lab 06 — Summary Stats & Category Filter
# Adds /summary endpoint and category filter to transactions

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_DIR="$REPO_ROOT/budget-tracker"
BACKEND="$PROJECT_DIR/backend"
FRONTEND="$PROJECT_DIR/frontend"

echo "📦 Lab 06: Adding summary stats & category filter..."

# Check if Lab 05 was completed
if [ ! -f "$FRONTEND/src/TransactionForm.jsx" ]; then
    echo "❌ Lab 05 not completed. Run: bash $REPO_ROOT/scripts/init/lab05-init.sh"
    exit 1
fi

cd "$BACKEND"

# Update transactions router: add /summary + category filter
cat > routers/transactions.py << 'EOF'
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from schemas import TransactionCreate, TransactionResponse
from models import Transaction
from database import get_db

router = APIRouter(prefix="/transactions", tags=["transactions"])

# /summary MUST come before /{transaction_id} or FastAPI matches "summary" as an id
@router.get("/summary")
def get_summary(db: Session = Depends(get_db)):
    total_income = (
        db.query(func.sum(Transaction.amount))
        .filter(Transaction.type == "income")
        .scalar() or 0.0
    )
    total_expense = (
        db.query(func.sum(Transaction.amount))
        .filter(Transaction.type == "expense")
        .scalar() or 0.0
    )
    return {
        "total_income": round(total_income, 2),
        "total_expense": round(total_expense, 2),
        "balance": round(total_income - total_expense, 2),
    }


@router.get("/")
def get_transactions(
    category: str | None = Query(default=None),
    db: Session = Depends(get_db),
) -> list[TransactionResponse]:
    query = db.query(Transaction)
    if category:
        query = query.filter(Transaction.category == category)
    return [TransactionResponse.from_orm(t) for t in query.all()]


@router.post("/")
def create_transaction(
    transaction: TransactionCreate,
    db: Session = Depends(get_db),
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
echo "✅ Updated routers/transactions.py (summary + category filter)"

# Update TransactionList to show summary bar + category dropdown
cd "$FRONTEND/src"

cat > TransactionList.jsx << 'EOF'
import { useState, useEffect } from 'react';

export default function TransactionList({ refreshKey }) {
  const [transactions, setTransactions] = useState([]);
  const [summary, setSummary] = useState({ total_income: 0, total_expense: 0, balance: 0 });
  const [categoryFilter, setCategoryFilter] = useState('All');
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch('http://localhost:8000/transactions')
      .then(res => res.json())
      .then(setTransactions)
      .catch(err => setError(err.message));

    fetch('http://localhost:8000/transactions/summary')
      .then(res => res.json())
      .then(setSummary)
      .catch(err => setError(err.message));
  }, [refreshKey]);

  const handleDelete = async (id) => {
    await fetch(`http://localhost:8000/transactions/${id}`, { method: 'DELETE' });
    setTransactions(prev => prev.filter(t => t.id !== id));
    // Refresh summary
    fetch('http://localhost:8000/transactions/summary')
      .then(res => res.json())
      .then(setSummary);
  };

  const categories = ['All', ...new Set(transactions.map(t => t.category))];
  const filtered = categoryFilter === 'All'
    ? transactions
    : transactions.filter(t => t.category === categoryFilter);

  if (error) return <p>Error: {error}</p>;

  return (
    <div>
      <div style={{ display: 'flex', gap: '24px', margin: '16px 0', padding: '12px', background: '#f5f5f5' }}>
        <span>Income: <strong>${summary.total_income}</strong></span>
        <span>Expenses: <strong>${summary.total_expense}</strong></span>
        <span>Balance: <strong style={{ color: summary.balance >= 0 ? 'green' : 'red' }}>${summary.balance}</strong></span>
      </div>

      <div style={{ marginBottom: '12px' }}>
        <label>Filter by category: </label>
        <select value={categoryFilter} onChange={e => setCategoryFilter(e.target.value)}>
          {categories.map(c => <option key={c}>{c}</option>)}
        </select>
      </div>

      {filtered.length === 0 ? (
        <p>No transactions yet.</p>
      ) : (
        <ul>
          {filtered.map(t => (
            <li key={t.id}>
              {t.date} — {t.category}: ${t.amount} ({t.type})
              {t.description && ` — ${t.description}`}
              <button onClick={() => handleDelete(t.id)} style={{ marginLeft: '8px' }}>Delete</button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
EOF
echo "✅ Updated TransactionList.jsx (summary bar + category filter)"

echo ""
echo "✅ Lab 06 Complete!"
echo ""
echo "New API endpoint:  GET /transactions/summary"
echo "Updated endpoint:  GET /transactions?category=food"
echo "Test: http://localhost:5173"
