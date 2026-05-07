#!/bin/bash
# Lab 04 — React Basics & Fetching Data
# Creates React component to display transactions from API

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_DIR="$REPO_ROOT/budget-tracker"
BACKEND="$PROJECT_DIR/backend"
FRONTEND="$PROJECT_DIR/frontend"

echo "📦 Lab 04: Adding React frontend with data fetching..."

# Check if Lab 03 was completed
if [ ! -f "$BACKEND/database.py" ]; then
    echo "❌ Lab 03 not completed. Run: bash $REPO_ROOT/scripts/init/lab03-init.sh"
    exit 1
fi

cd "$BACKEND"

# Update main.py to enable CORS
cat > main.py << 'EOF'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers.transactions import router
from database import engine
from models import Base

# Create all tables
Base.metadata.create_all(bind=engine)

app = FastAPI()

# Enable CORS for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)

@app.get("/health")
def health():
    return {"status": "ok"}
EOF

# Create TransactionList component in frontend
cd "$FRONTEND/src"
cat > TransactionList.jsx << 'EOF'
import { useState, useEffect } from 'react';

export default function TransactionList() {
  const [transactions, setTransactions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch('http://localhost:8000/transactions')
      .then(res => res.json())
      .then(data => {
        setTransactions(data);
        setLoading(false);
      })
      .catch(err => {
        setError(err.message);
        setLoading(false);
      });
  }, []);

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Error: {error}</p>;
  if (transactions.length === 0) return <p>No transactions yet.</p>;

  return (
    <ul>
      {transactions.map(t => (
        <li key={t.id}>
          {t.date} - {t.category}: ${t.amount} ({t.type}) - {t.description}
        </li>
      ))}
    </ul>
  );
}
EOF

# Update App.jsx to include TransactionList
cat > App.jsx << 'EOF'
import TransactionList from './TransactionList';
import './App.css';

function App() {
  return (
    <div className="App">
      <h1>Budget Tracker</h1>
      <TransactionList />
    </div>
  );
}

export default App;
EOF

echo "✅ Lab 04 Complete!"
echo ""
echo "Changes made:"
echo "   - TransactionList.jsx (React component)"
echo "   - Updated App.jsx (includes TransactionList)"
echo "   - Updated main.py (CORS enabled)"
echo ""
echo "How to test:"
echo "1. Start backend: cd $BACKEND && uv run uvicorn main:app --reload"
echo "2. Start frontend: cd $FRONTEND && npm run dev"
echo "3. Add test data: curl -X POST http://localhost:8000/transactions \\\\
       -H 'Content-Type: application/json' \\\\
       -d '{\"amount\": 100, \"type\": \"income\", \"category\": \"Salary\", \"description\": \"Monthly pay\", \"date\": \"2024-01-15\"}'"
echo "4. Visit http://localhost:5173 - you should see transactions listed"
