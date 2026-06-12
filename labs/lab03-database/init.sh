#!/usr/bin/env bash
set -e

# 不管從哪個目錄執行，都能找到正確路徑
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Lab 03: SQLite + SQLAlchemy ==="
echo ""

BACKEND="${1:-$REPO_ROOT/budget-tracker/backend}"

if [ ! -d "$BACKEND" ]; then
  echo "Error: backend directory not found at $BACKEND"
  echo "Usage: ./init.sh [path/to/backend]"
  exit 1
fi

echo "Next steps:"
echo "  1. cd $BACKEND && uv add sqlalchemy"
echo "  2. Create database.py (engine, SessionLocal, Base, get_db)"
echo "  3. Create models.py (Transaction ORM model)"
echo "  4. Update main.py: add Base.metadata.create_all(bind=engine)"
echo "  5. Update routers/transactions.py to use DB session via Depends(get_db)"
echo "  6. Create .gitignore (add db/ and .venv/)"
echo ""

# Create .gitignore if it doesn't exist
if [ ! -f "$BACKEND/.gitignore" ]; then
  cat > "$BACKEND/.gitignore" << 'EOF'
db/
.venv/
__pycache__/
*.pyc
EOF
  echo "✅ Created $BACKEND/.gitignore"
else
  echo "ℹ️  $BACKEND/.gitignore already exists — skipping"
fi

echo ""
echo "Run ./check.sh when the server is running."
