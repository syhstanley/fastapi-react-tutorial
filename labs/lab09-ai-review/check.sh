#!/usr/bin/env bash

PASS=0
FAIL=0

ok()   { echo "✅ $1"; PASS=$((PASS+1)); }
fail() { echo "❌ $1"; FAIL=$((FAIL+1)); }

PROJECT_ROOT="${1:-budget-tracker}"
AGENT_FILE="$PROJECT_ROOT/agent.md"

echo "=== Lab 09 Check ==="
echo ""

# Check agent.md exists
if [ -f "$AGENT_FILE" ]; then
  ok "agent.md exists at $AGENT_FILE"
else
  fail "agent.md not found at $AGENT_FILE"
  echo ""
  echo "Run: ./init.sh to create a template, then fill it in."
  echo "Results: $PASS passed, $FAIL failed"
  exit 1
fi

# Check no TODO lines remain
TODO_COUNT=$(grep -c "^TODO:" "$AGENT_FILE" 2>/dev/null || echo 0)
if [ "$TODO_COUNT" = "0" ]; then
  ok "No unfilled TODO lines in agent.md"
else
  fail "Found $TODO_COUNT unfilled TODO line(s) in agent.md — complete all sections"
fi

# Check all 5 sections present
for section in "Project Overview" "Directory Structure" "Coding Conventions" "What to Review" "Review Focus"; do
  if grep -qi "$section" "$AGENT_FILE"; then
    ok "Section found: $section"
  else
    fail "Missing section: $section"
  fi
done

# Check minimum length (too short = not filled in)
LINE_COUNT=$(wc -l < "$AGENT_FILE" | tr -d ' ')
if [ "$LINE_COUNT" -ge "20" ] 2>/dev/null; then
  ok "agent.md has sufficient content ($LINE_COUNT lines)"
else
  fail "agent.md seems too short ($LINE_COUNT lines) — make sure all sections are filled in"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
if [ $FAIL -eq 0 ]; then
  echo "🎉 agent.md looks good! Now run your AI review:"
  echo "   1. Open claude.ai"
  echo "   2. Paste agent.md content"
  echo "   3. Paste your Lab 08 code"
  echo "   4. Ask your specific questions"
else
  echo "Fix the failing checks, then run the AI review."
fi
