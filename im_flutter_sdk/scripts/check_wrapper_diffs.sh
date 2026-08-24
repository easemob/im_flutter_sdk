#!/bin/bash
# 检查各 flavor wrapper 目录与基线(base500)的冗余复制。
# 拓扑约定：src/base500/java = 5.0 基线（全套 wrapper）；
#           src/<flavor>/java 只放相对基线的差异 wrapper。
# 若 flavor 里有与基线逐字节相同的文件，说明误复制了没改的文件，应删除（自动复用基线）。
set -u

BASE="im_flutter_sdk_android/android/src/base500/java"
FOUND=0

for flavor_dir in im_flutter_sdk_android/android/src/sdk*/java; do
    [ -d "$flavor_dir" ] || continue
    flavor=$(basename "$(dirname "$flavor_dir")")
    while IFS= read -r f; do
        rel=${f#"$flavor_dir"/}
        base_file="$BASE/$rel"
        if [ -f "$base_file" ] && diff -q "$f" "$base_file" >/dev/null 2>&1; then
            echo "WARN: $flavor/$rel 与基线逐字节相同，可删除（自动复用基线）"
            FOUND=1
        fi
    done < <(find "$flavor_dir" -name "*.java" 2>/dev/null)
done

if [ "$FOUND" -eq 0 ]; then
    echo "OK: 无冗余 wrapper 复制"
fi
