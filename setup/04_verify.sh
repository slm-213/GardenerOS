#!/bin/bash
echo "===== 0. 系统信息 ====="
cat /etc/os-release | head -3
echo
echo "===== 1. 基础工具 ====="
curl --version | head -1
vim --version | head -1
gcc --version | head -1
git --version
echo
echo "===== 2. Rust ====="
export PATH="$HOME/.cargo/bin:$PATH"
rustc --version
cargo --version
rustup --version 2>/dev/null | head -1
echo "-- toolchain --"
rustup toolchain list
echo "-- targets --"
rustup target list --installed
echo "-- components --"
rustup component list --installed
echo "-- cargo-binutils --"
rust-objcopy --version | head -2
echo "-- cargo config --"
cat "$HOME/.cargo/config.toml"
echo
echo "===== 3. QEMU ====="
which qemu-system-riscv64 qemu-riscv64
qemu-system-riscv64 --version | head -1
qemu-riscv64 --version | head -1
echo
echo "===== 4. 挂载点 ====="
ls -la /mnt
echo
echo "===== 5. rust-toolchain 文件 ====="
cat /mnt/rust-toolchain 2>/dev/null || echo "(缺失)"
