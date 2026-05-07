#!/bin/bash
# Lab 01 — Environment Setup & Hello World
# Creates budget-tracker project with FastAPI backend + React frontend

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_DIR="$REPO_ROOT/budget-tracker"

echo "📦 Lab 01: Initializing budget-tracker project..."

# Create project structure
mkdir -p "$PROJECT_DIR/backend"
mkdir -p "$PROJECT_DIR/frontend"

# Backend setup
cd "$PROJECT_DIR/backend"
echo "🐍 Setting up Python backend..."

# Initialize uv project
if ! command -v uv &> /dev/null; then
    echo "⚠️  'uv' not found. Installing..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Remove existing venv/files
rm -rf .venv hello.py 2>/dev/null || true

# Initialize with uv
uv init --name budget-tracker
uv add fastapi uvicorn

# Create main.py with /health endpoint
cat > main.py << 'EOF'
from fastapi import FastAPI

app = FastAPI()

@app.get("/health")
def health():
    return {"status": "ok"}
EOF

echo "✅ Backend initialized at: $PROJECT_DIR/backend"
echo "   - FastAPI app with /health endpoint"
echo "   - Run with: cd $PROJECT_DIR/backend && uv run uvicorn main:app --reload"

# Frontend setup
cd "$PROJECT_DIR/frontend"
echo "⚛️  Setting up React frontend..."

# Remove existing files
rm -rf node_modules package.json package-lock.json vite.config.js 2>/dev/null || true

# Create Vite + React project
npm create vite@latest . -- --template react 2>&1 | grep -v "^npm notice"
npm install

echo "✅ Frontend initialized at: $PROJECT_DIR/frontend"
echo "   - React + Vite"
echo "   - Run with: cd $PROJECT_DIR/frontend && npm run dev"

echo ""
echo "🚀 Lab 01 Setup Complete!"
echo ""
echo "Next steps:"
echo "1. Terminal 1: cd $PROJECT_DIR/backend && uv run uvicorn main:app --reload"
echo "2. Terminal 2: cd $PROJECT_DIR/frontend && npm run dev"
echo "3. Visit http://localhost:5173 (frontend) and http://localhost:8000/docs (Swagger UI)"
