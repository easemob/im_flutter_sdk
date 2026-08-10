#!/bin/bash
# iOS wrapper 多版本冗余检查：对比各 sdk*/ 差异目录与 base500 基线，
# 发现"复制了但没改"的冗余文件（应删除，自动复用基线）。
set -u

BASE="im_flutter_sdk_ios/ios/Classes/base500"
FOUND=0

for dir in im_flutter_sdk_ios/ios/Classes/sdk*/; do
    [ -d "$dir" ] || continue
    flavor=$(basename "$dir")
    for f in "$dir"*.h "$dir"*.m; do
        [ -f "$f" ] || continue
        rel=$(basename "$f")
        if [ -f "$BASE/$rel" ] && diff -q "$f" "$BASE/$rel" >/dev/null 2>&1; then
            echo "WARN: $flavor/$rel 与基线逐字节相同，可删除（自动复用基线）"
            FOUND=1
        fi
    done
done

if [ "$FOUND" -eq 0 ]; then
    echo "OK: 无冗余 iOS wrapper 复制"
fi
