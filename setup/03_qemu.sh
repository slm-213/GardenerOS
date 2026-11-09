#!/bin/bash
# 实验0 步骤5：安装 qemu 11.0.0（在 openEuler 容器内以 root 执行）
# 说明：download.qemu.org 在本机网络下不可达
#       （curl: (35) OpenSSL SSL_connect: SSL_ERROR_SYSCALL in connection to download.qemu.org:443），
#       华为云镜像该路径实际返回的是网页而不是压缩包，
#       因此改用 GitLab 官方仓库的 v11.0.0 源码归档（与官方 tarball 同一份源码）。
set -euo pipefail

cd "$HOME"

echo "==> [1/6] 安装编译依赖组"
dnf groupinstall -y "Development Tools"
dnf install -y autoconf automake gcc gcc-c++ kernel-devel curl libmpc-devel mpfr-devel gmp-devel \
               glib2 glib2-devel make cmake gawk bison flex texinfo gperf libtool patchutils bc \
               python3 ninja-build wget xz python3-tomli python3-sphinx

echo "==> [2/6] 下载 qemu v11.0.0 源码"
cd "$HOME"
if [ ! -f qemu-11.0.0.tar.gz ]; then
  curl -L --fail -o qemu-11.0.0.tar.gz \
    https://gitlab.com/qemu-project/qemu/-/archive/v11.0.0/qemu-v11.0.0.tar.gz
fi
ls -lh qemu-11.0.0.tar.gz

echo "==> [3/6] 解压"
rm -rf qemu-11.0.0 qemu-v11.0.0
tar xzf qemu-11.0.0.tar.gz
mv qemu-v11.0.0 qemu-11.0.0

echo "==> [4/6] configure（仅 riscv64 目标）"
cd qemu-11.0.0
./configure --target-list=riscv64-softmmu,riscv64-linux-user

echo "==> [5/6] make install"
make -j"$(nproc)" install

echo "==> [6/6] 验证"
qemu-system-riscv64 --version
qemu-riscv64 --version
