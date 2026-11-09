#!/bin/bash
# 实验0 步骤4 补充：修正 cargo 镜像为 sparse 协议
# 说明：ustc 的 crates.io-index 已不再提供 git 协议仓库，
#       https://mirrors.ustc.edu.cn/crates.io-index/ 直接 git fetch 会报
#       "repository ... not found"，因此改用 cargo 官方推荐的 sparse 协议。
set -euo pipefail

mkdir -p "$HOME/.cargo"
cat > "$HOME/.cargo/config.toml" <<'EOF'
[source.crates-io]
replace-with = 'ustc'

[source.ustc]
registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"

[registries.ustc]
index = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"
EOF

cat "$HOME/.cargo/config.toml"

source "$HOME/.cargo/env"
echo "==> 验证 crates.io 换源是否可用"
cd /tmp && rm -rf _probe && cargo new _probe --bin -q && cd _probe
cargo add anyhow -q 2>&1 | tail -n 5 || true
cargo fetch 2>&1 | tail -n 5
