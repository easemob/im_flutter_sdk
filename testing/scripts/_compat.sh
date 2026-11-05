# _compat.sh — shell 兼容守卫（各脚本在 set -euo pipefail 之前 source 本文件）。
# 目标环境: bash >= 3.2（macOS 系统自带即 3.2.57）。
# 脚本刻意不使用 bash 4+ 特性，新增代码也必须遵守，禁用清单：
#   mapfile / readarray、declare -A / local -A（关联数组）、
#   &>> 与 |& 管道、coproc、${var,,} / ${var^^} 大小写展开、${var@Q} 等。
# 原因: macOS 系统 bash 长期停留在 3.2，bash -n 只查语法查不出内建缺失。
if [ -z "${BASH_VERSION:-}" ]; then
  echo "${0##*/}: 需要 bash >= 3.2（当前 shell 不是 bash），请改用 bash 执行本脚本" >&2
  exit 64
fi
_compat_major="${BASH_VERSION%%.*}"
_compat_minor="$(printf '%s' "${BASH_VERSION#*.}" | cut -d. -f1)"
if [ -z "$_compat_minor" ] || [ "$_compat_major" -lt 3 ] \
  || { [ "$_compat_major" -eq 3 ] && [ "$_compat_minor" -lt 2 ]; }; then
  echo "${0##*/}: 需要 bash >= 3.2，当前为 bash ${BASH_VERSION}" >&2
  exit 64
fi
unset _compat_major _compat_minor
