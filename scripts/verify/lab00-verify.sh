#!/bin/bash
# Lab 00 Verification — FastAPI Fundamentals Reference

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LAB_DIR="$REPO_ROOT/labs/lab00-fastapi-fundamentals"

echo "🔍 Verifying Lab 00..."
echo ""

checks_passed=0
checks_total=0

# 1. Check files exist
echo -n "Checking README.md... "
if [ -f "$LAB_DIR/README.md" ]; then
    echo "✅"
    ((checks_passed++))
else
    echo "❌"
fi
((checks_total++))

echo -n "Checking SPEC.md... "
if [ -f "$LAB_DIR/SPEC.md" ]; then
    echo "✅"
    ((checks_passed++))
else
    echo "❌"
fi
((checks_total++))

echo -n "Checking EXPECTED.md... "
if [ -f "$LAB_DIR/EXPECTED.md" ]; then
    echo "✅"
    ((checks_passed++))
else
    echo "❌"
fi
((checks_total++))

echo -n "Checking examples.py... "
if [ -f "$LAB_DIR/examples.py" ]; then
    # Verify it has key examples
    if grep -q "@app.get" "$LAB_DIR/examples.py" && \
       grep -q "@app.post" "$LAB_DIR/examples.py" && \
       grep -q "@app.delete" "$LAB_DIR/examples.py"; then
        echo "✅"
        ((checks_passed++))
    else
        echo "❌ (missing examples)"
    fi
else
    echo "❌"
fi
((checks_total++))

# 2. Check content quality
echo -n "Checking README.md covers decorators... "
if grep -q "HTTP Method Decorators" "$LAB_DIR/README.md"; then
    echo "✅"
    ((checks_passed++))
else
    echo "❌"
fi
((checks_total++))

echo -n "Checking README.md has documentation links... "
if grep -q "Documentation Links\|official FastAPI" "$LAB_DIR/README.md"; then
    echo "✅"
    ((checks_passed++))
else
    echo "❌"
fi
((checks_total++))

echo -n "Checking examples.py has docstrings... "
if grep -q '"""' "$LAB_DIR/examples.py"; then
    echo "✅"
    ((checks_passed++))
else
    echo "❌"
fi
((checks_total++))

echo ""
echo "Summary: $checks_passed/$checks_total checks passed"
echo ""

if [ $checks_passed -eq $checks_total ]; then
    echo "✅ Lab 00 verification passed!"
    echo ""
    echo "Next steps:"
    echo "1. Read the reference materials:"
    echo "   - $LAB_DIR/README.md"
    echo "   - $LAB_DIR/SPEC.md"
    echo "   - $LAB_DIR/EXPECTED.md"
    echo ""
    echo "2. Run and test the examples:"
    echo "   cd $LAB_DIR"
    echo "   uv add fastapi uvicorn"
    echo "   uv run uvicorn examples:app --reload"
    echo "   Visit http://localhost:8000/docs"
    echo ""
    echo "3. When ready, proceed to Lab 01!"
    exit 0
else
    echo "❌ Lab 00 verification failed. Check the errors above."
    exit 1
fi
