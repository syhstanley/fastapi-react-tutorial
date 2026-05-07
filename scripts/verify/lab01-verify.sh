#!/bin/bash
# Lab 01 Verification — Environment Setup & Hello World

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_DIR="$REPO_ROOT/budget-tracker"
BACKEND="$PROJECT_DIR/backend"
FRONTEND="$PROJECT_DIR/frontend"

echo "🔍 Verifying Lab 01..."

# Check list
checks_passed=0
checks_total=5

# 1. Backend directory exists
if [ -d "$BACKEND" ]; then
    echo "✅ backend/ directory exists"
    ((checks_passed++))
else
    echo "❌ backend/ directory missing"
fi
((checks_total++))

# 2. Frontend directory exists
if [ -d "$FRONTEND" ]; then
    echo "✅ frontend/ directory exists"
    ((checks_passed++))
else
    echo "❌ frontend/ directory missing"
fi
((checks_total++))

# 3. pyproject.toml exists
if [ -f "$BACKEND/pyproject.toml" ]; then
    echo "✅ backend/pyproject.toml exists"
    ((checks_passed++))
else
    echo "❌ backend/pyproject.toml missing"
fi
((checks_total++))

# 4. main.py exists with FastAPI app
if [ -f "$BACKEND/main.py" ]; then
    if grep -q "FastAPI" "$BACKEND/main.py" && grep -q "app = " "$BACKEND/main.py"; then
        echo "✅ backend/main.py contains FastAPI app"
        ((checks_passed++))
    else
        echo "❌ backend/main.py doesn't contain FastAPI app"
    fi
else
    echo "❌ backend/main.py missing"
fi
((checks_total++))

# 5. package.json exists in frontend
if [ -f "$FRONTEND/package.json" ]; then
    echo "✅ frontend/package.json exists"
    ((checks_passed++))
else
    echo "❌ frontend/package.json missing"
fi
((checks_total++))

echo ""
echo "Summary: $checks_passed/$checks_total checks passed"

if [ $checks_passed -eq $checks_total ]; then
    echo "✅ Lab 01 verification passed!"
    echo ""
    echo "Next steps:"
    echo "1. Terminal 1: cd $BACKEND && uv run uvicorn main:app --reload"
    echo "2. Terminal 2: cd $FRONTEND && npm run dev"
    echo "3. Visit http://localhost:5173 and http://localhost:8000/docs"
    exit 0
else
    echo "❌ Lab 01 verification failed. Check the errors above."
    exit 1
fi
