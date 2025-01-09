# 在执行命令之前增加提示
if [[ "$1" != "shengwang" && "$1" != "agorachat" ]]; then
    echo "错误: 参数 必须是 shengwang 或 agorachat, 如 python change_name.py path shengwang"
    exit 1
fi
python change_name.py ../../im_flutter_sdk --type $1