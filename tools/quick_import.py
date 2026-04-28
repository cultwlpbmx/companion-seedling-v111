# 陪伴小树苗 - 心理学数据集快速导入
# 简化版脚本

import subprocess
import os
import sys

print("")
print("陪伴小树苗 - 心理学数据集导入")
print("=" * 50)
print("")

# 检查 Python
print("检查 Python 环境...")
try:
    import requests
    print("Python 环境正常")
    print("requests 库已安装")
except ImportError:
    print("正在安装 requests 库...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "requests", "-q"])
    print("requests 库安装完成")

# 创建目录
print("")
print("创建目录结构...")
os.makedirs("temp", exist_ok=True)
os.makedirs("assets/knowledge_base/cases/psydt_corpus", exist_ok=True)
os.makedirs("assets/knowledge_base/cases/counselchat", exist_ok=True)
os.makedirs("assets/knowledge_base/cases/mental_health_hotline", exist_ok=True)
print("目录创建完成")

# 运行下载脚本
print("")
print("=" * 50)
print("步骤 1: 下载数据集")
print("=" * 50)
print("")

try:
    import tools.download_datasets as downloader
    downloader.main()
except Exception as e:
    print(f"下载失败：{e}")
    print("请手动下载数据集（详见心理学数据集导入指南.md）")

# 运行转换脚本
print("")
print("=" * 50)
print("步骤 2: 转换数据格式")
print("=" * 50)
print("")

try:
    import tools.convert_datasets as converter
    converter.main()
except Exception as e:
    print(f"转换失败：{e}")

# 验证结果
print("")
print("=" * 50)
print("步骤 3: 验证导入结果")
print("=" * 50)
print("")

import json
from pathlib import Path

master_index = Path("assets/knowledge_base/cases/master_index.json")
if master_index.exists():
    with open(master_index, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    print("案例库导入成功！")
    print("")
    print("数据集统计：")
    for source in data['sources']:
        print(f"  {source['source']}: {source['total']} 个案例")
    print("")
    print(f"总计：{data['totalCases']} 个案例")
else:
    print("未找到案例库索引文件")
    print("请检查数据集是否下载成功")

print("")
print("=" * 50)
print("全部完成！")
print("=" * 50)
print("")
print("案例库位置：assets/knowledge_base/cases/")
print("")
print("下一步：")
print("1. 重启 APP")
print("2. 开始对话测试")
print("3. 观察 AI 是否应用了案例库知识")
print("")

input("按 Enter 退出...")
