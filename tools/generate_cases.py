# 陪伴小树苗 - 案例库批量生成脚本
# 基于现有 10 个案例模板，生成 1000 条变体

import json
import random
from pathlib import Path

# 项目根目录
BASE_DIR = Path(__file__).parent.parent

# 读取现有案例
cases_path = BASE_DIR / "assets" / "knowledge_base" / "cases.json"
with open(cases_path, "r", encoding="utf-8") as f:
    data = json.load(f)

existing_cases = data.get("cases", [])

# 定义变体参数
growth_stages = {
    "toddler": "学龄前 (3-5岁)",
    "childhood": "儿童期 (6-12岁)",
    "earlyTeen": "青春期早期 (13-15岁)",
    "lateTeen": "青春期后期 (16-18岁)"
}
scenarios = [
    "学习动力", "情绪管理", "亲子沟通", "青春期问题", "二胎关系",
    "电子设备", "社交能力", "生活习惯", "性格培养", "家庭关系"
]

problem_templates = [
    "孩子{age}岁，{issue}，家长很头疼。",
    "孩子{age}岁出现{issue}的情况，已经持续一段时间。",
    "{age}岁的孩子{issue}，家长尝试过很多方法都没效果。",
]

issue_map = {
    "学习动力": ["写作业拖拉、注意力不集中", "不爱学习、厌学", "学习动力不足、需要催促"],
    "情绪管理": ["容易发脾气、大哭大闹", "情绪敏感、容易受伤", "焦虑、紧张"],
    "亲子沟通": ["不听话、顶嘴", "拒绝沟通、关门不出", "说谎、隐瞒"],
    "青春期问题": ["叛逆、厌学", "情绪波动大", "追求独立、不理解父母"],
    "二胎关系": ["大宝嫉妒小宝、经常打闹", "两个孩子争宠、冲突不断", "分配不公平引发矛盾"],
    "电子设备": ["沉迷手机游戏、无法自拔", "每天玩超过3小时", "不给玩就发脾气"],
    "社交能力": ["内向、不敢交朋友", "被同学排挤、孤立", "不会处理同伴冲突"],
    "生活习惯": ["拖延、不按时作息", "不爱做家务、依赖性强", "挑食、饮食不规律"],
    "性格培养": ["胆小、缺乏自信", "固执、不听劝告", "冲动、不考虑后果"],
    "家庭关系": ["父母吵架影响孩子情绪", "隔代教养方式冲突", "离婚如何与孩子沟通"]
}

# 从现有案例提取技巧库
all_tips = []
for c in existing_cases:
    all_tips.extend(c.get("keyPoints", []))

# 生成新案例
new_cases = []
target_total = 1000

while len(existing_cases) + len(new_cases) < target_total:
    base_scenario = random.choice(scenarios)
    age = random.choice(list(range(3, 18)))
    stage = (
        "toddler" if age < 6 else
        "childhood" if age < 13 else
        "earlyTeen" if age < 16 else
        "lateTeen"
    )

    issue = random.choice(issue_map[base_scenario])
    problem = random.choice(problem_templates).format(age=age, issue=issue)

    # 随机组合3个技巧 + 一个注意事项
    random.shuffle(all_tips)
    tip1 = all_tips[0] if all_tips else "建立良好沟通"
    tip2 = all_tips[1] if len(all_tips) > 1 else "给予正向鼓励"
    tip3 = all_tips[2] if len(all_tips) > 2 else "设定合理规则"
    note = "每个孩子都是独特的，需要家长耐心尝试"

    solution = f"1. {tip1}；2. {tip2}；3. {tip3}。注意：{note}"

    title = f"{base_scenario}案例：{issue.split('、')[0]}（{age}岁）"

    case = {
        "id": f"case_{len(existing_cases)+len(new_cases)+1:04d}",
        "title": title[:80],
        "growthStage": growth_stages[stage],
        "scenario": base_scenario,
        "problem": problem,
        "solution": solution,
        "keyPoints": [tip1, tip2, tip3],
        "parentingStyle": random.choice(["authoritative", "gentle", "permissive"])
    }
    new_cases.append(case)

    if (len(existing_cases) + len(new_cases)) % 50 == 0:
        print(f"已生成: {len(existing_cases) + len(new_cases)} / {target_total}")

# 保存
all_cases = existing_cases + new_cases
output = {"cases": all_cases}
with open(cases_path, "w", encoding="utf-8") as f:
    json.dump(output, f, ensure_ascii=False, indent=2)

print(f"\n✅ 完成！总计案例: {len(all_cases)} 条")
