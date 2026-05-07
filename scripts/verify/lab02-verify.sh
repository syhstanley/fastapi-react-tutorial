#!/bin/bash
# Lab 02 Verification — FastAPI Routes & Pydantic Schemas

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKEND="$REPO_ROOT/budget-tracker/backend"

echo "🔍 Verifying Lab 02..."

checks_passed=0
checks_total=0

# 1. Check schemas.py exists
echo -n "Checking schemas.py... "
if [ -f "$BACKEND/schemas.py" ]; then
    if grep -q "class TransactionBase" "$BACKEND/schemas.py" && \
       grep -q "class TransactionResponse" "$BACKEND/schemas.py"; then
        echo "✅"
        ((checks_passed++))
    else
        echo "❌ (missing required classes)"
    fi
else
    echo "❌ (missing)"
fi
((checks_total++))

# 2. Check routers/transactions.py exists
echo -n "Checking routers/transactions.py... "
if [ -f "$BACKEND/routers/transactions.py" ]; then
    if grep -q "@router.get" "$BACKEND/routers/transactions.py" && \
       grep -q "@router.post" "$BACKEND/routers/transactions.py"; then
        echo "✅"
        ((checks_passed++))
    else
        echo "❌ (missing GET/POST routes)"
    fi
else
    echo "❌ (missing)"
fi
((checks_total++))

# 3. Check main.py includes router
echo -n "Checking main.py includes router... "
if grep -q "include_router" "$BACKEND/main.py"; then
    echo "✅"
    ((checks_passed++))
else
    echo "❌ (router not included)"
fi
((checks_total++))

# 4. Check for /transactions endpoint
echo -n "Checking /transactions endpoint... "
if grep -q 'prefix="/transactions"' "$BACKEND/routers/transactions.py"; then
    echo "✅"
    ((checks_passed++))
else
    echo "❌ (endpoint not found)"
fi
((checks_total++))

echo ""
echo "Summary: $checks_passed/$checks_total checks passed"

if [ $checks_passed -eq $checks_total ]; then
    echo "✅ Lab 02 verification passed!"
    echo ""
    echo "Manual test (requires server running):"
    echo "  curl http://localhost:8000/docs          # View Swagger UI"
    echo "  curl http://localhost:8000/transactions  # Test GET"
    echo "  curl -X POST http://localhost:8000/transactions \\"
    echo "    -H 'Content-Type: application/json' \\"
    echo '    -d '"'"'{"amount": 100, "type": "income", "category": "Test", "description": "Test", "date": "2024-01-01"}'"'"
    exit 0
else
    echo "❌ Lab 02 verification failed. Check the errors above."
    exit 1
fi
