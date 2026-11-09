#!/bin/bash
# 实验0 步骤4 补充：安装 riscv64 目标与 Rust 相关组件
set -euo pipefail
source "$HOME/.cargo/env"

echo "==> rustup target add riscv64gc-unknown-none-elf"
rustup target add riscv64gc-unknown-none-elf

echo "==> rustup component add llvm-tools-preview"
rustup component add llvm-tools-preview

echo "==> rustup component add rust-src"
rustup component add rust-src

echo "==> cargo install cargo-binutils"
cargo install cargo-binutils

echo "==> 汇总"
rustc --version
cargo --version
rustup target list --installed
rustup component list --installed
~/.cargo/bin/rust-objcopy --version
