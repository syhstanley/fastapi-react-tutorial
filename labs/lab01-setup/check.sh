#!/usr/bin/env bash

PASS=0
FAIL=0

ok()   { echo "✅ $1"; PASS=$((PASS+1)); }
fail() { echo "❌ $1"; FAIL=$((FAIL+1)); }

echo "=== Lab 01 Check ==="
echo ""

# Check backend health
HEALTH=$(curl -s --max-time 3 http://localhost:8000/health 2>/dev/null)
if [ "$HEALTH" = '{"status":"ok"}' ]; then
  ok "GET /health returns {\"status\":\"ok\"}"
else
  fail "GET /health — expected {\"status\":\"ok\"}, got: $HEALTH"
fi

# Check Swagger UI
SWAGGER=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 http://localhost:8000/docs 2>/dev/null)
if [ "$SWAGGER" = "200" ]; then
  ok "Swagger UI accessible at http://localhost:8000/docs"
else
  fail "Swagger UI not accessible at /docs (HTTP $SWAGGER)"
fi

# Check frontend
FRONT=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 http://localhost:5173 2>/dev/null)
if [ "$FRONT" = "200" ]; then
  ok "React app accessible at http://localhost:5173"
else
  fail "React app not accessible at http://localhost:5173 (HTTP $FRONT)"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
if [ $FAIL -eq 0 ]; then
  echo "🎉 All checks passed! Move on to Lab 02."
else
  echo "Fix the failing checks before moving on."
fi
