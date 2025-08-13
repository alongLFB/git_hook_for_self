# Git Hooks for Chinese Character Detection

A set of shell scripts to automatically detect and prevent Chinese characters in Git commits using global pre-commit hooks.

## Features

- 🔍 **Automatic Detection**: Detects Chinese characters in staged files before commit
- 🌍 **Cross-Platform**: Works on both macOS (with ggrep) and Linux (with grep)
- 📝 **Configurable Ignore**: Support for ignore patterns to skip specific files/directories
- ⚡ **Easy Installation**: One-command setup with automatic validation
- 🧪 **Self-Testing**: Built-in tests to verify hook functionality

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/alongLFB/git_hook_for_self.git
cd git_hook_for_self

# Make scripts executable
chmod +x install-global-precommit.sh check-global-hook.sh

# Install the global pre-commit hook
./install-global-precommit.sh
```

### macOS Prerequisites

If you're on macOS, install GNU grep for better Unicode support:

```bash
brew install grep
```

### Validation

Check if the hook is working correctly:

```bash
./check-global-hook.sh
```

## How It Works

1. **Global Hook**: Sets up a global Git pre-commit hook that applies to all repositories
2. **Chinese Detection**: Uses regex pattern `[\x{4e00}-\x{9fff}]` to detect Chinese characters
3. **File Filtering**: Only checks text files and respects ignore patterns
4. **Commit Prevention**: Blocks commits containing Chinese characters with detailed error messages

## Configuration

### Ignore Patterns

Edit `~/.githooks/ignore-chinese.txt` to customize which files to skip:

```bash
# Ignore patterns for Chinese detection
README_CN.md
*.md
docs/*
install-global-precommit.sh
check-global-hook.sh
```

Supported patterns:
- Exact filenames: `README_CN.md`
- Wildcards: `*.md`, `docs/*`
- Directory patterns: `docs/*`

### Hook Location

- Hook file: `~/.githooks/pre-commit`
- Ignore file: `~/.githooks/ignore-chinese.txt`
- Git config: `core.hooksPath = ~/.githooks`

## Usage Examples

### Successful Commit (English only)
```bash
echo "Hello World" > test.txt
git add test.txt
git commit -m "Add test file"
# ✅ Commit succeeds
```

### Blocked Commit (Contains Chinese)
```bash
echo "你好世界" > test.txt
git add test.txt
git commit -m "Add test file"
# ❌ Chinese characters detected in file: test.txt
# 1:你好世界
# ⚠️ Commit rejected. Please remove Chinese characters before committing.
```

### Ignored File (In ignore list)
```bash
echo "你好世界" > README_CN.md
git add README_CN.md
git commit -m "Add Chinese README"
# ✅ Skipping ignored file: README_CN.md
# ✅ Commit succeeds
```

## Troubleshooting

### Hook Not Triggering
- Check if `core.hooksPath` is set: `git config --get core.hooksPath`
- Verify hook exists and is executable: `ls -la ~/.githooks/pre-commit`
- Run validation script: `./check-global-hook.sh`

### Chinese Detection Not Working
- Ensure ggrep is installed on macOS: `brew install grep`
- Test regex manually: `ggrep -P "[\x{4e00}-\x{9fff}]" yourfile.txt`
- Check file encoding (UTF-8 recommended)

### Permission Issues
```bash
chmod +x ~/.githooks/pre-commit
```

## Scripts

- **`install-global-precommit.sh`**: Main installation script
  - Sets up global hooks directory
  - Configures Git to use global hooks
  - Creates ignore patterns file
  - Installs and tests the pre-commit hook

- **`check-global-hook.sh`**: Validation and troubleshooting script
  - Verifies hook installation
  - Checks prerequisites (ggrep on macOS)
  - Tests hook functionality
  - Fixes common issues automatically

## Requirements

- Git 2.9+ (for global hooks support)
- Bash shell
- grep with Perl regex support:
  - macOS: `ggrep` (install via `brew install grep`)
  - Linux: `grep` (usually pre-installed)

## License

MIT License - feel free to use and modify as needed.

## Contributing

1. Fork the repository
2. Create your feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

[中文说明](README_CN.md) | [English](README.md)
