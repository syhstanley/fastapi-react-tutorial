#!/bin/bash
# Lab 08 — New Feature: Budget Limits (separate router)
# Adds budget limits with their own router, extends summary

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_DIR="$REPO_ROOT/budget-tracker"
BACKEND="$PROJECT_DIR/backend"

echo "📦 Lab 08: Adding budget limits feature..."

# Check if Lab 07 was completed
if [ ! -f "$BACKEND/routers/transactions.py" ]; then
    echo "❌ Lab 07 not completed. Run: bash $REPO_ROOT/scripts/init/lab07-init.sh"
    exit 1
fi

cd "$BACKEND"

# Add BudgetLimit model to models.py
cat > models.py << 'EOF'
from sqlalchemy import Column, Integer, String, Float, DateTime
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime

Base = declarative_base()


class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(Integer, primary_key=True, index=True)
    amount = Column(Float, nullable=False)
    type = Column(String, nullable=False)
    category = Column(String, nullable=False)
    description = Column(String, nullable=False)
    date = Column(String, nullable=False)


class BudgetLimit(Base):
    __tablename__ = "budget_limits"

    id = Column(Integer, primary_key=True, index=True)
    category = Column(String, nullable=False, unique=True)
    monthly_limit = Column(Float, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
EOF
echo "✅ Updated models.py (added BudgetLimit)"

# Create budgets schema
cat >> schemas.py << 'EOF'


class BudgetLimitCreate(BaseModel):
    category: str
    monthly_limit: float


class BudgetLimitResponse(BudgetLimitCreate):
    id: int
    created_at: str

    model_config = ConfigDict(from_attributes=True)
EOF
echo "✅ Updated schemas.py (BudgetLimit schemas)"

# Create routers/budgets.py
cat > routers/budgets.py << 'EOF'
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from schemas import BudgetLimitCreate, BudgetLimitResponse
from models import BudgetLimit
from database import get_db

router = APIRouter(prefix="/budgets", tags=["budgets"])


@router.get("/")
def get_budgets(db: Session = Depends(get_db)) -> list[BudgetLimitResponse]:
    budgets = db.query(BudgetLimit).all()
    return [
        BudgetLimitResponse(
            id=b.id, category=b.category, monthly_limit=b.monthly_limit,
            created_at=str(b.created_at)
        )
        for b in budgets
    ]


@router.post("/", status_code=201)
def create_budget(budget: BudgetLimitCreate, db: Session = Depends(get_db)):
    existing = db.query(BudgetLimit).filter(BudgetLimit.category == budget.category).first()
    if existing:
        raise HTTPException(status_code=409, detail="Budget for this category already exists")
    db_budget = BudgetLimit(**budget.model_dump())
    db.add(db_budget)
    db.commit()
    db.refresh(db_budget)
    return BudgetLimitResponse(
        id=db_budget.id, category=db_budget.category,
        monthly_limit=db_budget.monthly_limit, created_at=str(db_budget.created_at)
    )


@router.put("/{budget_id}")
def update_budget(
    budget_id: int, budget: BudgetLimitCreate, db: Session = Depends(get_db)
):
    db_budget = db.query(BudgetLimit).filter(BudgetLimit.id == budget_id).first()
    if not db_budget:
        raise HTTPException(status_code=404, detail="Budget not found")
    db_budget.category = budget.category
    db_budget.monthly_limit = budget.monthly_limit
    db.commit()
    db.refresh(db_budget)
    return BudgetLimitResponse(
        id=db_budget.id, category=db_budget.category,
        monthly_limit=db_budget.monthly_limit, created_at=str(db_budget.created_at)
    )


@router.delete("/{budget_id}", status_code=204)
def delete_budget(budget_id: int, db: Session = Depends(get_db)):
    db_budget = db.query(BudgetLimit).filter(BudgetLimit.id == budget_id).first()
    if not db_budget:
        raise HTTPException(status_code=404, detail="Budget not found")
    db.delete(db_budget)
    db.commit()
EOF
echo "✅ Created routers/budgets.py"

# Update main.py to include budgets router
cat > main.py << 'EOF'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers.transactions import router as transactions_router
from routers.budgets import router as budgets_router
from database import engine
from models import Base

Base.metadata.create_all(bind=engine)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(transactions_router)
app.include_router(budgets_router)

@app.get("/health")
def health():
    return {"status": "ok"}
EOF
echo "✅ Updated main.py (mounted budgets router)"

# Update summary to include budget info for current month
cat > routers/transactions.py << 'EOF'
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from schemas import TransactionCreate, TransactionResponse
from models import Transaction, BudgetLimit
from database import get_db
from datetime import date

router = APIRouter(prefix="/transactions", tags=["transactions"])


@router.get("/summary")
def get_summary(db: Session = Depends(get_db)):
    total_income = (
        db.query(func.sum(Transaction.amount))
        .filter(Transaction.type == "income").scalar() or 0.0
    )
    total_expense = (
        db.query(func.sum(Transaction.amount))
        .filter(Transaction.type == "expense").scalar() or 0.0
    )

    # Per-category spending this month vs budget
    current_month = date.today().strftime("%Y-%m")
    budgets = db.query(BudgetLimit).all()
    budget_info = []
    for b in budgets:
        spent = (
            db.query(func.sum(Transaction.amount))
            .filter(
                Transaction.category == b.category,
                Transaction.type == "expense",
                Transaction.date.startswith(current_month),
            )
            .scalar() or 0.0
        )
        budget_info.append({
            "category": b.category,
            "monthly_limit": b.monthly_limit,
            "spent_this_month": round(spent, 2),
        })

    return {
        "total_income": round(total_income, 2),
        "total_expense": round(total_expense, 2),
        "balance": round(total_income - total_expense, 2),
        "budget_status": budget_info,
    }


@router.get("/")
def get_transactions(
    category: str | None = Query(default=None),
    month: str | None = Query(default=None),
    db: Session = Depends(get_db),
) -> list[TransactionResponse]:
    query = db.query(Transaction)
    if category:
        query = query.filter(Transaction.category == category)
    if month:
        query = query.filter(Transaction.date.startswith(month))
    return [TransactionResponse.from_orm(t) for t in query.all()]


@router.post("/")
def create_transaction(
    transaction: TransactionCreate, db: Session = Depends(get_db)
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
echo "✅ Updated routers/transactions.py (summary includes budget_status)"

echo ""
echo "✅ Lab 08 Complete!"
echo ""
echo "New endpoints:"
echo "  GET    /budgets/"
echo "  POST   /budgets/"
echo "  PUT    /budgets/{id}"
echo "  DELETE /budgets/{id}"
echo "  GET    /transactions/summary  (now includes budget_status)"
echo ""
echo "Test: http://localhost:8000/docs"
