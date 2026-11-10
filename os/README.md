# os —— 实验1：独立的可执行程序

一个不依赖 Rust 标准库（`std`）的 riscv64 程序，验证「脱离操作系统运行时、
只靠 `ecall` 系统调用与操作系统交互」这条最小路径。

## 目录结构

```
os/
├── .cargo/config.toml     # 指定默认编译目标为 riscv64gc-unknown-none-elf
├── Cargo.toml             # edition = 2021（2024 版要求 unsafe(no_mangle)）
└── src/
    ├── main.rs            # no_std / no_main、_start 入口、ecall 系统调用封装
    └── console.rs         # 实现 core::fmt::Write，提供 print! / println!
```

## 关键点

| 项 | 说明 |
|---|---|
| `#![no_std]` | 不链接 std，避免依赖 Linux 用户态运行时（`crt1.o`、libc 等） |
| `#![no_main]` | 不用 Rust 默认的 `main` 入口，C 运行时没有地方调用它 |
| `#[panic_handler]` | std 里自带的 panic 处理函数随之消失，必须自己提供 |
| `#[no_mangle] extern "C" fn _start` | 让链接器生成名为 `_start` 的符号，作为 ELF 入口 |
| `asm!("ecall", in("x17") id, ...)` | 直接发起系统调用：a7 放调用号，a0~a2 放参数，返回值在 a0 |
| `sys_exit(9)` | 调用 93 号系统调用退出，否则 `_start` 返回后会落到非法地址，段错误 |
| `sys_write(1, ..)` | 调用 64 号系统调用往 stdout 写字，是实现 `println!` 的基础 |

## 编译与运行

```bash
cargo build
qemu-riscv64 target/riscv64gc-unknown-none-elf/debug/os
# 输出: Hello, world!
# 退出码: 9
```

## 踩坑记录

1. **edition 2024 的 `no_mangle`**：`cargo new` 默认生成 `edition = "2024"`，
   该版本起 `#[no_mangle]` 属于 unsafe 属性，必须写成 `#[unsafe(no_mangle)]`，
   否则报 `error: unsafe attribute used without unsafe`（E0583）。
   本实验改成 `edition = "2021"`，与课程指导给的代码保持一致。
2. **没有 `_start` 时编译产物是“空程序”**：编译器找不到入口，不生成 `.text`
   段，产物 4496 字节全是调试信息，`rust-objdump -S` 除文件头外没有任何输出。
3. **`_start` 里只有 `loop {}` 不会退出**：`timeout 3 qemu-riscv64 ...` 返回 124。
4. **去掉 `loop` 后段错误**：`_start` 编译成一条 `ret`，返回地址来自栈上
   未初始化的值，跳飞后触发 Segmentation fault（exit 139）。
