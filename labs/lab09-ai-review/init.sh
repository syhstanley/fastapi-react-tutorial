#!/usr/bin/env bash
set -e

echo "=== Lab 09: AI Coding Style Review ==="
echo ""

PROJECT_ROOT="${1:-budget-tracker}"

if [ -f "$PROJECT_ROOT/agent.md" ]; then
  echo "ℹ️  $PROJECT_ROOT/agent.md already exists. Edit it to complete this lab."
  echo ""
  echo "Run ./check.sh to verify your agent.md has all required sections."
  exit 0
fi

# Create agent.md template
cat > "$PROJECT_ROOT/agent.md" << 'EOF'
# agent.md — Budget Tracker Project Context

## 1. Project Overview

<!-- Describe what this app does and its tech stack in 3-5 sentences. -->
<!-- Example: "This is a personal budget tracker built with FastAPI (Python) and React (JavaScript)..." -->

TODO: Write 3-5 sentences describing the app and tech stack.

## 2. Directory Structure

<!-- List the key backend files and what each one does. -->
<!-- Example: -->
<!-- - backend/main.py — FastAPI app entry point, mounts routers, configures CORS -->
<!-- - backend/database.py — SQLAlchemy engine, SessionLocal, get_db dependency -->

TODO: List at least 5 key files with one-line descriptions.

## 3. Coding Conventions

<!-- Describe patterns you consistently used in this project. -->
<!-- Examples: -->
<!-- - "I always inject the DB session using Depends(get_db)" -->
<!-- - "404 errors are raised with HTTPException(status_code=404, detail='...')" -->

TODO: Describe at least 2 patterns you used consistently.

## 4. What to Review

<!-- Name the specific files you created or modified in Lab 08. -->
<!-- Example: "Please review routers/budgets.py and any related changes to models.py" -->

TODO: Name your Lab 08 files here.

## 5. Review Focus

<!-- Ask at least 2 specific questions about your Lab 08 code. -->
<!-- Examples: -->
<!-- - "Is my error handling in budgets.py consistent with transactions.py?" -->
<!-- - "Are my endpoint paths RESTful?" -->

TODO: Write at least 2 specific questions about your Lab 08 implementation.
EOF

echo "✅ Created $PROJECT_ROOT/agent.md (template)"
echo ""
echo "Next steps:"
echo "  1. Open $PROJECT_ROOT/agent.md and fill in all 5 sections"
echo "  2. Replace every 'TODO:' line with real content"
echo "  3. Open claude.ai (or your AI of choice)"
echo "  4. Paste agent.md + your Lab 08 code"
echo "  5. Ask your specific review questions"
echo ""
echo "Run ./check.sh to verify your agent.md before running the AI review."
