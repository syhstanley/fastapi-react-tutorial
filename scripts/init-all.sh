#!/bin/bash
# Initialize all labs (01-05) in sequence

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$REPO_ROOT/init"

echo "🚀 Initializing all labs (01-05)..."
echo ""

# Array of labs to initialize
labs=("01" "02" "03" "04" "05")

for lab in "${labs[@]}"; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 Lab $lab"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    script="$SCRIPTS_DIR/lab${lab}-init.sh"

    if [ ! -f "$script" ]; then
        echo "❌ Script not found: $script"
        exit 1
    fi

    bash "$script"
    echo ""
done

echo "✅ All labs initialized!"
echo ""
echo "To run the project:"
echo ""
echo "Terminal 1 (Backend):"
echo "  cd $(cd "$REPO_ROOT/.." && pwd)/budget-tracker/backend"
echo "  uv run uvicorn main:app --reload"
echo ""
echo "Terminal 2 (Frontend):"
echo "  cd $(cd "$REPO_ROOT/.." && pwd)/budget-tracker/frontend"
echo "  npm run dev"
echo ""
echo "Then visit: http://localhost:5173"
