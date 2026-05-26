#!/usr/bin/env bash

PASS=0
FAIL=0

ok()   { echo "✅ $1"; PASS=$((PASS+1)); }
fail() { echo "❌ $1"; FAIL=$((FAIL+1)); }

BASE="http://localhost:8000"

echo "=== Lab 06 Check ==="
echo ""
echo "Setting up test data..."

# Clear and add known data
curl -s -X POST "$BASE/transactions" -H "Content-Type: application/json" \
  -d '{"amount": 1000.0, "type": "income", "category": "lab06-salary", "date": "2026-05-01"}' > /dev/null
curl -s -X POST "$BASE/transactions" -H "Content-Type: application/json" \
  -d '{"amount": 200.0, "type": "expense", "category": "lab06-food", "date": "2026-05-02"}' > /dev/null
curl -s -X POST "$BASE/transactions" -H "Content-Type: application/json" \
  -d '{"amount": 100.0, "type": "expense", "category": "lab06-food", "date": "2026-05-03"}' > /dev/null
echo "Added 3 test transactions."
echo ""

# Check summary endpoint exists
SUMMARY=$(curl -s --max-time 3 "$BASE/transactions/summary" 2>/dev/null)
if echo "$SUMMARY" | grep -q "total_income"; then
  ok "GET /transactions/summary endpoint exists"
else
  fail "GET /transactions/summary missing or returns wrong format — got: $SUMMARY"
fi

# Check balance math (income=1000, expense=300 from our test data, but there may be existing data)
# Just verify the keys exist
if echo "$SUMMARY" | grep -q "total_expense" && echo "$SUMMARY" | grep -q "balance"; then
  ok "Summary has total_income, total_expense, and balance fields"
else
  fail "Summary missing required fields — got: $SUMMARY"
fi

# Check category filter
FOOD=$(curl -s --max-time 3 "$BASE/transactions?category=lab06-food" 2>/dev/null)
FOOD_COUNT=$(echo "$FOOD" | grep -o '"category":"lab06-food"' | wc -l | tr -d ' ')
if [ "$FOOD_COUNT" = "2" ]; then
  ok "GET /transactions?category=lab06-food returns 2 results"
else
  fail "Category filter — expected 2 lab06-food transactions, got $FOOD_COUNT (response: $FOOD)"
fi

# Check non-existent category returns empty
EMPTY=$(curl -s --max-time 3 "$BASE/transactions?category=lab06-doesnotexist" 2>/dev/null)
if [ "$EMPTY" = "[]" ]; then
  ok "GET /transactions?category=nonexistent returns []"
else
  fail "Non-existent category filter — expected [], got: $EMPTY"
fi

# Check salary filter
SALARY=$(curl -s --max-time 3 "$BASE/transactions?category=lab06-salary" 2>/dev/null)
SALARY_COUNT=$(echo "$SALARY" | grep -o '"category":"lab06-salary"' | wc -l | tr -d ' ')
if [ "$SALARY_COUNT" = "1" ]; then
  ok "GET /transactions?category=lab06-salary returns 1 result"
else
  fail "Salary filter — expected 1 result, got $SALARY_COUNT"
fi

echo ""
echo "ℹ️  UI checks (verify manually):"
echo "   - Summary bar shows correct income/expense/balance"
echo "   - Category dropdown contains all categories"
echo "   - Selecting a category filters the list client-side"
echo "   - Summary updates after add/delete"
echo ""
echo "Results: $PASS passed, $FAIL failed"
if [ $FAIL -eq 0 ]; then
  echo "🎉 All checks passed! Move on to Lab 07."
else
  echo "Fix the failing checks before moving on."
fi
