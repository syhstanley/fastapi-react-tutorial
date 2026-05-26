#!/usr/bin/env bash
set -e

echo "=== Lab 05: Full CRUD (Add & Delete) ==="
echo ""

echo "Next steps:"
echo ""
echo "Backend:"
echo "  Add to routers/transactions.py:"
echo "    DELETE /{transaction_id}"
echo "    - Returns 404 if not found"
echo "    - Returns 204 (no body) on success"
echo ""
echo "Frontend:"
echo "  1. Add a transaction form (amount, type, category, description, date)"
echo "     - POST to http://localhost:8000/transactions on submit"
echo "     - Clear form on success, refresh list"
echo "  2. Add Delete button to each transaction row"
echo "     - DELETE http://localhost:8000/transactions/{id} on click"
echo "     - Remove from list on success"
echo ""
echo "Run ./check.sh when both servers are running."
