# Git 中文字符检测钩子

> [中文说明](README_CN.md) | [English](README.md)

一套用于自动检测和阻止Git提交中包含中文字符的shell脚本，使用全局pre-commit钩子实现。

## 特性

- 🔍 **自动检测**: 在提交前自动检测暂存文件中的中文字符
- 🌍 **跨平台**: 支持macOS (使用ggrep) 和Linux (使用grep)
- 📝 **可配置忽略**: 支持忽略模式，可跳过特定文件/目录
- ⚡ **一键安装**: 单命令设置，自动验证功能
- 🧪 **自检测试**: 内置测试验证钩子功能

## 快速开始

### 安装

```bash
# 克隆仓库
git clone https://github.com/alongLFB/git_hook_for_self.git
cd git_hook_for_self

# 给脚本添加执行权限
chmod +x install-global-precommit.sh check-global-hook.sh

# 安装全局pre-commit钩子
./install-global-precommit.sh
```

### macOS 前置条件

如果你使用macOS，需要安装GNU grep以获得更好的Unicode支持：

```bash
brew install grep
```

### 验证

检查钩子是否正常工作：

```bash
./check-global-hook.sh
```

## 工作原理

1. **全局钩子**: 设置适用于所有仓库的全局Git pre-commit钩子
2. **中文检测**: 使用正则表达式 `[\x{4e00}-\x{9fff}]` 检测中文字符
3. **文件过滤**: 只检查文本文件并遵循忽略模式
4. **阻止提交**: 当检测到中文字符时阻止提交并显示详细错误信息

## 配置

### 忽略模式

编辑 `~/.githooks/ignore-chinese.txt` 来自定义要跳过的文件：

```bash
# 中文检测的忽略模式
README_CN.md
*.md
docs/*
install-global-precommit.sh
check-global-hook.sh
```

支持的模式：

- 精确文件名: `README_CN.md`
- 通配符: `*.md`, `docs/*`
- 目录模式: `docs/*`

### 钩子位置

- 钩子文件: `~/.githooks/pre-commit`
- 忽略文件: `~/.githooks/ignore-chinese.txt`
- Git配置: `core.hooksPath = ~/.githooks`

## 使用示例

### 成功提交 (仅英文)

```bash
echo "Hello World" > test.txt
git add test.txt
git commit -m "Add test file"
# ✅ 提交成功
```

### 被阻止的提交 (包含中文)

```bash
echo "你好世界" > test.txt
git add test.txt
git commit -m "Add test file"
# ❌ Chinese characters detected in file: test.txt
# 1:你好世界
# ⚠️ Commit rejected. Please remove Chinese characters before committing.
```

### 被忽略的文件 (在忽略列表中)

```bash
echo "你好世界" > README_CN.md
git add README_CN.md
git commit -m "Add Chinese README"
# ✅ Skipping ignored file: README_CN.md
# ✅ 提交成功
```

## 故障排除

### 钩子未触发

- 检查 `core.hooksPath` 是否设置: `git config --get core.hooksPath`
- 验证钩子存在且可执行: `ls -la ~/.githooks/pre-commit`
- 运行验证脚本: `./check-global-hook.sh`

### 中文检测不工作

- 确保在macOS上安装了ggrep: `brew install grep`
- 手动测试正则表达式: `ggrep -P "[\x{4e00}-\x{9fff}]" yourfile.txt`
- 检查文件编码 (推荐UTF-8)

### 权限问题

```bash
chmod +x ~/.githooks/pre-commit
```

## 脚本说明

- **`install-global-precommit.sh`**: 主安装脚本
  - 设置全局钩子目录
  - 配置Git使用全局钩子
  - 创建忽略模式文件
  - 安装和测试pre-commit钩子

- **`check-global-hook.sh`**: 验证和故障排除脚本
  - 验证钩子安装
  - 检查前置条件 (macOS上的ggrep)
  - 测试钩子功能
  - 自动修复常见问题

## 系统要求

- Git 2.9+ (支持全局钩子)
- Bash shell
- 支持Perl正则表达式的grep:
  - macOS: `ggrep` (通过 `brew install grep` 安装)
  - Linux: `grep` (通常预装)

## 许可证

MIT许可证 - 可自由使用和修改。

## 贡献

1. Fork 仓库
2. 创建你的功能分支
3. 进行修改
4. 充分测试
5. 提交pull request
