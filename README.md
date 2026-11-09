# 实验0：配置环境 —— 环境配置记录

本目录用于《操作系统》课程实验 0 的环境配置。

## 主机环境
- Windows 11 家庭版 26200
- Docker Desktop 4.43.1（WSL2 后端，已启用 虚拟机平台 VirtualMachinePlatform）
- 本地开发目录：`~\GardenerOS`，容器内通过 `/mnt` 访问

## 目录结构
```
GardenerOS/
├── .gitignore
├── rust-toolchain          # 锁定 nightly-2026-05-08
├── setup/
│   ├── 01_base_tools.sh    # dnf 安装 curl vim gcc 等
│   ├── 02_rust_env.sh      # rustup + nightly + ustc 镜像 + riscv64 目标
│   └── 03_qemu.sh          # 源码编译安装 qemu 11.0.0
└── README.md
```

## 配置步骤

### 1. 准备实验基础平台
```bash
docker pull openeuler/openeuler
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
```

### 4. 安装基础工具
```bash
dnf install -y curl vim gcc
# 等价于执行 setup/01_base_tools.sh
```

### 5. 配置 Rust
```bash
bash /mnt/setup/02_rust_env.sh
```
关键点：
- `~/.bashrc` 追加 ustc 镜像：
  - `export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static`
  - `export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup`
- 默认工具链切到 nightly
- `~/.cargo/config.toml` 换源 ustc
- 安装 `riscv64gc-unknown-none-elf` 目标、`cargo-binutils`、`llvm-tools-preview`、`rust-src`
- 工作目录放置 `rust-toolchain`，内容 `nightly-2026-05-08`

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
