#!/bin/bash
# Initialize all labs (01-08) in sequence

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$REPO_ROOT/init"

echo "🚀 Initializing all labs (01-08)..."
echo ""

labs=("01" "02" "03" "04" "05" "06" "07" "08")

for lab in "${labs[@]}"; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 Lab $lab"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    script="$SCRIPTS_DIR/lab${lab}-init.sh"

    if [ ! -f "$script" ]; then
        echo "⚠️  Script not found: $script (skipping)"
        continue
    fi

    bash "$script"
    echo ""
done

PROJECT_DIR="$(cd "$REPO_ROOT/.." && pwd)/budget-tracker"

echo "✅ All labs initialized!"
echo ""
echo "To run the project:"
echo ""
echo "Terminal 1 (Backend):"
echo "  cd $PROJECT_DIR/backend"
echo "  uv run uvicorn main:app --reload"
echo ""
echo "Terminal 2 (Frontend):"
echo "  cd $PROJECT_DIR/frontend"
echo "  npm run dev"
echo ""
echo "Then visit: http://localhost:5173"
echo "Swagger UI: http://localhost:8000/docs"
