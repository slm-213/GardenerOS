#!/bin/bash
# 为 rust-toolchain 指定的固定版本补齐组件
# 说明：/mnt/rust-toolchain 内容为 nightly-2026-05-08，进入该目录后 rustup 会
#       自动切换到该 toolchain；因此 riscv64 目标、rust-src、llvm-tools 必须
#       装在这个 toolchain 上，否则在实验目录里 cargo build 会失败。
set -euo pipefail
source "$HOME/.cargo/env"

TC="nightly-2026-05-08"

echo "==> 安装 $TC"
rustup toolchain install "$TC" --profile minimal
rustup target add riscv64gc-unknown-none-elf --toolchain "$TC"
rustup component add llvm-tools-preview --toolchain "$TC"
rustup component add rust-src --toolchain "$TC"

echo "==> 组件清单"
rustup component list --installed --toolchain "$TC"
rustup target list --installed --toolchain "$TC"

echo "==> 在实验目录内验证（应自动使用 rust-toolchain 指定的版本）"
cd /mnt
rustc --version
cargo --version
