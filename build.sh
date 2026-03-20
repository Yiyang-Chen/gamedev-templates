#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

bash install.sh

rm -rf dist

echo "[build] Building production bundle..."
pnpm run build

# 强制覆盖所有 public 静态文件（解决 NFS mtime 缓存问题）
echo "📋 强制更新静态资源..."
cp -rf public/* dist/

echo "✅ 构建完成！"  
