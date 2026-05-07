#!/bin/bash
# Lab 04 Verification — React Basics & Fetching Data

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKEND="$REPO_ROOT/budget-tracker/backend"
FRONTEND="$REPO_ROOT/budget-tracker/frontend"

echo "🔍 Verifying Lab 04..."

checks_passed=0
checks_total=0

# 1. Check TransactionList.jsx exists
echo -n "Checking TransactionList.jsx... "
if [ -f "$FRONTEND/src/TransactionList.jsx" ]; then
    if grep -q "useState" "$FRONTEND/src/TransactionList.jsx" && \
       grep -q "useEffect" "$FRONTEND/src/TransactionList.jsx"; then
        echo "✅"
        ((checks_passed++))
    else
        echo "❌ (missing hooks)"
    fi
else
    echo "❌ (missing)"
fi
((checks_total++))

# 2. Check fetch to /transactions
echo -n "Checking fetch to /transactions... "
if grep -q "fetch.*transactions" "$FRONTEND/src/TransactionList.jsx"; then
    echo "✅"
    ((checks_passed++))
else
    echo "❌ (not fetching transactions)"
fi
((checks_total++))

# 3. Check App.jsx imports TransactionList
echo -n "Checking App.jsx includes TransactionList... "
if grep -q "TransactionList" "$FRONTEND/src/App.jsx"; then
    echo "✅"
    ((checks_passed++))
else
    echo "❌ (not imported)"
fi
((checks_total++))

# 4. Check CORS is enabled in backend
echo -n "Checking CORS in backend... "
if grep -q "CORSMiddleware" "$BACKEND/main.py"; then
    echo "✅"
    ((checks_passed++))
else
    echo "❌ (CORS not configured)"
fi
((checks_total++))

# 5. Check handling of empty transactions
echo -n "Checking empty state handling... "
if grep -q "No transactions" "$FRONTEND/src/TransactionList.jsx"; then
    echo "✅"
    ((checks_passed++))
else
    echo "❌ (no empty state)"
fi
((checks_total++))

echo ""
echo "Summary: $checks_passed/$checks_total checks passed"

if [ $checks_passed -eq $checks_total ]; then
    echo "✅ Lab 04 verification passed!"
    echo ""
    echo "Manual integration test:"
    echo "1. Terminal 1: cd $BACKEND && uv run uvicorn main:app --reload"
    echo "2. Terminal 2: cd $FRONTEND && npm run dev"
    echo "3. Add test data:"
    echo '   curl -X POST http://localhost:8000/transactions \'
    echo "     -H 'Content-Type: application/json' \\"
    echo '     -d '"'"'{"amount": 50, "type": "expense", "category": "Food", "description": "Lunch", "date": "2024-01-15"}'"'"
    echo "4. Visit http://localhost:5173"
    echo "5. Verify transaction appears in list (check Network tab for API calls)"
    exit 0
else
    echo "❌ Lab 04 verification failed. Check the errors above."
    exit 1
fi
