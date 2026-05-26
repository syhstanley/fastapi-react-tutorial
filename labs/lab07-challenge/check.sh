#!/usr/bin/env bash

PASS=0
FAIL=0

ok()   { echo "✅ $1"; PASS=$((PASS+1)); }
fail() { echo "❌ $1"; FAIL=$((FAIL+1)); }

BASE="http://localhost:8000"

echo "=== Lab 07 Check ==="
echo ""
echo "Setting up test data across two months..."

curl -s -X POST "$BASE/transactions" -H "Content-Type: application/json" \
  -d '{"amount": 500.0, "type": "income", "category": "lab07-salary", "date": "2026-05-01"}' > /dev/null
curl -s -X POST "$BASE/transactions" -H "Content-Type: application/json" \
  -d '{"amount": 50.0, "type": "expense", "category": "lab07-food", "date": "2026-05-15"}' > /dev/null
curl -s -X POST "$BASE/transactions" -H "Content-Type: application/json" \
  -d '{"amount": 400.0, "type": "income", "category": "lab07-salary", "date": "2026-04-01"}' > /dev/null
curl -s -X POST "$BASE/transactions" -H "Content-Type: application/json" \
  -d '{"amount": 30.0, "type": "expense", "category": "lab07-food", "date": "2026-04-20"}' > /dev/null
echo "Added 4 test transactions (2 in May, 2 in April)."
echo ""

# Month filter: May
MAY=$(curl -s --max-time 3 "$BASE/transactions?month=2026-05" 2>/dev/null)
MAY_COUNT=$(echo "$MAY" | grep -o '"category":"lab07' | wc -l | tr -d ' ')
if [ "$MAY_COUNT" = "2" ]; then
  ok "GET /transactions?month=2026-05 returns 2 May transactions"
else
  fail "Month filter May — expected 2 lab07 transactions, got $MAY_COUNT"
fi

# Month filter: April
APR=$(curl -s --max-time 3 "$BASE/transactions?month=2026-04" 2>/dev/null)
APR_COUNT=$(echo "$APR" | grep -o '"category":"lab07' | wc -l | tr -d ' ')
if [ "$APR_COUNT" = "2" ]; then
  ok "GET /transactions?month=2026-04 returns 2 April transactions"
else
  fail "Month filter April — expected 2 lab07 transactions, got $APR_COUNT"
fi

# Month + category combined
COMBO=$(curl -s --max-time 3 "$BASE/transactions?month=2026-05&category=lab07-food" 2>/dev/null)
COMBO_COUNT=$(echo "$COMBO" | grep -o '"category":"lab07-food"' | wc -l | tr -d ' ')
if [ "$COMBO_COUNT" = "1" ]; then
  ok "GET /transactions?month=2026-05&category=lab07-food returns 1 result"
else
  fail "Combined filter — expected 1 result, got $COMBO_COUNT"
fi

# Empty month
EMPTY=$(curl -s --max-time 3 "$BASE/transactions?month=2026-03" 2>/dev/null)
if [ "$EMPTY" = "[]" ]; then
  ok "GET /transactions?month=2026-03 returns []"
else
  fail "Empty month filter — expected [], got: $EMPTY"
fi

# Create a transaction to edit
EDIT_RESP=$(curl -s --max-time 3 -X POST "$BASE/transactions" \
  -H "Content-Type: application/json" \
  -d '{"amount": 99.0, "type": "expense", "category": "lab07-edit-test", "date": "2026-05-01"}' 2>/dev/null)
EDIT_ID=$(echo "$EDIT_RESP" | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)

if [ -n "$EDIT_ID" ]; then
  # PUT to update it
  PUT_RESP=$(curl -s --max-time 3 -X PUT "$BASE/transactions/$EDIT_ID" \
    -H "Content-Type: application/json" \
    -d '{"amount": 77.0, "type": "expense", "category": "lab07-edit-test", "date": "2026-05-01"}' 2>/dev/null)
  NEW_AMOUNT=$(echo "$PUT_RESP" | grep -o '"amount":[0-9.]*' | head -1 | cut -d: -f2)

  if [ "$NEW_AMOUNT" = "77.0" ]; then
    ok "PUT /transactions/$EDIT_ID updates amount to 77.0"
  else
    fail "PUT /transactions/$EDIT_ID — expected amount=77.0, got $NEW_AMOUNT (response: $PUT_RESP)"
  fi

  # Verify id unchanged
  RETURNED_ID=$(echo "$PUT_RESP" | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)
  if [ "$RETURNED_ID" = "$EDIT_ID" ]; then
    ok "PUT does not change transaction id"
  else
    fail "PUT changed transaction id (expected $EDIT_ID, got $RETURNED_ID)"
  fi
fi

# PUT non-existent → 404
HTTP_404=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 \
  -X PUT "$BASE/transactions/999999" \
  -H "Content-Type: application/json" \
  -d '{"amount": 1.0, "type": "expense", "category": "x", "date": "2026-05-01"}' 2>/dev/null)
if [ "$HTTP_404" = "404" ]; then
  ok "PUT /transactions/999999 returns 404"
else
  fail "PUT non-existent — expected 404, got $HTTP_404"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
if [ $FAIL -eq 0 ]; then
  echo "🎉 All checks passed! Move on to Lab 08."
else
  echo "Fix the failing checks before moving on."
fi
