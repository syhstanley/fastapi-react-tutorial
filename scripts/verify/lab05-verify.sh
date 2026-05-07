#!/bin/bash
# Lab 05 Verification — Full CRUD (Add & Delete)

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKEND="$REPO_ROOT/budget-tracker/backend"
FRONTEND="$REPO_ROOT/budget-tracker/frontend"

echo "🔍 Verifying Lab 05..."

checks_passed=0
checks_total=0

# 1. Check TransactionForm.jsx exists
echo -n "Checking TransactionForm.jsx... "
if [ -f "$FRONTEND/src/TransactionForm.jsx" ]; then
    if grep -q "form" "$FRONTEND/src/TransactionForm.jsx" && \
       grep -q "POST" "$FRONTEND/src/TransactionForm.jsx"; then
        echo "✅"
        ((checks_passed++))
    else
        echo "❌ (invalid form)"
    fi
else
    echo "❌ (missing)"
fi
((checks_total++))

# 2. Check App.jsx includes TransactionForm
echo -n "Checking App.jsx includes TransactionForm... "
if grep -q "TransactionForm" "$FRONTEND/src/App.jsx"; then
    echo "✅"
    ((checks_passed++))
else
    echo "❌ (form not included)"
fi
((checks_total++))

# 3. Check TransactionList has delete button
echo -n "Checking delete functionality... "
if grep -q "DELETE\|delete\|handleDelete" "$FRONTEND/src/TransactionList.jsx"; then
    echo "✅"
    ((checks_passed++))
else
    echo "❌ (no delete button)"
fi
((checks_total++))

# 4. Check backend has DELETE endpoint
echo -n "Checking DELETE endpoint in backend... "
if grep -q "@router.delete" "$BACKEND/routers/transactions.py"; then
    echo "✅"
    ((checks_passed++))
else
    echo "❌ (DELETE endpoint missing)"
fi
((checks_total++))

# 5. Check form clears after submit
echo -n "Checking form reset after submit... "
if grep -q "setFormData" "$FRONTEND/src/TransactionForm.jsx" && \
   grep -q "formData.amount = ''" "$FRONTEND/src/TransactionForm.jsx"; then
    echo "✅"
    ((checks_passed++))
else
    echo "❌ (form not reset)"
fi
((checks_total++))

# 6. Check 404 handling for delete
echo -n "Checking 404 error handling... "
if grep -q "404\|not found" "$BACKEND/routers/transactions.py"; then
    echo "✅"
    ((checks_passed++))
else
    echo "❌ (no 404 handling)"
fi
((checks_total++))

echo ""
echo "Summary: $checks_passed/$checks_total checks passed"

if [ $checks_passed -eq $checks_total ]; then
    echo "✅ Lab 05 verification passed!"
    echo ""
    echo "Manual CRUD test:"
    echo "1. Terminal 1: cd $BACKEND && uv run uvicorn main:app --reload"
    echo "2. Terminal 2: cd $FRONTEND && npm run dev"
    echo "3. Visit http://localhost:5173"
    echo "4. Fill out form and submit"
    echo "5. Verify transaction appears in list"
    echo "6. Click delete button"
    echo "7. Verify transaction disappears"
    echo "8. Restart server"
    echo "9. Verify deletion persisted"
    exit 0
else
    echo "❌ Lab 05 verification failed. Check the errors above."
    exit 1
fi
