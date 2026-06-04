#!/usr/bin/env bash
set -euo pipefail

# Remote Deps Agent — 切换为远程依赖并更新版本（默认 dry-run）
#
# 用法示例：
#   im_flutter_sdk/scripts/agents/remote_deps_agent.sh \
#     --android-ver 4.20.1 --ios-hy-ver 4.20.1 --ios-sw-chat-ver 1.3.3 --apply

ROOT_DIR=$(cd "$(dirname "$0")/../.." && pwd)
ANDROID_DIR="$ROOT_DIR/../im_flutter_sdk_android/android"
IOS_PODSPEC="$ROOT_DIR/../im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec"
SPECKIT="$ROOT_DIR/scripts/speckit.sh"

APPLY=0
RUN_BUILD=0
ANDROID_VER=""
IOS_HY_VER=""
IOS_SW_CHAT_VER=""

usage(){
  cat <<USAGE
Remote Deps Agent — 切换为远程依赖并更新版本（dry-run 默认）

选项:
  --android-ver <ver>       例如 4.20.1（io.hyphenate:hyphenate-chat）
  --ios-hy-ver <ver>        例如 4.20.1（HyphenateChat >=）
  --ios-sw-chat-ver <ver>   例如 1.3.3（ShengwangChat_iOS >=）
  --apply                   实际写入（默认仅显示变更）
  --run-build               写入后执行 speckit check + build-all
  -h, --help                显示本帮助
USAGE
}

msg(){ echo "[remote-deps] $*"; }
dry(){ echo "[DRY-RUN] $*"; }

awk_write(){ # awk_write <in> <out> <awk-program>
  local in="$1" out="$2" prog="$3"
  awk "$prog" "$in" > "$out"
}

patch_android(){
  local f="$ANDROID_DIR/build.gradle" tmp="$f.__tmp__"; [[ -f "$f" ]] || { msg "未找到: $f"; return 1; }
  msg "处理 Android 远程依赖: $f"
  local awk_prog='
    BEGIN{remote_seen=0}
    {
      line=$0
      # 注释本地 implementation files(hyphenatechat_*.jar)
      if(line ~ /^[ \t]*implementation[ \t]+files\(.*hyphenatechat_.*\.jar['"]\)/){
        if(line ~ /^[ \t]*\/\//){ print line } else { print "// " line }
        next
      }
      # 远程 implementation 行：取消注释
      if(line ~ /^[ \t]*\/\/[ \t]*implementation[ \t]+\x27io\.hyphenate:hyphenate-chat:[^\x27]*\x27/){
        sub(/^([ \t]*)\/\//, "\\1", line)
      }
      if(line ~ /^[ \t]*implementation[ \t]+\x27io\.hyphenate:hyphenate-chat:[^\x27]*\x27/){
        remote_seen=1
      }
      print line
    }
    END{}
  '
  if [[ $APPLY -eq 1 ]]; then
    awk_write "$f" "$tmp" "$awk_prog" && mv "$tmp" "$f"
  else
    dry "将取消注释远程依赖并注释本地 implementation files(...)"
  fi

  if [[ -n "$ANDROID_VER" ]]; then
    # 设置远程版本号（若存在）
    local sedexpr="s#^\\([ \\t]*implementation[ \\t]*'io\\.hyphenate:hyphenate-chat:\\)[^']*\('#\\1$ANDROID_VER\\2#"
    if [[ $APPLY -eq 1 ]]; then
      perl -0777 -pe "$sedexpr" -i "$f" || true
    else
      dry "将把远程版本设为 $ANDROID_VER"
    fi
  fi
}

patch_ios(){
  local f="$IOS_PODSPEC" tmp="$f.__tmp__"; [[ -f "$f" ]] || { msg "未找到: $f"; return 1; }
  msg "处理 iOS 远程依赖: $f"
  local awk_prog='
    {
      line=$0
      # 注释 vendored_frameworks 行
      if(line ~ /^[ \t]*s\.vendored_frameworks\b/){
        if(line ~ /^[ \t]*#/){ print line } else { print "# " line }
        next
      }
      # 取消注释 HyphenateChat/ShengwangChat_iOS 依赖
      if(line ~ /^[ \t]*#[ \t]*s\.dependency[ \t]+\x27HyphenateChat\x27/){ sub(/^([ \t]*)#[ \t]*/, "\\1", line) }
      if(line ~ /^[ \t]*#[ \t]*s\.dependency[ \t]+\x27ShengwangChat_iOS\x27/){ sub(/^([ \t]*)#[ \t]*/, "\\1", line) }
      print line
    }
  '
  if [[ $APPLY -eq 1 ]]; then
    awk_write "$f" "$tmp" "$awk_prog" && mv "$tmp" "$f"
  else
    dry "将注释 vendored，并取消注释远程 s.dependency 行"
  fi

  if [[ -n "$IOS_HY_VER" ]]; then
    local sedexpr="s/^([ \\t]*s\\.dependency[ \\t]+\'HyphenateChat\',[ \\t]*')>=*[^']*('\s*)$/\\1>= $IOS_HY_VER\\2/; s/^([ \\t]*s\\.dependency[ \\t]+\'HyphenateChat\',[ \\t]*')([^']*)('\s*)$/\\1>= $IOS_HY_VER\\3/"
    if [[ $APPLY -eq 1 ]]; then perl -0777 -pe "$sedexpr" -i "$f" || true; else dry "将设置 HyphenateChat >= $IOS_HY_VER"; fi
  fi
  if [[ -n "$IOS_SW_CHAT_VER" ]]; then
    local sedexpr2="s/^([ \\t]*s\\.dependency[ \\t]+\'ShengwangChat_iOS\',[ \\t]*')>=*[^']*('\s*)$/\\1>= $IOS_SW_CHAT_VER\\2/; s/^([ \\t]*s\\.dependency[ \\t]+\'ShengwangChat_iOS\',[ \\t]*')([^']*)('\s*)$/\\1>= $IOS_SW_CHAT_VER\\3/"
    if [[ $APPLY -eq 1 ]]; then perl -0777 -pe "$sedexpr2" -i "$f" || true; else dry "将设置 ShengwangChat_iOS >= $IOS_SW_CHAT_VER"; fi
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
      --android-ver) ANDROID_VER="$2"; shift 2;;
      --ios-hy-ver) IOS_HY_VER="$2"; shift 2;;
      --ios-sw-chat-ver) IOS_SW_CHAT_VER="$2"; shift 2;;
      --apply) APPLY=1; shift;;
      --run-build) RUN_BUILD=1; shift;;
      -h|--help) usage; exit 0;;
      *) echo "未知参数: $1"; usage; exit 2;;
    esac
  done
  [[ $APPLY -eq 0 ]] && dry "当前为 dry-run 模式，添加 --apply 才会写入文件"
  patch_android
  patch_ios
  maybe_build
  msg "完成"
}

main "$@"

