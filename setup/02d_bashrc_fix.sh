#!/bin/bash
# 修正 /root/.bashrc 中的 cargo 环境变量引入行
set -euo pipefail

# 删除之前可能写坏的行
sed -i '/cargo\/env/d' /root/.bashrc 2>/dev/null || true

cat >> /root/.bashrc <<'EOF'

# Rust 环境
. "$HOME/.cargo/env"
EOF

echo "==> 当前 .bashrc 末尾："
tail -n 15 /root/.bashrc
echo "==> 验证 login shell 中 rustc："
bash -lc 'rustc --version; cargo --version'
