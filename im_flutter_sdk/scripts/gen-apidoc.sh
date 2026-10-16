#!/usr/bin/env bash
# 生成单语 API 文档(中文或英文)。
#
# 原理:
#   1. 将文档生成所需的 Dart 源码与包配置(含未提交改动)拷贝到临时目录,
#      保持 ../im_flutter_sdk_interface 等 path 依赖的相对路径不变;
#   2. 在副本中剥离主包 lib 下的双语注释标记(见 AGENTS.md「文档注释规范」),
#      只保留目标语言;
#   3. 在临时目录运行 dart doc,成功后整体移动到 <主包>/output/apidoc-<lang>;
#   4. 删除临时副本。源码仓库全程不被修改。
#
# 用法: scripts/gen-apidoc.sh [cn|en]   默认 cn

set -euo pipefail

lang="${1:-cn}"
case "$lang" in
  cn|en) ;;
  *) echo "用法: $0 [cn|en]" >&2; exit 1 ;;
esac

pkg_dir="$(cd "$(dirname "$0")/.." && pwd)"   # im_flutter_sdk/im_flutter_sdk
repo_root="$(cd "$pkg_dir/.." && pwd)"        # 仓库根
tmp_dir="$(mktemp -d /tmp/im_flutter_sdk_apidoc.XXXXXX)"
out_dir="$pkg_dir/output/apidoc-$lang"
staged_out_dir="$tmp_dir/apidoc-$lang"
previous_out_dir="$tmp_dir/previous-apidoc-$lang"
started_at=$SECONDS

cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

# 只拷贝 dartdoc 与 path 依赖解析所需内容,避免复制 example、Pods、SPM .build 等产物。
echo "[apidoc] 正在准备临时工作区..."
for package in \
  im_flutter_sdk \
  im_flutter_sdk_interface \
  im_flutter_sdk_ios \
  im_flutter_sdk_android; do
  mkdir -p "$tmp_dir/$package"
  rsync -a --prune-empty-dirs \
    --include='/lib/***' \
    --include='/pubspec.yaml' \
    --include='/pubspec.lock' \
    --include='/README*' \
    --include='/CHANGELOG*' \
    --include='/LICENSE*' \
    --include='/analysis_options.yaml' \
    --include='/dartdoc_options.yaml' \
    --exclude='*' \
    "$repo_root/$package/" "$tmp_dir/$package/"
done

# 平台包可能暂时指向已发布的 interface 版本;生成工作区文档时统一使用本地副本。
cat > "$tmp_dir/im_flutter_sdk/pubspec_overrides.yaml" <<'EOF'
dependency_overrides:
  im_flutter_sdk_interface:
    path: ../im_flutter_sdk_interface
  im_flutter_sdk_ios:
    path: ../im_flutter_sdk_ios
  im_flutter_sdk_android:
    path: ../im_flutter_sdk_android
EOF

# 剥离注释: 删除非目标语言块,以及所有 ~english/~chinese/~end 标记行
find "$tmp_dir/im_flutter_sdk/lib" -name '*.dart' -print0 |
  while IFS= read -r -d '' f; do
    awk -v keep="$lang" '
      /^[[:space:]]*\/\/\/[[:space:]]*~english[[:space:]]*$/ { inb=1; bl="en"; next }
      /^[[:space:]]*\/\/\/[[:space:]]*~chinese[[:space:]]*$/ { inb=1; bl="cn"; next }
      /^[[:space:]]*\/\/\/[[:space:]]*~end[[:space:]]*$/     { inb=0; next }
      { if (inb && bl != keep) next; print }
    ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  done

# dart doc 需要依赖解析结果(package_config.json)
echo "[apidoc] 正在解析依赖..."
(cd "$tmp_dir/im_flutter_sdk" && flutter pub get --no-example)

echo "[apidoc] 正在生成 $lang 版 API 文档..."
(cd "$tmp_dir/im_flutter_sdk" && dart doc --output "$staged_out_dir")

# dartdoc 成功后再替换输出。目录重命名避免 VS Code 监听到逐个文件写入。
mkdir -p "$(dirname "$out_dir")"
if [[ -e "$out_dir" || -L "$out_dir" ]]; then
  mv "$out_dir" "$previous_out_dir"
fi
if ! mv "$staged_out_dir" "$out_dir"; then
  rm -rf "$out_dir"
  if [[ -e "$previous_out_dir" || -L "$previous_out_dir" ]]; then
    mv "$previous_out_dir" "$out_dir"
  fi
  echo "替换 API 文档输出失败,已恢复原输出。" >&2
  exit 1
fi

# 主动清理后再报告总耗时;异常退出仍由 EXIT trap 清理。
cleanup
trap - EXIT

echo "已生成 $lang 版 API 文档($((SECONDS - started_at)) 秒): $out_dir"
echo "本地预览(侧边导航需通过 HTTP 访问才能加载): (cd \"$out_dir\" && python3 -m http.server 8765) 然后打开 http://localhost:8765/"
