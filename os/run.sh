#!/bin/bash
cd "$(dirname "$0")"
qemu-riscv64 target/riscv64gc-unknown-none-elf/debug/os
printf '[exit] %d\n' $?