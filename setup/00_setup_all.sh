#!/bin/bash
# 一键执行全部环境配置（在 openEuler 容器内以 root 执行）
# 用法：bash /mnt/setup/00_setup_all.sh
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for s in 01_base_tools.sh \
         02_rust_env.sh \
         02b_cargo_mirror.sh \
         02c_rust_components.sh \
         02d_bashrc_fix.sh \
         02e_pinned_toolchain.sh \
         03_qemu.sh \
         04_verify.sh; do
  echo
  echo "############ 执行 $s ############"
  bash "$DIR/$s"
done
