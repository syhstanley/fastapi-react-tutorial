#!/bin/bash
# Lab 03 Verification — SQLite + SQLAlchemy

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKEND="$REPO_ROOT/budget-tracker/backend"

echo "🔍 Verifying Lab 03..."

checks_passed=0
checks_total=0

# 1. Check models.py exists
echo -n "Checking models.py... "
if [ -f "$BACKEND/models.py" ]; then
    if grep -q "class Transaction" "$BACKEND/models.py" && \
       grep -q "__tablename__" "$BACKEND/models.py"; then
        echo "✅"
        ((checks_passed++))
    else
        echo "❌ (invalid model)"
    fi
else
    echo "❌ (missing)"
fi
((checks_total++))

# 2. Check database.py exists
echo -n "Checking database.py... "
if [ -f "$BACKEND/database.py" ]; then
    if grep -q "create_engine" "$BACKEND/database.py" && \
       grep -q "SessionLocal" "$BACKEND/database.py"; then
        echo "✅"
        ((checks_passed++))
    else
        echo "❌ (invalid setup)"
    fi
else
    echo "❌ (missing)"
fi
((checks_total++))

# 3. Check main.py creates tables
echo -n "Checking main.py creates tables... "
if grep -q "Base.metadata.create_all" "$BACKEND/main.py"; then
    echo "✅"
    ((checks_passed++))
else
    echo "❌ (no table creation)"
fi
((checks_total++))

# 4. Check .gitignore excludes db
echo -n "Checking .gitignore for db/... "
if [ -f "$BACKEND/.gitignore" ] && grep -q "db/" "$BACKEND/.gitignore"; then
    echo "✅"
    ((checks_passed++))
else
    echo "❌ (not properly configured)"
fi
((checks_total++))

# 5. Check routers use database dependency
echo -n "Checking routers use database... "
if grep -q "Depends(get_db)" "$BACKEND/routers/transactions.py"; then
    echo "✅"
    ((checks_passed++))
else
    echo "❌ (not using database)"
fi
((checks_total++))

echo ""
echo "Summary: $checks_passed/$checks_total checks passed"

if [ $checks_passed -eq $checks_total ]; then
    echo "✅ Lab 03 verification passed!"
    echo ""
    echo "Manual persistence test (requires server running):"
    echo "1. Start server: cd $BACKEND && uv run uvicorn main:app --reload"
    echo "2. Add transaction:"
    echo '   curl -X POST http://localhost:8000/transactions \'
    echo "     -H 'Content-Type: application/json' \\"
    echo '     -d '"'"'{"amount": 100, "type": "income", "category": "Test", "description": "Test", "date": "2024-01-01"}'"'"
    echo "3. Restart server (Ctrl+C, then re-run)"
    echo "4. Verify transaction still exists:"
    echo "   curl http://localhost:8000/transactions"
    echo "5. Check database file:"
    echo "   ls -la $BACKEND/db/budget.db"
    exit 0
else
    echo "❌ Lab 03 verification failed. Check the errors above."
    exit 1
fi
