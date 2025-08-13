#!/bin/bash

HOOK_DIR="$HOME/.githooks"
HOOK_FILE="$HOOK_DIR/pre-commit"

echo "🔍 Checking global Git hook installation..."

# 1. Check core.hooksPath
hooks_path=$(git config --get core.hooksPath)
if [ "$hooks_path" != "$HOOK_DIR" ]; then
    echo "❌ core.hooksPath is NOT set correctly."
    echo "Current: $hooks_path"
    echo "Fixing..."
    git config --global core.hooksPath "$HOOK_DIR"
    echo "✅ Fixed: core.hooksPath -> $HOOK_DIR"
else
    echo "✅ core.hooksPath is correctly set to $HOOK_DIR"
fi

# 2. Check if hook file exists
if [ ! -f "$HOOK_FILE" ]; then
    echo "❌ pre-commit hook does not exist in $HOOK_FILE"
    exit 1
else
    echo "✅ pre-commit hook exists."
fi

# 3. Check execute permission
if [ ! -x "$HOOK_FILE" ]; then
    echo "❌ pre-commit hook is NOT executable. Fixing..."
    chmod +x "$HOOK_FILE"
    echo "✅ Executable permission added."
else
    echo "✅ pre-commit hook is executable."
fi

# 4. Check ggrep on macOS
GREP_CMD="grep"
if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v ggrep &> /dev/null; then
        GREP_CMD="ggrep"
        echo "✅ ggrep found for macOS"
    else
        echo "⚠️ macOS: ggrep not found. Please install GNU grep:"
        echo "   brew install grep"
        echo "⚠️ Chinese detection test may fail without ggrep"
    fi
fi

# 5. Add debug line if not exists
if ! grep -q ">>> pre-commit hook test triggered" "$HOOK_FILE"; then
    sed -i '' -e '$i\
echo ">>> pre-commit hook test triggered"
' "$HOOK_FILE" 2>/dev/null || echo 'echo ">>> pre-commit hook test triggered"' >> "$HOOK_FILE"
    echo "✅ Added test output line to pre-commit hook."
fi

# 6. Test hook trigger with empty commit
echo "⚡ Testing if pre-commit hook triggers..."
git commit --allow-empty -m "hook test" >/dev/null 2>&1
echo "✅ Check above for '>>> pre-commit hook test triggered'"

# 7. Test Chinese detection
echo "⚡ Testing Chinese detection..."
TEST_FILE="hook_test_chinese.txt"
echo 'test中文' > "$TEST_FILE"
git add "$TEST_FILE" >/dev/null 2>&1
if output=$(git commit -m "hook self-test" 2>&1); then
    echo "❌ Self-test failed: hook did not reject Chinese characters."
    echo "Output:"
    echo "$output"
else
    if echo "$output" | grep -q "Chinese characters detected"; then
        echo "✅ Self-test passed: Chinese detection works!"
    else
        echo "❌ Self-test failed: Chinese detection did NOT trigger."
        echo "Output:"
        echo "$output"
    fi
fi
git reset HEAD "$TEST_FILE" >/dev/null 2>&1
rm "$TEST_FILE"

echo "✅ Self-check completed."
