#!/bin/bash
# Verify all labs (01-05)

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$REPO_ROOT/verify"

echo "🔍 Verifying all labs (01-05)..."
echo ""

# Array of labs to verify
labs=("01" "02" "03" "04" "05")

all_passed=true

for lab in "${labs[@]}"; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔍 Lab $lab Verification"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    script="$SCRIPTS_DIR/lab${lab}-verify.sh"

    if [ ! -f "$script" ]; then
        echo "❌ Script not found: $script"
        all_passed=false
        continue
    fi

    if bash "$script"; then
        echo ""
    else
        echo ""
        all_passed=false
    fi
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$all_passed" = true ]; then
    echo "✅ All labs verified successfully!"
    exit 0
else
    echo "❌ Some labs failed verification. Check the errors above."
    exit 1
fi
