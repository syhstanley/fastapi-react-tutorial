#!/usr/bin/env bash
set -e

# 不管從哪個目錄執行，都能找到正確路徑
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Lab 04: React Basics & Fetching Data ==="
echo ""

BACKEND="${1:-$REPO_ROOT/budget-tracker/backend}"
FRONTEND="${2:-$REPO_ROOT/budget-tracker/frontend}"

echo "Next steps:"
echo ""
echo "Backend ($BACKEND/main.py):"
echo "  Add CORSMiddleware BEFORE include_router calls:"
echo "    from fastapi.middleware.cors import CORSMiddleware"
echo "    app.add_middleware("
echo "        CORSMiddleware,"
echo "        allow_origins=['http://localhost:5173'],"
echo "        allow_methods=['*'],"
echo "        allow_headers=['*'],"
echo "    )"
echo ""
echo "Frontend ($FRONTEND/src/):"
echo "  1. Create TransactionList.jsx"
echo "     - useEffect to fetch GET http://localhost:8000/transactions on mount"
echo "     - useState to store transactions"
echo "     - Render each transaction: date, category, type, amount"
echo "     - Show total count"
echo "     - Show 'No transactions yet.' when empty"
echo "  2. Update App.jsx to render <TransactionList />"
echo ""
echo "Run ./check.sh when both servers are running."
