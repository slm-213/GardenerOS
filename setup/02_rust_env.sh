#!/bin/bash
# 实验0 步骤4：配置 Rust 开发环境（在 openEuler 容器内以 root 执行）
# 说明：本脚本做 1~4 步；组件与目标安装见 02c/02e，cargo 换源见 02b。
set -euo pipefail

cd "$HOME"

echo "==> [1/4] 写入 ustc 镜像环境变量到 ~/.bashrc"
touch "$HOME/.bashrc"
grep -q 'RUSTUP_DIST_SERVER' "$HOME/.bashrc" || cat >> "$HOME/.bashrc" <<'EOF'

export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
EOF

export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup

echo "==> [2/4] 安装 rustup + rust（非交互）"
if [ ! -x "$HOME/.cargo/bin/rustup" ]; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path --profile minimal
fi
source "$HOME/.cargo/env"

echo "==> [3/4] 安装并切换 nightly"
rustup install nightly
rustup default nightly
rustc --version

echo "==> [4/4] 配置 cargo 镜像 ~/.cargo/config.toml（ustc sparse 协议）"
# 注意：ustc 的 crates.io-index 已不再提供 git 协议仓库，
# 指导书里的 https://mirrors.ustc.edu.cn/crates.io-index/ 会报
# fatal: repository ... not found，必须带 sparse+ 前缀。
mkdir -p "$HOME/.cargo"
cat > "$HOME/.cargo/config.toml" <<'EOF'
[source.crates-io]
replace-with = 'ustc'

[source.ustc]
registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"

[registries.ustc]
index = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"
EOF

echo "==> 完成。后续请继续执行 02b / 02c / 02d / 02e"
rustc --version
cargo --version
