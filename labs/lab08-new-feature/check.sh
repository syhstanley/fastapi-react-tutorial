#!/usr/bin/env bash

PASS=0
FAIL=0

ok()   { echo "✅ $1"; PASS=$((PASS+1)); }
fail() { echo "❌ $1"; FAIL=$((FAIL+1)); }
info() { echo "ℹ️  $1"; }

BASE="http://localhost:8000"

echo "=== Lab 08 Check ==="
echo ""

# Check OpenAPI spec has a "budgets" tag
OPENAPI=$(curl -s --max-time 3 "$BASE/openapi.json" 2>/dev/null)
if echo "$OPENAPI" | grep -qi '"budgets"'; then
  ok "OpenAPI spec contains a 'budgets' tag group"
else
  fail "OpenAPI spec missing 'budgets' tag — add tags=['budgets'] to your budget router"
fi

# Discover the budget endpoint path
BUDGET_PATH=""
for path in "/budgets" "/budget" "/budget-limits"; do
  HTTP=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 -X GET "$BASE$path" 2>/dev/null)
  if [ "$HTTP" = "200" ] || [ "$HTTP" = "422" ]; then
    BUDGET_PATH="$path"
    break
  fi
done

if [ -n "$BUDGET_PATH" ]; then
  ok "Budget endpoint found at $BUDGET_PATH"
else
  fail "Could not find budget endpoint at /budgets, /budget, or /budget-limits"
  info "Make sure your budget router is mounted in main.py"
  echo ""
  echo "Results: $PASS passed, $FAIL failed"
  echo "Fix the failing checks before moving on."
  exit 1
fi

# POST a budget limit
POST_BUDGET=$(curl -s --max-time 3 -X POST "$BASE$BUDGET_PATH" \
  -H "Content-Type: application/json" \
  -d '{"category": "lab08-food", "monthly_limit": 500.0}' 2>/dev/null)
BUDGET_ID=$(echo "$POST_BUDGET" | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)

if [ -n "$BUDGET_ID" ]; then
  ok "POST $BUDGET_PATH creates a budget with id=$BUDGET_ID"
else
  fail "POST $BUDGET_PATH — no id in response (got: $POST_BUDGET)"
fi

# GET all budgets
GET_BUDGETS=$(curl -s --max-time 3 "$BASE$BUDGET_PATH" 2>/dev/null)
if echo "$GET_BUDGETS" | grep -q "lab08-food"; then
  ok "GET $BUDGET_PATH returns the created budget"
else
  fail "GET $BUDGET_PATH — expected lab08-food budget, got: $GET_BUDGETS"
fi

# PUT to update
if [ -n "$BUDGET_ID" ]; then
  PUT_RESP=$(curl -s --max-time 3 -X PUT "$BASE$BUDGET_PATH/$BUDGET_ID" \
    -H "Content-Type: application/json" \
    -d '{"category": "lab08-food", "monthly_limit": 750.0}' 2>/dev/null)
  NEW_LIMIT=$(echo "$PUT_RESP" | grep -o '"monthly_limit":[0-9.]*' | head -1 | cut -d: -f2)
  if [ "$NEW_LIMIT" = "750.0" ]; then
    ok "PUT $BUDGET_PATH/$BUDGET_ID updates monthly_limit to 750.0"
  else
    fail "PUT $BUDGET_PATH/$BUDGET_ID — expected monthly_limit=750.0, got: $PUT_RESP"
  fi
fi

# Check summary includes budget info
SUMMARY=$(curl -s --max-time 3 "$BASE/transactions/summary" 2>/dev/null)
if echo "$SUMMARY" | grep -qi "budget\|monthly_limit"; then
  ok "GET /transactions/summary includes budget information"
else
  fail "GET /transactions/summary missing budget info — got: $SUMMARY"
fi

# DELETE budget
if [ -n "$BUDGET_ID" ]; then
  DEL=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 \
    -X DELETE "$BASE$BUDGET_PATH/$BUDGET_ID" 2>/dev/null)
  if [ "$DEL" = "204" ]; then
    ok "DELETE $BUDGET_PATH/$BUDGET_ID returns 204"
  else
    fail "DELETE $BUDGET_PATH/$BUDGET_ID — expected 204, got $DEL"
  fi
fi

# Regression: existing endpoints still work
TXNS=$(curl -s --max-time 3 "$BASE/transactions" 2>/dev/null)
if echo "$TXNS" | grep -q '\['; then
  ok "GET /transactions still works (regression check)"
else
  fail "GET /transactions broken after Lab 08 changes"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
if [ $FAIL -eq 0 ]; then
  echo "🎉 All checks passed! Move on to Lab 09."
else
  echo "Fix the failing checks before moving on."
fi
