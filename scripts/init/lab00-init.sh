#!/bin/bash
# Lab 00 — FastAPI Fundamentals Reference
# This script sets up a temporary environment to test Lab 00 examples

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LAB_DIR="$REPO_ROOT/labs/lab00-fastapi-fundamentals"

echo "📖 Lab 00: FastAPI Fundamentals Setup"
echo ""
echo "This is a reference lab — no installation needed!"
echo "You can read the materials and run the examples anytime."
echo ""
echo "📁 Lab 00 Location:"
echo "   $LAB_DIR"
echo ""
echo "📚 Read these files:"
echo "   1. README.md — Core concepts and patterns"
echo "   2. SPEC.md — Checklist of what to understand"
echo "   3. EXPECTED.md — What you should learn"
echo ""
echo "💻 Run the example code:"
echo "   cd $LAB_DIR"
echo "   uv add fastapi uvicorn  # One-time setup"
echo "   uv run uvicorn examples:app --reload"
echo ""
echo "Then visit:"
echo "   - http://localhost:8000/docs (Swagger UI - interactive testing)"
echo "   - http://localhost:8000/redoc (ReDoc - documentation)"
echo ""
echo "🔗 Official FastAPI docs:"
echo "   https://fastapi.tiangolo.com/"
echo ""
echo "✅ Lab 00 is ready!"
echo ""
echo "Next step: Read Lab 00 materials, then proceed to Lab 01"
