#!/bin/bash
# Lab 03 — SQLite + SQLAlchemy
# Replaces in-memory storage with persistent SQLite database

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_DIR="$REPO_ROOT/budget-tracker"
BACKEND="$PROJECT_DIR/backend"

echo "📦 Lab 03: Adding SQLite database persistence..."

# Check if Lab 02 was completed
if [ ! -f "$BACKEND/routers/transactions.py" ]; then
    echo "❌ Lab 02 not completed. Run: bash $REPO_ROOT/scripts/init/lab02-init.sh"
    exit 1
fi

cd "$BACKEND"

# Add SQLAlchemy dependency
echo "📦 Installing SQLAlchemy..."
uv add sqlalchemy

# Create database models
cat > models.py << 'EOF'
from sqlalchemy import Column, Integer, String, Float
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(Integer, primary_key=True, index=True)
    amount = Column(Float, nullable=False)
    type = Column(String, nullable=False)  # "income" or "expense"
    category = Column(String, nullable=False)
    description = Column(String, nullable=False)
    date = Column(String, nullable=False)
EOF

# Create database.py with SQLAlchemy session management
cat > database.py << 'EOF'
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
import os

# Create db directory if it doesn't exist
os.makedirs("db", exist_ok=True)

DATABASE_URL = "sqlite:///db/budget.db"
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
EOF

# Update main.py to initialize database tables
cat > main.py << 'EOF'
from fastapi import FastAPI
from routers.transactions import router
from database import engine
from models import Base

# Create all tables
Base.metadata.create_all(bind=engine)

app = FastAPI()
app.include_router(router)

@app.get("/health")
def health():
    return {"status": "ok"}
EOF

# Update transactions router to use database
cat > routers/transactions.py << 'EOF'
from fastapi import APIRouter, Depends
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
EOF

# Update schemas to support from_orm
cat > schemas.py << 'EOF'
from pydantic import BaseModel, ConfigDict
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

    model_config = ConfigDict(from_attributes=True)
EOF

# Create .gitignore for database file
cat > .gitignore << 'EOF'
.venv/
__pycache__/
*.pyc
.pytest_cache/
db/budget.db
.DS_Store
EOF

echo "✅ Lab 03 Complete!"
echo ""
echo "Changes made:"
echo "   - models.py (SQLAlchemy ORM model)"
echo "   - database.py (SQLAlchemy engine & session)"
echo "   - Updated main.py (creates tables on startup)"
echo "   - Updated routers/transactions.py (uses database)"
echo "   - .gitignore (ignores database file)"
echo ""
echo "Database file: $BACKEND/db/budget.db"
echo ""
echo "Data now persists across server restarts!"
echo "Test: Add a transaction, restart server, data should still exist."
