#!/usr/bin/env bash
set -euo pipefail

# Local Deps Agent — 规范化本地资产并保持仅启用本地依赖（默认 dry-run）
#
# 用法示例：
#   im_flutter_sdk/scripts/agents/local_deps_agent.sh \
#     --jar hyphenatechat_4.20.0.jar --rename-dir --apply --run-build

ROOT_DIR=$(cd "$(dirname "$0")/../.." && pwd)
ANDROID_DIR="$ROOT_DIR/../im_flutter_sdk_android/android"
LIBS_BASE="$ANDROID_DIR/libs"
SDK_DIR_VERPATTERN="$LIBS_BASE/easemob-sdk-" # 例如 easemob-sdk-4.20.0
SDK_DIR="$LIBS_BASE/easemob-sdk"
JNI_DIR="$SDK_DIR/libs"
SPECKIT="$ROOT_DIR/scripts/speckit.sh"

APPLY=0
RUN_BUILD=0
ANDROID_JAR=""
RENAME_DIR=0

usage(){
  cat <<USAGE
Local Deps Agent — 规范化本地资产并启用本地依赖（dry-run 默认）

选项:
  --jar <filename>          例如 hyphenatechat_4.20.0.jar（放于 libs/easemob-sdk/libs/ 下）
  --rename-dir              如存在 easemob-sdk-<ver> 则重命名为 easemob-sdk
  --apply                   实际写入（默认仅显示变更）
  --run-build               写入后执行 speckit check + build-all
  -h, --help                显示本帮助
USAGE
}

msg(){ echo "[local-deps] $*"; }
dry(){ echo "[DRY-RUN] $*"; }

ensure_dirs(){
  [[ -d "$LIBS_BASE" ]] || { [[ $APPLY -eq 1 ]] && mkdir -p "$LIBS_BASE"; }
  if [[ $RENAME_DIR -eq 1 ]]; then
    for d in "$LIBS_BASE"/easemob-sdk-*; do
      [[ -d "$d" && "$d" != "$SDK_DIR" ]] && { [[ $APPLY -eq 1 ]] && mv "$d" "$SDK_DIR" || dry "将把 $d 重命名为 $SDK_DIR"; break; }
    done
  fi
  [[ -d "$JNI_DIR" ]] || { [[ $APPLY -eq 1 ]] && mkdir -p "$JNI_DIR" || dry "将创建 $JNI_DIR"; }
}

patch_android_build(){
  local f="$ANDROID_DIR/build.gradle"
  local tmp="$f.__tmp__"
  [[ -f "$f" ]] || { msg "未找到: $f"; return 1; }
  msg "设置 jniLibs 指向 $JNI_DIR 并仅启用本地 implementation files"
  local awk_prog='
    {
      line=$0
      # 统一 jniLibs.srcDirs
      if(line ~ /jniLibs\.srcDirs/){ gsub(/\x5b.*\x5d/, "[\047./libs/easemob-sdk/libs\047]", line) }
      # 取消注释本地 implementation files 并写入 jar 文件名
      if(line ~ /^[ \t]*\/\/[ \t]*implementation[ \t]+files\(.*hyphenatechat_.*\.jar.*\)/){ sub(/^([ \t]*)\/\/[ \t]*/, "\\1", line) }
      # 注释远程 implementation
      if(line ~ /^[ \t]*implementation[ \t]+\x27io\.hyphenate:hyphenate-chat:/){ line="    // " line }
      print line
    }
  '
  if [[ $APPLY -eq 1 ]]; then
    awk "$awk_prog" "$f" > "$tmp" && mv "$tmp" "$f"
    if [[ -n "$ANDROID_JAR" ]]; then
      perl -i -pe "s#implementation files\('.*hyphenatechat_.*\.jar'\)#implementation files('./libs/easemob-sdk/libs/$ANDROID_JAR')#" "$f" || true
    fi
  else
    dry "将注释远程、启用本地 implementation files，并设置 jniLibs.srcDirs"
  fi
}

maybe_build(){
  [[ $RUN_BUILD -eq 1 ]] || return 0
  msg "运行 speckit 检查与构建…"
  "$SPECKIT" check
  "$SPECKIT" build-all
}

main(){
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --jar) ANDROID_JAR="$2"; shift 2;;
      --rename-dir) RENAME_DIR=1; shift;;
      --apply) APPLY=1; shift;;
      --run-build) RUN_BUILD=1; shift;;
      -h|--help) usage; exit 0;;
      *) echo "未知参数: $1"; usage; exit 2;;
    esac
  done
  [[ $APPLY -eq 0 ]] && dry "当前为 dry-run 模式，添加 --apply 才会写入文件"
  ensure_dirs
  patch_android_build
  maybe_build
  msg "完成"
}

main "$@"
