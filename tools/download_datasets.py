# 🌱 陪伴小树苗 - 心理学数据集下载工具
# 自动下载开源心理学数据集

import requests
import zipfile
import os
import json
from datetime import datetime

# 数据集下载链接
DATASETS = {
    "PsyDTCorpus": {
        "url": "https://github.com/microsoft/PsyDTCorpus/archive/refs/heads/main.zip",
        "description": "心理对话语料库（微软）",
        "expected_size": "10MB+"
    },
    "CounselChat": {
        "url": "https://github.com/psychology-datasets/CounselChat/archive/refs/heads/main.zip",
        "description": "心理咨询对话数据集（中英对照）",
        "expected_size": "20MB+"
    },
    "MentalHealthHotline": {
        "url": "https://github.com/mental-health/Hotline-Dialogues/archive/refs/heads/main.zip",
        "description": "心理援助热线对话",
        "expected_size": "5MB+"
    }
}

TEMP_DIR = "temp"
OUTPUT_DIR = "assets/knowledge_base/cases"

def download_file(url, filepath):
    """下载文件"""
    print(f"正在下载：{filepath}")
    response = requests.get(url, stream=True)
    total_size = int(response.headers.get('content-length', 0))
    
    with open(filepath, "wb") as f:
        downloaded = 0
        for chunk in response.iter_content(chunk_size=8192):
            f.write(chunk)
            downloaded += len(chunk)
            if total_size > 0:
                percent = (downloaded / total_size) * 100
                print(f"\r  进度：{percent:.1f}%", end="")
    
    print()

def extract_zip(zip_path, extract_to):
    """解压 ZIP 文件"""
    print(f"正在解压：{zip_path}")
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall(extract_to)
    print(f"✅ 解压完成：{extract_to}")

def convert_to_standard_format(input_data, source_name):
    """转换为标准案例格式"""
    case = {
        "caseId": f"case_{source_name.lower()}_{datetime.now().timestamp():.0f}",
        "source": source_name,
        "title": input_data.get('title', '心理案例'),
        "category": input_data.get('category', '一般咨询'),
        "tags": input_data.get('tags', []),
        "situation": input_data.get('situation', {}),
        "dialogue": input_data.get('dialogue', []),
        "analysis": input_data.get('analysis', {}),
        "result": input_data.get('result', ''),
        "techniques": input_data.get('techniques', []),
        "applicableAge": input_data.get('applicableAge', []),
        "applicableTraits": input_data.get('applicableTraits', []),
        "metadata": {
            "importedAt": datetime.now().isoformat(),
            "version": "1.0",
            "language": "zh-CN" if source_name != "CounselChat" else "zh-CN/en-US"
        }
    }
    return case

def main():
    print("")
    print("🌱 陪伴小树苗 - 心理学数据集下载工具")
    print("=====================================")
    print("")
    
    # 创建目录
    os.makedirs(TEMP_DIR, exist_ok=True)
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    downloaded_datasets = []
    
    # 下载数据集
    for name, info in DATASETS.items():
        print(f"\n📊 数据集：{name}")
        print(f"说明：{info['description']}")
        print(f"预计大小：{info['expected_size']}")
        print("")
        
        try:
            # 下载
            zip_path = f"{TEMP_DIR}/{name}.zip"
            download_file(info['url'], zip_path)
            
            # 解压
            extract_to = f"{TEMP_DIR}/{name}"
            extract_zip(zip_path, extract_to)
            
            downloaded_datasets.append(name)
            print(f"✅ {name} 下载成功")
            
        except Exception as e:
            print(f"❌ {name} 下载失败：{e}")
    
    print("")
    print("=====================================")
    print(f"✅ 下载完成！成功：{len(downloaded_datasets)}/{len(DATASETS)}")
    print("=====================================")
    print("")
    
    if downloaded_datasets:
        print("下一步：")
        print("1. 检查 temp/ 目录确认文件已下载")
        print("2. 运行数据转换脚本：python tools/convert_datasets.py")
        print("3. 验证案例库：assets/knowledge_base/cases/")
        print("")
    
    input("按 Enter 退出...")

if __name__ == "__main__":
    main()
