#!/bin/bash
# 实验0 步骤4：配置 Rust 开发环境（在 openEuler 容器内以 root 执行）
set -euo pipefail

cd "$HOME"

echo "==> [1/6] 写入 ustc 镜像环境变量到 ~/.bashrc"
touch "$HOME/.bashrc"
grep -q 'RUSTUP_DIST_SERVER' "$HOME/.bashrc" || cat >> "$HOME/.bashrc" <<'EOF'

export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
EOF

export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup

echo "==> [2/6] 安装 rustup + rust（非交互）"
if [ ! -x "$HOME/.cargo/bin/rustup" ]; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path --profile minimal
fi
source "$HOME/.cargo/env"
rustc --version

echo "==> [3/6] 安装并切换 nightly"
rustup install nightly
rustup default nightly
rustc --version

echo "==> [4/6] 配置 cargo 镜像 ~/.cargo/config.toml"
mkdir -p "$HOME/.cargo"
cat > "$HOME/.cargo/config.toml" <<'EOF'
[source.crates-io]
replace-with = 'ustc'

[source.ustc]
registry = "https://mirrors.ustc.edu.cn/crates.io-index/"

[registries.ustc]
index = "https://mirrors.ustc.edu.cn/crates.io-index/"
EOF

echo "==> [5/6] 安装 riscv64 目标、cargo-binutils、llvm-tools、rust-src"
rustup target add riscv64gc-unknown-none-elf
cargo install cargo-binutils
rustup component add llvm-tools-preview
rustup component add rust-src

echo "==> [6/6] 版本汇总"
rustc --version
cargo --version
rustup target list --installed
cargo binutils --version 2>/dev/null || echo "(cargo-binutils 已安装)"
