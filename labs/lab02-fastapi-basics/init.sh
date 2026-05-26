#!/usr/bin/env bash
set -e

echo "=== Lab 02: FastAPI Routes & Pydantic Schemas ==="
echo ""

BACKEND="${1:-budget-tracker/backend}"

if [ ! -d "$BACKEND" ]; then
  echo "Error: backend directory not found at $BACKEND"
  echo "Usage: ./init.sh [path/to/backend]"
  echo "Make sure you completed Lab 01 first."
  exit 1
fi

# Write schemas.py (given file)
cat > "$BACKEND/schemas.py" << 'EOF'
from pydantic import BaseModel
from datetime import date
from enum import Enum


class TransactionType(str, Enum):
    income = "income"
    expense = "expense"


class TransactionCreate(BaseModel):
    amount: float
    type: TransactionType
    category: str
    description: str = ""
    date: date


class TransactionResponse(TransactionCreate):
    id: int

    class Config:
        from_attributes = True
EOF
echo "✅ Created $BACKEND/schemas.py (given — do not modify)"

# Create routers package
mkdir -p "$BACKEND/routers"
touch "$BACKEND/routers/__init__.py"
echo "✅ Created $BACKEND/routers/__init__.py"

echo ""
echo "Next steps:"
echo "  1. Create $BACKEND/routers/transactions.py"
echo "     - GET /  → returns list[TransactionResponse]"
echo "     - POST / → accepts TransactionCreate, returns TransactionResponse with id"
echo "     - Use a module-level list for in-memory storage"
echo "  2. Update $BACKEND/main.py to mount the router at prefix='/transactions'"
echo ""
echo "Run ./check.sh when the server is running."
