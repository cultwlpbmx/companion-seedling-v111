# 陪伴小树苗 - 案例库批量收集脚本
# 从公开网络资源爬取育儿案例，保存为 cases.json

import json
import requests
import re
from datetime import datetime
from typing import List, Dict
import time

# 案例存储结构
cases = []

def add_case(title, growth_stage, scenario, problem, solution, key_points, parenting_style="authoritative"):
    """添加案例到列表"""
    case = {
        "id": f"case_{len(cases)+1:04d}",
        "title": title,
        "growthStage": growth_stage,
        "scenario": scenario,
        "problem": problem.strip(),
        "solution": solution.strip(),
        "keyPoints": [p.strip() for p in key_points if p.strip()],
        "parentingStyle": parenting_style
    }
    cases.append(case)
    print(f"✅ 已添加: {title}")

# 示例：手动添加一些高质量案例（可替换为爬虫结果）
def load_examples():
    """加载示例案例（前100个高质量案例）"""
    examples = [
        {
            "title": "孩子写作业拖拉 - 小学低年级",
            "growthStage": "childhood",
            "scenario": "学习动力",
            "problem": "7岁孩子每天写作业要拖到半夜，家长催也没用，亲子冲突严重。",
            "solution": "1. 设立固定的作业时间段，使用可视化计时器；2. 采用番茄工作法，专注25分钟+休息5分钟；3. 拆分作业为小块，每完成一项打钩奖励；4. 给孩子有限选择；5. 减少干扰；6. 家长陪伴但不盯着；7. 完成后给予自由时间作为奖励。",
            "keyPoints": ["建立规律作息", "任务拆分法", "可视化计时", "有限选择权", "正向即时强化"],
            "parentingStyle": "authoritative"
        }
    ]
    for ex in examples:
        add_case(**ex)

# TODO: 实现以下爬虫函数

def crawl_zhihu():
    """爬取知乎育儿话题下的案例回答"""
    print("开始爬取知乎...")
    # 示例API（实际需要处理反爬）
    url = "https://www.zhihu.com/api/v4/answers?include=content&limit=100"
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
    }
    try:
        resp = requests.get(url, headers=headers, timeout=10)
        data = resp.json()
        for answer in data.get("data", []):
            content = answer.get("content", "")
            # 使用正则提取问题描述和答案
            # TODO: 解析 content HTML，提取问题和解决方案
            # 这里先跳过，需要针对具体页面结构编写
    except Exception as e:
        print(f"知乎爬取失败: {e}")

def crawl_wechat_gongzhonghao():
    """通过搜索引擎找公众号文章"""
    print("搜索公众号文章...")
    # 使用百度/Google搜索：site:mp.weixin.qq.com 育儿案例
    # 然后解析文章链接
    pass

def crawl_parenting_forums():
    """爬取育儿论坛"""
    forums = [
        "https://www.babytree.com/",
        "https://www.mmbang.com/",
    ]
    for url in forums:
        print(f"正在爬取: {url}")
        # 需要登录或反爬绕过
        pass

def generate_ai_cases_via_api():
    """使用StepFun API自动生成案例（需要API Key）"""
    print("正在调用 AI 生成案例...")
    # 调用 StepFun Step 模型
    # 提示词：生成1000个不同年龄、场景的育儿案例，JSON格式
    # 这样可以获得高质量variation
    pass

def main():
    print("=== 陪伴小树苗 - 案例库批量收集 ===")
    print(f"开始时间: {datetime.now()}")

    # 1. 加载现有案例
    try:
        with open("assets/knowledge_base/cases.json", "r", encoding="utf-8") as f:
            existing = json.load(f)
            for c in existing.get("cases", []):
                cases.append(c)
        print(f"已加载现有案例: {len(cases)} 条")
    except FileNotFoundError:
        print("未找到现有案例文件，将新建")

    # 2. 运行爬虫（按需启用）
    # load_examples()
    # crawl_zhihu()
    # crawl_wechat_gongzhonghao()
    # crawl_parenting_forums()

    # 3. 使用AI生成（推荐）
    # generate_ai_cases_via_api()

    # 4. 保存结果
    output = {"cases": cases}
    with open("assets/knowledge_base/cases.json", "w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, indent=2)

    print(f"\n完成！总计案例数: {len(cases)}")
    print(f"保存至: assets/knowledge_base/cases.json")

if __name__ == "__main__":
    main()
