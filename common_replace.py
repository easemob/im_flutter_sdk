#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import shutil
import re
import argparse

def parse_args():
    """
    解析命令行参数
    """
    parser = argparse.ArgumentParser(description='过滤Dart文件中的中文或英文注释',
                                     add_help=True)
    parser.add_argument('language', choices=['chinese', 'english'], help='要过滤的注释语言')
    parser.add_argument('src_folder', help='要过滤的源文件夹')
    parser.add_argument('dst_folder', help='要输出过滤后文件的目标文件夹')
    parser.add_argument('--file-type', '-t', default='.dart', help='要过滤的文件类型（默认为.dart）')
    return parser.parse_args()

def filter_folder(src_folder, dst_folder, file_type, language):
    """
    过滤指定文件夹中的文件，并输出到目标文件夹
    """
    for root, dirs, files in os.walk(src_folder):
        for file in files:
            if file.endswith(file_type):
                src_path = os.path.join(root, file)
                dst_path = os.path.join(dst_folder, os.path.relpath(src_path, start=src_folder))
                os.makedirs(os.path.dirname(dst_path), exist_ok=True)
                if not os.path.basename(src_path) == ".DS_Store":
                    shutil.copy2(src_path, dst_path)
                filter_comments(dst_path, language)
            else:
                src_path = os.path.join(root, file)
                dst_path = os.path.join(dst_folder, os.path.relpath(src_path, start=src_folder))
                os.makedirs(os.path.dirname(dst_path), exist_ok=True)
                if not os.path.basename(src_path) == ".DS_Store":
                    shutil.copy2(src_path, dst_path)

def filter_comments(file_path, language):
    """
    过滤文件中的中文或英文注释
    """
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        if language == 'chinese':
            pattern = r'~chinese[\s\S]*?~end'
        elif language == 'english':
            pattern = r'~english[\s\S]*?~end'
        else:
            return
        filtered_content = re.sub(pattern, '', content)
        filtered_content = filtered_content.replace('~chinese', '').replace('~english', '').replace('~end', '')
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(filtered_content)

if __name__ == '__main__':
    args = parse_args()
    filter_folder(args.src_folder, args.dst_folder, args.file_type, args.language)
