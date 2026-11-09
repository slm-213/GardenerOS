#!/bin/bash
# 实验0 步骤3：容器内安装必要工具（在 openEuler 容器内以 root 执行）
set -euo pipefail

echo "==> [1/4] 更新 dnf 缓存"
dnf makecache -y || true

echo "==> [2/4] 安装基础工具 curl vim gcc"
dnf install -y curl vim gcc git tar xz

echo "==> [3/4] 校验"
curl --version | head -n 1
vim --version | head -n 1
gcc --version | head -n 1
git --version

echo "==> [4/4] done"
