#!/usr/bin/env bash

PASS=0
FAIL=0

ok()   { echo "✅ $1"; PASS=$((PASS+1)); }
fail() { echo "❌ $1"; FAIL=$((FAIL+1)); }

BASE="http://localhost:8000"

echo "=== Lab 02 Check ==="
echo ""

# Check empty list
EMPTY=$(curl -s --max-time 3 "$BASE/transactions" 2>/dev/null)
if [ "$EMPTY" = "[]" ]; then
  ok "GET /transactions returns [] on fresh start"
else
  fail "GET /transactions — expected [], got: $EMPTY"
fi

# POST first transaction
RESP=$(curl -s --max-time 3 -X POST "$BASE/transactions" \
  -H "Content-Type: application/json" \
  -d '{"amount": 50.0, "type": "expense", "category": "food", "description": "test", "date": "2026-05-01"}' 2>/dev/null)

ID=$(echo "$RESP" | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)
AMOUNT=$(echo "$RESP" | grep -o '"amount":[0-9.]*' | head -1 | cut -d: -f2)
TYPE=$(echo "$RESP" | grep -o '"type":"[^"]*"' | head -1 | cut -d: -f2 | tr -d '"')

if [ "$ID" = "1" ]; then
  ok "First POST returns id=1"
else
  fail "First POST — expected id=1, got id=$ID (response: $RESP)"
fi

if [ "$AMOUNT" = "50.0" ] && [ "$TYPE" = "expense" ]; then
  ok "POST response includes amount and type fields"
else
  fail "POST response missing fields (amount=$AMOUNT, type=$TYPE)"
fi

# POST second transaction
RESP2=$(curl -s --max-time 3 -X POST "$BASE/transactions" \
  -H "Content-Type: application/json" \
  -d '{"amount": 3000.0, "type": "income", "category": "salary", "date": "2026-05-01"}' 2>/dev/null)

ID2=$(echo "$RESP2" | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)
if [ "$ID2" = "2" ]; then
  ok "Second POST returns id=2"
else
  fail "Second POST — expected id=2, got id=$ID2"
fi

# GET returns both
LIST=$(curl -s --max-time 3 "$BASE/transactions" 2>/dev/null)
COUNT=$(echo "$LIST" | grep -o '"id"' | wc -l | tr -d ' ')
if [ "$COUNT" = "2" ]; then
  ok "GET /transactions returns both transactions"
else
  fail "GET /transactions — expected 2 items, found $COUNT"
fi

# Invalid type returns 422
HTTP422=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 -X POST "$BASE/transactions" \
  -H "Content-Type: application/json" \
  -d '{"amount": 10.0, "type": "unknown", "category": "food", "date": "2026-05-01"}' 2>/dev/null)
if [ "$HTTP422" = "422" ]; then
  ok "Invalid type returns HTTP 422"
else
  fail "Invalid type — expected HTTP 422, got $HTTP422"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
if [ $FAIL -eq 0 ]; then
  echo "🎉 All checks passed! Move on to Lab 03."
else
  echo "Fix the failing checks before moving on."
fi
