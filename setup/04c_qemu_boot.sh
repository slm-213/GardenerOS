#!/bin/bash
# 用 QEMU 实际跑一下编译出来的 riscv64 裸机程序，确认模拟器可用。
# 程序向 0x1000_0000（QEMU virt 机器的 UART0）写 'O'，然后死循环。
set -uo pipefail
source "$HOME/.cargo/env"

cd /tmp/smoke
# QEMU 的 -kernel 会把镜像加载到 0x8000_0000，所以按该地址重新链接
sed -i 's/0x80200000/0x80000000/' .cargo/config.toml
cargo build --release
rust-objcopy --strip-all target/riscv64gc-unknown-none-elf/release/smoke -O binary smoke.bin
ls -l smoke.bin

echo "==> 运行 qemu-system-riscv64（3 秒后自动结束）"
timeout 3 qemu-system-riscv64 -machine virt -m 128M -nographic -bios none -kernel smoke.bin
rc=$?
echo
echo "==> 退出码 $rc（124 = 被 timeout 正常终止，即程序在死循环，符合预期）"
