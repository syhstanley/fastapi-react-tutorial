#!/usr/bin/env bash

PASS=0
FAIL=0

ok()   { echo "✅ $1"; PASS=$((PASS+1)); }
fail() { echo "❌ $1"; FAIL=$((FAIL+1)); }

BASE="http://localhost:8000"

echo "=== Lab 04 Check ==="
echo ""

# Check backend is up
HEALTH=$(curl -s --max-time 3 "$BASE/health" 2>/dev/null)
if [ "$HEALTH" = '{"status":"ok"}' ]; then
  ok "Backend is running"
else
  fail "Backend not running or /health failed"
fi

# Check CORS header on /transactions
CORS_HEADER=$(curl -s --max-time 3 -H "Origin: http://localhost:5173" \
  -I "$BASE/transactions" 2>/dev/null | grep -i "access-control-allow-origin" || echo "")
if echo "$CORS_HEADER" | grep -qi "localhost:5173\|*"; then
  ok "CORS header present for http://localhost:5173"
else
  fail "CORS header missing — add CORSMiddleware to main.py before include_router calls"
fi

# Check frontend is accessible
FRONT=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 http://localhost:5173 2>/dev/null)
if [ "$FRONT" = "200" ]; then
  ok "Frontend accessible at http://localhost:5173"
else
  fail "Frontend not accessible at http://localhost:5173 (HTTP $FRONT)"
fi

# Check frontend HTML contains React root
FRONT_HTML=$(curl -s --max-time 3 http://localhost:5173 2>/dev/null)
if echo "$FRONT_HTML" | grep -q 'id="root"'; then
  ok "Frontend HTML has React root element"
else
  fail "Frontend HTML missing React root — is Vite running?"
fi

echo ""
echo "ℹ️  To fully verify the UI, open http://localhost:5173 in a browser and check:"
echo "   - Transaction list renders (after adding data via curl)"
echo "   - No CORS errors in DevTools console"
echo "   - Network tab shows GET /transactions with status 200"
echo ""
echo "Results: $PASS passed, $FAIL failed"
if [ $FAIL -eq 0 ]; then
  echo "🎉 All checks passed! Move on to Lab 05."
else
  echo "Fix the failing checks before moving on."
fi
