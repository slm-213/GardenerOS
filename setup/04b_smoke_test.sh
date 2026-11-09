#!/bin/bash
# 冒烟测试：用 riscv64gc-unknown-none-elf 目标编译一个 no_std 程序，
# 再用 rust-objcopy 转成二进制，确认工具链真正可用。
set -euo pipefail
source "$HOME/.cargo/env"

cd /tmp
rm -rf smoke
mkdir -p smoke/src
cd smoke

cat > Cargo.toml <<'EOF'
[package]
name = "smoke"
version = "0.1.0"
edition = "2021"

[[bin]]
name = "smoke"
path = "src/main.rs"

[profile.dev]
panic = "abort"

[profile.release]
panic = "abort"
EOF

cat > src/main.rs <<'EOF'
#![no_std]
#![no_main]

use core::panic::PanicInfo;

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

#[no_mangle]
pub extern "C" fn _start() -> ! {
    let ptr = 0x1000_0000 as *mut u8;
    unsafe { core::ptr::write_volatile(ptr, b'O'); }
    loop {}
}
EOF

mkdir -p .cargo
cat > .cargo/config.toml <<'EOF'
[build]
target = "riscv64gc-unknown-none-elf"

[target.riscv64gc-unknown-none-elf]
rustflags = ["-C", "link-arg=-Ttext=0x80200000"]
EOF

echo "==> cargo build --release"
cargo build --release

echo "==> 产物"
ls -l target/riscv64gc-unknown-none-elf/release/smoke

echo "==> rust-objcopy -> smoke.bin"
rust-objcopy --strip-all target/riscv64gc-unknown-none-elf/release/smoke -O binary smoke.bin
ls -l smoke.bin

echo "==> rust-readobj 头信息"
rust-readobj -h target/riscv64gc-unknown-none-elf/release/smoke | head -n 20
