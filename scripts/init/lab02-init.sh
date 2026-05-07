#!/bin/bash
# Lab 02 — FastAPI Routes & Pydantic Schemas
# Sets up in-memory transaction storage with basic API routes

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_DIR="$REPO_ROOT/budget-tracker"
BACKEND="$PROJECT_DIR/backend"

echo "📦 Lab 02: Adding FastAPI routes and schemas..."

# Check if Lab 01 was completed
if [ ! -f "$BACKEND/main.py" ]; then
    echo "❌ Lab 01 not completed. Run: bash $REPO_ROOT/scripts/init/lab01-init.sh"
    exit 1
fi

cd "$BACKEND"

# Create schemas.py with Pydantic models
cat > schemas.py << 'EOF'
from pydantic import BaseModel
from typing import Literal

class TransactionBase(BaseModel):
    amount: float
    type: Literal["income", "expense"]
    category: str
    description: str
    date: str

class TransactionCreate(TransactionBase):
    pass

class TransactionResponse(TransactionBase):
    id: int

    class Config:
        from_attributes = True
EOF

# Create routers directory
mkdir -p routers
cat > routers/__init__.py << 'EOF'
EOF

# Create transactions router
cat > routers/transactions.py << 'EOF'
from fastapi import APIRouter
from schemas import TransactionCreate, TransactionResponse

router = APIRouter(prefix="/transactions", tags=["transactions"])

# In-memory storage (will be replaced with database in Lab 03)
transactions: list[dict] = []
next_id = 1

@router.get("/")
def get_transactions() -> list[TransactionResponse]:
    return [TransactionResponse(**t) for t in transactions]

@router.post("/")
def create_transaction(transaction: TransactionCreate) -> TransactionResponse:
    global next_id
    new_transaction = {
        "id": next_id,
        **transaction.model_dump()
    }
    transactions.append(new_transaction)
    next_id += 1
    return TransactionResponse(**new_transaction)
EOF

# Update main.py to include the router
cat > main.py << 'EOF'
from fastapi import FastAPI
from routers.transactions import router

app = FastAPI()
app.include_router(router)

@app.get("/health")
def health():
    return {"status": "ok"}
EOF

echo "✅ Lab 02 Complete!"
echo ""
echo "Files created:"
echo "   - schemas.py (Pydantic models)"
echo "   - routers/transactions.py (API routes)"
echo "   - Updated main.py"
echo ""
echo "API endpoints:"
echo "   - GET /transactions"
echo "   - POST /transactions"
echo "   - GET /health"
echo ""
echo "Test with:"
echo "   curl http://localhost:8000/docs"
