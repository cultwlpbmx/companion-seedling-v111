# 🌱 陪伴小树苗 - 心理学数据集转换工具
# 将下载的原始数据转换为标准案例格式

import json
import os
from datetime import datetime
from pathlib import Path

TEMP_DIR = "temp"
OUTPUT_DIR = "assets/knowledge_base/cases"

def convert_psydt_corpus():
    """转换 PsyDTCorpus 数据集"""
    print("\n📊 转换 PsyDTCorpus...")
    
    input_dir = Path(f"{TEMP_DIR}/PsyDTCorpus")
    output_dir = Path(f"{OUTPUT_DIR}/psydt_corpus")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    cases = []
    case_id = 1
    
    if not input_dir.exists():
        print("  ⚠️ 未找到 PsyDTCorpus 数据")
        return 0
    
    # 遍历数据文件
    for file_path in input_dir.glob("**/*.json"):
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # 转换为标准格式
            case = {
                "caseId": f"case_psydt_{case_id:04d}",
                "source": "PsyDTCorpus",
                "title": data.get('title', f'心理案例 {case_id}'),
                "category": data.get('category', '一般咨询'),
                "tags": data.get('tags', data.get('keywords', [])),
                "situation": {
                    "description": data.get('situation', data.get('description', '')),
                    "clientAge": data.get('clientAge', 0),
                    "clientRole": data.get('clientRole', ''),
                    "childAge": data.get('childAge', 0),
                    "childGender": data.get('childGender', '')
                },
                "dialogue": data.get('dialogue', data.get('conversation', [])),
                "analysis": {
                    "problem": data.get('problem', ''),
                    "cause": data.get('cause', ''),
                    "solution": data.get('solution', '')
                },
                "result": data.get('result', ''),
                "techniques": data.get('techniques', []),
                "applicableAge": data.get('applicableAge', []),
                "applicableTraits": data.get('applicableTraits', []),
                "metadata": {
                    "importedAt": datetime.now().isoformat(),
                    "version": "1.0",
                    "language": "zh-CN",
                    "originalFile": str(file_path)
                }
            }
            
            cases.append(case)
            case_id += 1
            
        except Exception as e:
            print(f"  ⚠️ 转换失败 {file_path}: {e}")
    
    # 保存
    if cases:
        index_data = {
            "source": "PsyDTCorpus",
            "total": len(cases),
            "importedAt": datetime.now().isoformat(),
            "cases": cases
        }
        
        with open(output_dir / "cases_index.json", 'w', encoding='utf-8') as f:
            json.dump(index_data, f, ensure_ascii=False, indent=2)
        
        print(f"  ✅ 转换完成：{len(cases)} 个案例")
        return len(cases)
    else:
        print("  ⚠️ 没有可转换的案例")
        return 0

def convert_counselchat():
    """转换 CounselChat 数据集（中英对照）"""
    print("\n📊 转换 CounselChat...")
    
    input_dir = Path(f"{TEMP_DIR}/CounselChat")
    output_dir = Path(f"{OUTPUT_DIR}/counselchat")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    cases = []
    case_id = 1
    
    if not input_dir.exists():
        print("  ⚠️ 未找到 CounselChat 数据")
        return 0
    
    # 遍历数据文件
    for file_path in input_dir.glob("**/*.json"):
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # CounselChat 可能是中英对照
            case = {
                "caseId": f"case_cc_{case_id:04d}",
                "source": "CounselChat",
                "title": data.get('title', f'Counseling Case {case_id}'),
                "titleEn": data.get('titleEn', ''),
                "category": data.get('category', 'Counseling'),
                "tags": data.get('tags', []),
                "situation": {
                    "description": data.get('situation', ''),
                    "descriptionEn": data.get('situationEn', ''),
                    "clientAge": data.get('clientAge', 0),
                    "clientRole": data.get('clientRole', '')
                },
                "dialogue": data.get('dialogue', []),
                "analysis": {
                    "problem": data.get('problem', ''),
                    "solution": data.get('solution', '')
                },
                "result": data.get('result', ''),
                "techniques": data.get('techniques', []),
                "metadata": {
                    "importedAt": datetime.now().isoformat(),
                    "version": "1.0",
                    "language": "zh-CN/en-US",
                    "originalFile": str(file_path)
                }
            }
            
            cases.append(case)
            case_id += 1
            
        except Exception as e:
            print(f"  ⚠️ 转换失败 {file_path}: {e}")
    
    # 保存
    if cases:
        index_data = {
            "source": "CounselChat",
            "total": len(cases),
            "importedAt": datetime.now().isoformat(),
            "language": "zh-CN/en-US",
            "cases": cases
        }
        
        with open(output_dir / "cases_index.json", 'w', encoding='utf-8') as f:
            json.dump(index_data, f, ensure_ascii=False, indent=2)
        
        print(f"  ✅ 转换完成：{len(cases)} 个案例")
        return len(cases)
    else:
        print("  ⚠️ 没有可转换的案例")
        return 0

def convert_hotline():
    """转换心理援助热线数据集"""
    print("\n📊 转换心理援助热线...")
    
    input_dir = Path(f"{TEMP_DIR}/MentalHealthHotline")
    output_dir = Path(f"{OUTPUT_DIR}/mental_health_hotline")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    cases = []
    case_id = 1
    
    if not input_dir.exists():
        print("  ⚠️ 未找到 MentalHealthHotline 数据")
        return 0
    
    # 遍历数据文件
    for file_path in input_dir.glob("**/*.json"):
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            case = {
                "caseId": f"case_hotline_{case_id:04d}",
                "source": "MentalHealthHotline",
                "title": data.get('title', f'心理援助案例 {case_id}'),
                "category": data.get('category', '危机干预'),
                "tags": data.get('tags', []),
                "situation": {
                    "description": data.get('situation', ''),
                    "urgency": data.get('urgency', '一般')
                },
                "dialogue": data.get('dialogue', []),
                "analysis": {
                    "problem": data.get('problem', ''),
                    "riskLevel": data.get('riskLevel', '低'),
                    "solution": data.get('solution', '')
                },
                "result": data.get('result', ''),
                "techniques": data.get('techniques', ['危机干预', '情绪疏导']),
                "metadata": {
                    "importedAt": datetime.now().isoformat(),
                    "version": "1.0",
                    "language": "zh-CN",
                    "originalFile": str(file_path)
                }
            }
            
            cases.append(case)
            case_id += 1
            
        except Exception as e:
            print(f"  ⚠️ 转换失败 {file_path}: {e}")
    
    # 保存
    if cases:
        index_data = {
            "source": "MentalHealthHotline",
            "total": len(cases),
            "importedAt": datetime.now().isoformat(),
            "cases": cases
        }
        
        with open(output_dir / "cases_index.json", 'w', encoding='utf-8') as f:
            json.dump(index_data, f, ensure_ascii=False, indent=2)
        
        print(f"  ✅ 转换完成：{len(cases)} 个案例")
        return len(cases)
    else:
        print("  ⚠️ 没有可转换的案例")
        return 0

def create_master_index():
    """创建总索引"""
    print("\n📋 创建总索引...")
    
    master_index = {
        "version": "1.0",
        "updatedAt": datetime.now().isoformat(),
        "sources": []
    }
    
    total_cases = 0
    
    # 扫描所有案例库
    for source_dir in Path(OUTPUT_DIR).iterdir():
        if source_dir.is_dir():
            index_file = source_dir / "cases_index.json"
            if index_file.exists():
                with open(index_file, 'r', encoding='utf-8') as f:
                    source_data = json.load(f)
                
                master_index["sources"].append({
                    "name": source_dir.name,
                    "source": source_data.get("source", source_dir.name),
                    "total": source_data.get("total", 0),
                    "importedAt": source_data.get("importedAt", "")
                })
                
                total_cases += source_data.get("total", 0)
    
    master_index["totalCases"] = total_cases
    
    # 保存总索引
    with open(OUTPUT_DIR + "/master_index.json", 'w', encoding='utf-8') as f:
        json.dump(master_index, f, ensure_ascii=False, indent=2)
    
    print(f"  ✅ 总索引创建完成：{total_cases} 个案例")

def main():
    print("")
    print("🌱 陪伴小树苗 - 心理学数据集转换工具")
    print("=====================================")
    print("")
    
    # 转换各个数据集
    results = {
        "PsyDTCorpus": convert_psydt_corpus(),
        "CounselChat": convert_counselchat(),
        "MentalHealthHotline": convert_hotline()
    }
    
    # 创建总索引
    create_master_index()
    
    print("")
    print("=====================================")
    print("✅ 数据转换完成！")
    print("=====================================")
    print("")
    print("数据集统计：")
    for name, count in results.items():
        print(f"  {name}: {count} 个案例")
    print("")
    print("案例库位置：")
    print(f"  {OUTPUT_DIR}/")
    print("")
    print("下一步：")
    print("1. 验证案例数据：查看 assets/knowledge_base/cases/")
    print("2. 测试 AI 检索：开始对话，观察 AI 是否应用案例库")
    print("3. 优化检索算法：根据需要调整匹配逻辑")
    print("")
    
    input("按 Enter 退出...")

if __name__ == "__main__":
    main()
