#!/usr/bin/env bash
# 生成单语 API 文档(中文或英文)。
#
# 原理:
#   1. 将仓库工作区(含未提交改动)拷贝到临时目录,保持 ../im_flutter_sdk_interface
#      等 path 依赖的相对路径不变;
#   2. 在副本中剥离主包 lib 下的双语注释标记(见 AGENTS.md「文档注释规范」),
#      只保留目标语言;
#   3. 运行 dart doc 生成 HTML,输出到 <主包>/output/apidoc-<lang>;
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

cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

# 拷贝工作区(含未提交改动),排除版本控制、构建产物与历史 worktree
rsync -a \
  --exclude='.git' \
  --exclude='.worktree' \
  --exclude='.dart_tool' \
  --exclude='build' \
  --exclude='output' \
  "$repo_root/" "$tmp_dir/"

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
(cd "$tmp_dir/im_flutter_sdk" && flutter pub get >/dev/null)

rm -rf "$out_dir"
(cd "$tmp_dir/im_flutter_sdk" && dart doc --output "$out_dir")

echo "已生成 $lang 版 API 文档: $out_dir"
echo "本地预览(侧边导航需通过 HTTP 访问才能加载): (cd \"$out_dir\" && python3 -m http.server 8765) 然后打开 http://localhost:8765/"
