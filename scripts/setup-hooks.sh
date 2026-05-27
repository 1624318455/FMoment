#!/bin/bash

# FMoment Git Hooks 设置脚本
# 用于设置 pre-commit hook

set -e

echo "🔧 设置 Git Hooks..."

# 检查是否在 Git 仓库中
if [ ! -d ".git" ]; then
  echo "❌ 错误：不在 Git 仓库中"
  exit 1
fi

# 创建 hooks 目录（如果不存在）
mkdir -p .git/hooks

# 复制 pre-commit hook
cp config/gates/pre-commit.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

echo "✅ Git Hooks 设置完成！"
echo "📝 Pre-commit hook 已安装到 .git/hooks/pre-commit"
