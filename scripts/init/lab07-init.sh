#!/bin/bash
# Lab 07 — Challenge: Month Filter + Edit Transaction
# Adds month filtering and PUT /transactions/{id}

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_DIR="$REPO_ROOT/budget-tracker"
BACKEND="$PROJECT_DIR/backend"
FRONTEND="$PROJECT_DIR/frontend"

echo "📦 Lab 07: Adding month filter + edit transaction..."

# Check if Lab 06 was completed
if [ ! -f "$BACKEND/routers/transactions.py" ]; then
    echo "❌ Lab 06 not completed. Run: bash $REPO_ROOT/scripts/init/lab06-init.sh"
    exit 1
fi

cd "$BACKEND"

# Update transactions router: add month filter + PUT
cat > routers/transactions.py << 'EOF'
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from schemas import TransactionCreate, TransactionResponse
from models import Transaction
from database import get_db

router = APIRouter(prefix="/transactions", tags=["transactions"])


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
    month: str | None = Query(default=None, description="YYYY-MM format"),
    db: Session = Depends(get_db),
) -> list[TransactionResponse]:
    query = db.query(Transaction)
    if category:
        query = query.filter(Transaction.category == category)
    if month:
        # date stored as string "YYYY-MM-DD", filter by prefix
        query = query.filter(Transaction.date.startswith(month))
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


@router.put("/{transaction_id}")
def update_transaction(
    transaction_id: int,
    transaction: TransactionCreate,
    db: Session = Depends(get_db),
) -> TransactionResponse:
    db_transaction = db.query(Transaction).filter(Transaction.id == transaction_id).first()
    if not db_transaction:
        raise HTTPException(status_code=404, detail="Transaction not found")
    for key, value in transaction.model_dump().items():
        setattr(db_transaction, key, value)
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
echo "✅ Updated routers/transactions.py (month filter + PUT)"

# Update frontend: month filter + inline edit
cd "$FRONTEND/src"

cat > TransactionList.jsx << 'EOF'
import { useState, useEffect } from 'react';

export default function TransactionList({ refreshKey, onMutate }) {
  const [transactions, setTransactions] = useState([]);
  const [summary, setSummary] = useState({ total_income: 0, total_expense: 0, balance: 0 });
  const [categoryFilter, setCategoryFilter] = useState('All');
  const [monthFilter, setMonthFilter] = useState('');
  const [editingId, setEditingId] = useState(null);
  const [editForm, setEditForm] = useState({});
  const [error, setError] = useState(null);

  const fetchAll = () => {
    fetch('http://localhost:8000/transactions')
      .then(res => res.json()).then(setTransactions);
    fetch('http://localhost:8000/transactions/summary')
      .then(res => res.json()).then(setSummary);
  };

  useEffect(() => { fetchAll(); }, [refreshKey]);

  const handleDelete = async (id) => {
    await fetch(`http://localhost:8000/transactions/${id}`, { method: 'DELETE' });
    fetchAll();
    if (onMutate) onMutate();
  };

  const startEdit = (t) => {
    setEditingId(t.id);
    setEditForm({ amount: t.amount, type: t.type, category: t.category, description: t.description, date: t.date });
  };

  const handleEditSubmit = async (id) => {
    await fetch(`http://localhost:8000/transactions/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ...editForm, amount: parseFloat(editForm.amount) }),
    });
    setEditingId(null);
    fetchAll();
  };

  const categories = ['All', ...new Set(transactions.map(t => t.category))];
  let filtered = transactions;
  if (categoryFilter !== 'All') filtered = filtered.filter(t => t.category === categoryFilter);
  if (monthFilter) filtered = filtered.filter(t => t.date.startsWith(monthFilter));

  if (error) return <p>Error: {error}</p>;

  return (
    <div>
      <div style={{ display: 'flex', gap: '24px', margin: '16px 0', padding: '12px', background: '#f5f5f5' }}>
        <span>Income: <strong>${summary.total_income}</strong></span>
        <span>Expenses: <strong>${summary.total_expense}</strong></span>
        <span>Balance: <strong style={{ color: summary.balance >= 0 ? 'green' : 'red' }}>${summary.balance}</strong></span>
      </div>

      <div style={{ display: 'flex', gap: '16px', marginBottom: '12px' }}>
        <label>Category:
          <select value={categoryFilter} onChange={e => setCategoryFilter(e.target.value)}>
            {categories.map(c => <option key={c}>{c}</option>)}
          </select>
        </label>
        <label>Month:
          <input type="month" value={monthFilter} onChange={e => setMonthFilter(e.target.value)} />
        </label>
        {monthFilter && <button onClick={() => setMonthFilter('')}>Clear month</button>}
      </div>

      {filtered.length === 0 ? <p>No transactions yet.</p> : (
        <ul style={{ listStyle: 'none', padding: 0 }}>
          {filtered.map(t => (
            <li key={t.id} style={{ marginBottom: '8px', padding: '8px', border: '1px solid #ddd' }}>
              {editingId === t.id ? (
                <span>
                  <input value={editForm.amount} onChange={e => setEditForm({...editForm, amount: e.target.value})} style={{ width: '80px' }} />
                  <select value={editForm.type} onChange={e => setEditForm({...editForm, type: e.target.value})}>
                    <option>income</option><option>expense</option>
                  </select>
                  <input value={editForm.category} onChange={e => setEditForm({...editForm, category: e.target.value})} placeholder="category" />
                  <input value={editForm.description} onChange={e => setEditForm({...editForm, description: e.target.value})} placeholder="description" />
                  <input type="date" value={editForm.date} onChange={e => setEditForm({...editForm, date: e.target.value})} />
                  <button onClick={() => handleEditSubmit(t.id)}>Save</button>
                  <button onClick={() => setEditingId(null)}>Cancel</button>
                </span>
              ) : (
                <span>
                  {t.date} — {t.category}: ${t.amount} ({t.type}){t.description && ` — ${t.description}`}
                  <button onClick={() => startEdit(t)} style={{ marginLeft: '8px' }}>Edit</button>
                  <button onClick={() => handleDelete(t.id)} style={{ marginLeft: '4px' }}>Delete</button>
                </span>
              )}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
EOF
echo "✅ Updated TransactionList.jsx (month filter + inline edit)"

echo ""
echo "✅ Lab 07 Complete!"
echo ""
echo "New endpoints:"
echo "  PUT /transactions/{id}    — update a transaction"
echo "  GET /transactions?month=2026-05  — filter by month"
echo "Test: http://localhost:5173"
