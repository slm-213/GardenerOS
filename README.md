# 实验0：配置环境 —— 环境配置记录

本目录用于《操作系统》课程实验 0 的环境配置：openEuler 容器 + Rust(riscv64) + QEMU 11.0.0。

## 主机环境
- Windows 11（启用「虚拟机平台 VirtualMachinePlatform」，Docker Desktop 走 WSL2 后端）
- Docker Desktop 4.43.1 / Docker 28.3.0
- 本地开发目录：`~\GardenerOS`，容器内通过 `/mnt` 访问

## 容器内环境
- `openEuler 24.03 (LTS-SP4)`
- curl 8.4.0 / VIM 9.0 / gcc 12.3.1 / git 2.54.0
- rustc 1.97.0-nightly（`nightly-2026-05-08`，由 `rust-toolchain` 文件锁定）
- 目标 `riscv64gc-unknown-none-elf`、组件 `rust-src`、`llvm-tools-preview`、`cargo-binutils`
- QEMU 11.0.0（源码编译，`/usr/local/bin`）

## 目录结构
```
GardenerOS/
├── .gitignore
├── rust-toolchain              # 锁定 nightly-2026-05-08
├── setup/
│   ├── 01_base_tools.sh        # dnf 安装 curl vim gcc 等基础工具
│   ├── 02_rust_env.sh          # rustup + nightly + ustc 镜像
│   ├── 02b_cargo_mirror.sh     # cargo 换 ustc sparse 源
│   ├── 02c_rust_components.sh  # riscv64 目标 + 组件 + cargo-binutils
│   ├── 02d_bashrc_fix.sh       # .bashrc 引入 ~/.cargo/env
│   ├── 02e_pinned_toolchain.sh # 为 rust-toolchain 指定版本补齐组件
│   ├── 03_qemu.sh              # 源码编译安装 QEMU 11.0.0
│   ├── 04_verify.sh            # 汇总校验
│   ├── 04b_smoke_test.sh       # no_std 冒烟测试（编译到 riscv64）
│   └── 04c_qemu_boot.sh        # 用 QEMU 实际运行冒烟测试产物
└── README.md
```

## 配置步骤

### 1. 准备实验基础平台
```bash
docker pull openeuler/openeuler
```
国内网络直连 Docker Hub 会超时，可用镜像站拉取后改 tag：
```bash
docker pull docker.m.daocloud.io/openeuler/openeuler
docker tag docker.m.daocloud.io/openeuler/openeuler:latest openeuler/openeuler:latest
```

### 2. 创建本地开发目录与 git
```bash
mkdir ~/GardenerOS/
cd ~/GardenerOS/
git init
touch .gitignore
git add .
git commit -m "init"
git remote add origin <你的远程仓库>
git push --all
```

### 3. 创建容器（bind mount）
```bash
cd ~/GardenerOS
docker run -it --name gardener --mount type=bind,source=$(pwd),destination=/mnt openeuler/openeuler
# 之后重新进入：
docker restart gardener
docker attach gardener
# 从 attach 脱离：Ctrl+P 然后 Ctrl+Q
```

### 4. 安装基础工具
```bash
dnf install -y curl vim gcc
# 等价于执行 bash /mnt/setup/01_base_tools.sh
```

### 5. 配置 Rust
```bash
bash /mnt/setup/02_rust_env.sh
bash /mnt/setup/02b_cargo_mirror.sh
bash /mnt/setup/02c_rust_components.sh
bash /mnt/setup/02d_bashrc_fix.sh
bash /mnt/setup/02e_pinned_toolchain.sh
```
关键点：
- `~/.bashrc` 追加 ustc 镜像：
  - `export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static`
  - `export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup`
- 默认工具链切到 nightly
- `~/.cargo/config.toml` 换源 ustc（**必须用 sparse 协议**，见下方「踩坑记录」）
- 安装 `riscv64gc-unknown-none-elf` 目标、`cargo-binutils`、`llvm-tools-preview`、`rust-src`
- 工作目录放置 `rust-toolchain`，内容 `nightly-2026-05-08`；该版本需单独补齐上述目标与组件

### 6. 安装 QEMU 11.0.0
```bash
bash /mnt/setup/03_qemu.sh
```
验证：
```bash
qemu-system-riscv64 --version
qemu-riscv64 --version
```

### 7. 保存为自有镜像
```bash
docker commit -m "New configured environment" -a "Di Zhang" <容器ID> myopeneuler
```

## 踩坑记录

1. **Docker 起不来**：`docker info` 报 `open //./pipe/dockerDesktopLinuxEngine: The system cannot find the file specified`，
   `wsl -d docker-desktop` 报 `HCS_E_SERVICE_NOT_AVAILABLE`。根因是 Windows 可选功能「虚拟机平台」
   （`VirtualMachinePlatform`）被禁用，导致 `vmcompute` / `hns` 服务缺失。启用并重启后解决：
   ```powershell
   dism /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   ```

2. **Docker Hub 拉不动**：`registry-1.docker.io` 超时，改用 `docker.m.daocloud.io` 镜像站。

3. **ustc 的 crates.io-index 不再支持 git 协议**：按实验指导写
   `registry = "https://mirrors.ustc.edu.cn/crates.io-index/"` 会报
   `fatal: repository ... not found`，必须改用 sparse：
   ```toml
   [source.crates-io]
   replace-with = 'ustc'
   [source.ustc]
   registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"
   [registries.ustc]
   index = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"
   ```

4. **download.qemu.org 不可达**：容器内 `curl: (35) OpenSSL SSL_connect: SSL_ERROR_SYSCALL`。
   国内各镜像站（tuna/ustc/aliyun/163/bfsu/nju/lzu/腾讯云/华为云）均无 qemu 目录；
   `mirrors.huaweicloud.com/qemu/qemu-11.0.0.tar.xz` 的 HEAD 虽然返回 200，下载到的却是 HTML 网页
   （解压报 `xz: File format not recognized`）——**HEAD 200 不等于文件存在，要看 content-type 和实际大小**。
   最终改用 GitLab 官方仓库归档：
   `https://gitlab.com/qemu-project/qemu/-/archive/v11.0.0/qemu-v11.0.0.tar.gz`（40MB），
   源码内容与官方 tarball 一致，编译后版本号为 11.0.0。

5. **riscv64 目标装错工具链**：`rustup target add` 默认加到 default toolchain（nightly-2026-11-07），
   但实验目录里的 `rust-toolchain` 会强制切到 `nightly-2026-05-08`，导致在该目录下编译找不到
   `riscv64gc-unknown-none-elf`。需要用 `--toolchain nightly-2026-05-08` 给指定版本单独安装。

## 验证结果

```
rustc 1.97.0-nightly (f964de49b 2026-05-07)     # 在 /mnt 下由 rust-toolchain 自动切换
riscv64gc-unknown-none-elf                      # 目标已安装
QEMU emulator version 11.0.0
qemu-riscv64 version 11.0.0
```
冒烟测试（`setup/04b_smoke_test.sh` + `setup/04c_qemu_boot.sh`）：编译一个 `#![no_std]` 的 riscv64 程序，
`rust-objcopy` 转成 14 字节裸二进制，用 `qemu-system-riscv64 -machine virt -nographic -bios none -kernel smoke.bin`
运行，串口成功输出 `O`，说明「Rust 交叉编译 → objcopy → QEMU 运行」整条链路可用。

最终镜像：`myopeneuler:latest`（4.66GB），容器名 `gardener`。
