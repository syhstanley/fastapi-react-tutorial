#!/usr/bin/env bash

PASS=0
FAIL=0

ok()   { echo "✅ $1"; PASS=$((PASS+1)); }
fail() { echo "❌ $1"; FAIL=$((FAIL+1)); }

BASE="http://localhost:8000"
BACKEND="${1:-budget-tracker/backend}"

echo "=== Lab 03 Check ==="
echo ""

# POST a transaction
RESP=$(curl -s --max-time 3 -X POST "$BASE/transactions" \
  -H "Content-Type: application/json" \
  -d '{"amount": 100.0, "type": "income", "category": "salary", "date": "2026-05-01"}' 2>/dev/null)
ID=$(echo "$RESP" | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)

if [ -n "$ID" ]; then
  ok "POST /transactions works (id=$ID)"
else
  fail "POST /transactions failed — response: $RESP"
fi

# Check DB file exists
DB_PATH="$BACKEND/db/budget.db"
if [ -f "$DB_PATH" ]; then
  ok "Database file exists at $DB_PATH"
else
  fail "Database file not found at $DB_PATH"
fi

# Check GET returns data (not empty)
LIST=$(curl -s --max-time 3 "$BASE/transactions" 2>/dev/null)
COUNT=$(echo "$LIST" | grep -o '"id"' | wc -l | tr -d ' ')
if [ "$COUNT" -ge "1" ] 2>/dev/null; then
  ok "GET /transactions returns $COUNT transaction(s)"
else
  fail "GET /transactions returned no data — got: $LIST"
fi

# Check created_at exists in response
HAS_CREATED=$(echo "$LIST" | grep -c '"created_at"' 2>/dev/null || echo 0)
if [ "$HAS_CREATED" -ge "1" ] 2>/dev/null; then
  ok "Response includes created_at field"
else
  fail "Response missing created_at field (check your models.py and TransactionResponse)"
fi

# Check DB contents via sqlite3 if available
if command -v sqlite3 &>/dev/null; then
  ROW_COUNT=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM transactions;" 2>/dev/null || echo "0")
  if [ "$ROW_COUNT" -ge "1" ] 2>/dev/null; then
    ok "sqlite3: $ROW_COUNT row(s) in transactions table"
  else
    fail "sqlite3: transactions table is empty or doesn't exist"
  fi
else
  echo "ℹ️  sqlite3 not installed — skipping direct DB check"
fi

echo ""
echo "⚠️  Persistence test: restart your server manually, then run this script again."
echo "   GET /transactions should still return your data after restart."
echo ""
echo "Results: $PASS passed, $FAIL failed"
if [ $FAIL -eq 0 ]; then
  echo "🎉 All checks passed! Move on to Lab 04."
else
  echo "Fix the failing checks before moving on."
fi
