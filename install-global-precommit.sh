#!/bin/bash

HOOK_DIR="$HOME/.githooks"
HOOK_FILE="$HOOK_DIR/pre-commit"
IGNORE_FILE="$HOOK_DIR/ignore-chinese.txt"

echo "🔧 Installing global Git pre-commit hook for Chinese detection..."

# 1. Create hook directory
mkdir -p "$HOOK_DIR"

# 2. Set Git global hooks path
git config --global core.hooksPath "$HOOK_DIR"
echo "✅ core.hooksPath set to $HOOK_DIR"

# 3. Check ggrep on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v ggrep &> /dev/null; then
        echo "⚠️ macOS detected. Please install GNU grep:"
        echo "   brew install grep"
    else
        echo "✅ ggrep found"
    fi
fi

# 4. Create ignore file if not exists
if [ ! -f "$IGNORE_FILE" ]; then
    cat > "$IGNORE_FILE" <<EOL
# Ignore patterns for Chinese detection
README_CN.md
*.md
docs/*
EOL
    echo "✅ Created ignore file: $IGNORE_FILE"
fi

# 5. Install pre-commit hook
cat > "$HOOK_FILE" << 'EOF'
#!/bin/bash

IGNORE_FILE="$HOME/.githooks/ignore-chinese.txt"

# Auto-detect grep command
if command -v ggrep &> /dev/null; then
    GREP_CMD="ggrep"
else
    GREP_CMD="grep"
fi

# Support ignore file with glob patterns
should_ignore() {
    local file="$1"
    if [ -f "$IGNORE_FILE" ]; then
        while IFS= read -r pattern; do
            [[ "$pattern" =~ ^#.*$ || -z "$pattern" ]] && continue
            case "$file" in
                $pattern)
                    return 0
                    ;;
            esac
        done < "$IGNORE_FILE"
    fi
    return 1
}

files=$(git diff --cached --name-only --diff-filter=ACM)
has_chinese=0

for file in $files; do
    if should_ignore "$file"; then
        echo "✅ Skipping ignored file: $file"
        continue
    fi

    if file "$file" | grep -q "text"; then
        matches=$($GREP_CMD -n -P "[\x{4e00}-\x{9fff}]" "$file" 2>/dev/null)
        if [ -n "$matches" ]; then
            echo "❌ Chinese characters detected in file: $file"
            echo "$matches"
            has_chinese=1
        fi
    fi
done

if [ $has_chinese -eq 1 ]; then
    echo "⚠️ Commit rejected. Please remove Chinese characters before committing."
    exit 1
fi

echo ">>> pre-commit hook triggered"
exit 0
EOF

# 6. Make hook executable
chmod +x "$HOOK_FILE"
echo "✅ Pre-commit hook installed successfully!"

# 7. Self-test Chinese detection
echo "⚡ Running self-test for Chinese detection..."
TEST_FILE="hook_test_chinese.txt"
echo 'test中文' > "$TEST_FILE"
git add "$TEST_FILE" >/dev/null 2>&1
# Capture both stdout and stderr, expect non-zero exit code
if output=$(git commit -m "hook self-test" 2>&1); then
    echo "❌ Self-test failed: hook did not reject Chinese characters."
    echo "$output"
else
    # Hook should reject and return non-zero, check if it detected Chinese
    if echo "$output" | grep -q "Chinese characters detected"; then
        echo "✅ Self-test passed: Chinese detection works!"
    else
        echo "❌ Self-test failed: hook did not detect Chinese."
        echo "$output"
    fi
fi
git reset HEAD "$TEST_FILE" >/dev/null 2>&1
rm "$TEST_FILE"

echo "✅ Installation and self-check completed."
