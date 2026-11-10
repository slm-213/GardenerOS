//! 实验1：独立的可执行程序
//!
//! 这是一个不依赖 Rust 标准库（std）的 riscv64 用户态程序。没有 std，
//! 就没有现成的 println! / 程序退出逻辑，所有与操作系统打交道的动作
//! 都要自己通过 RISC-V 的 `ecall` 指令发起系统调用完成。

#![no_std]
#![no_main]

mod console;

use core::arch::asm;
use core::panic::PanicInfo;

/// Linux 系统调用号：exit
const SYSCALL_EXIT: usize = 93;
/// Linux 系统调用号：write
const SYSCALL_WRITE: usize = 64;

/// 发起一次系统调用。
///
/// RISC-V 的约定是：系统调用号放在 x17（a7），参数依次放在 x10~x12（a0~a2），
/// 返回值仍然从 x10 取回。
fn syscall(id: usize, args: [usize; 3]) -> isize {
    let mut ret: isize;
    unsafe {
        asm!("ecall",
             in("x10") args[0],
             in("x11") args[1],
             in("x12") args[2],
             in("x17") id,
             lateout("x10") ret
        );
    }
    ret
}

/// 退出当前进程，xstate 为退出码。
pub fn sys_exit(xstate: i32) -> isize {
    syscall(SYSCALL_EXIT, [xstate as usize, 0, 0])
}

/// 向文件描述符 fd 写一段字节。
pub fn sys_write(fd: usize, buffer: &[u8]) -> isize {
    syscall(SYSCALL_WRITE, [fd, buffer.as_ptr() as usize, buffer.len()])
}

/// 没有 std 时 panic 的处理函数必须自己提供。
#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

#[no_mangle]
extern "C" fn _start() {
    println!("Hello, world!");
    sys_exit(9);
}
