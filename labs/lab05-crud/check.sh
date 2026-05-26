#!/usr/bin/env bash

PASS=0
FAIL=0

ok()   { echo "✅ $1"; PASS=$((PASS+1)); }
fail() { echo "❌ $1"; FAIL=$((FAIL+1)); }

BASE="http://localhost:8000"

echo "=== Lab 05 Check ==="
echo ""

# POST a new transaction
RESP=$(curl -s --max-time 3 -X POST "$BASE/transactions" \
  -H "Content-Type: application/json" \
  -d '{"amount": 25.0, "type": "expense", "category": "check-lab05", "date": "2026-05-01"}' 2>/dev/null)
TEST_ID=$(echo "$RESP" | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)

if [ -n "$TEST_ID" ]; then
  ok "POST /transactions works (created id=$TEST_ID)"
else
  fail "POST /transactions failed — response: $RESP"
fi

# DELETE non-existent id → 404
HTTP_404=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 \
  -X DELETE "$BASE/transactions/999999" 2>/dev/null)
if [ "$HTTP_404" = "404" ]; then
  ok "DELETE /transactions/999999 returns 404"
else
  fail "DELETE non-existent id — expected 404, got $HTTP_404"
fi

# DELETE existing transaction → 204
if [ -n "$TEST_ID" ]; then
  HTTP_204=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 \
    -X DELETE "$BASE/transactions/$TEST_ID" 2>/dev/null)
  if [ "$HTTP_204" = "204" ]; then
    ok "DELETE /transactions/$TEST_ID returns 204"
  else
    fail "DELETE existing transaction — expected 204, got $HTTP_204"
  fi

  # Verify deleted (GET should not include it)
  LIST=$(curl -s --max-time 3 "$BASE/transactions" 2>/dev/null)
  if echo "$LIST" | grep -q "\"id\":$TEST_ID"; then
    fail "Deleted transaction id=$TEST_ID still appears in GET /transactions"
  else
    ok "Deleted transaction no longer appears in GET /transactions"
  fi
fi

echo ""
echo "ℹ️  UI checks (verify manually in browser):"
echo "   - Add transaction via form → appears in list immediately"
echo "   - Refresh browser → transaction persists"
echo "   - Delete via button → disappears from list"
echo "   - Refresh browser → deletion persists"
echo ""
echo "Results: $PASS passed, $FAIL failed"
if [ $FAIL -eq 0 ]; then
  echo "🎉 All checks passed! Move on to Lab 06."
else
  echo "Fix the failing checks before moving on."
fi
