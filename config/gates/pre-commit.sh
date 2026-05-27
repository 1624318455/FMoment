#!/bin/bash

# FMoment Pre-commit Hook
# 在提交前执行代码检查

set -e

echo "🔍 执行 pre-commit 检查..."

# 1. 静态分析
echo "📊 运行静态分析..."
flutter analyze --no-pub

# 2. 格式检查
echo "🎨 检查代码格式..."
dart format --output=none --set-exit-if-changed .

# 3. 测试
echo "🧪 运行测试..."
flutter test

echo "✅ Pre-commit 检查通过！"
