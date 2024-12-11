# -*- coding: utf-8 -*-

import os

def replace_imports_in_file(file_path, old_package, new_package):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.readlines()

    with open(file_path, 'w', encoding='utf-8') as file:
        for line in content:
            if old_package in line:
                line = line.replace(old_package, new_package)
            file.write(line)

def main():
    directory = 'android/src/main/java/com/easemob/im_flutter_sdk'  # 修改为你的文件夹路径
    old_package = 'com.hyphenate'
    new_package = 'test.hyphenate'  # 替换为新的包名

    for filename in os.listdir(directory):
        if filename.endswith('.java'):
            file_path = os.path.join(directory, filename)
            replace_imports_in_file(file_path, old_package, new_package)
            print('Updated imports in {}'.format(file_path))

if __name__ == "__main__":
    main()