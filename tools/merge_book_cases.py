# 书籍案例合并脚本
# 将 assets/book_cases/ 下的所有书籍案例合并到主 cases.json
# 同时保留来源标识（source: "book:book_id"）

import json
from pathlib import Path

BASE_DIR = Path(__file__).parent.parent

# 1. 读取主案例库
cases_path = BASE_DIR / "assets" / "knowledge_base" / "cases.json"
with open(cases_path, "r", encoding="utf-8") as f:
    main_data = json.load(f)
    all_cases = main_data.get("cases", [])

print(f"主案例库现有: {len(all_cases)} 条")

# 2. 读取书籍索引
books_index_path = BASE_DIR / "assets" / "book_cases" / "books_index.json"
with open(books_index_path, "r", encoding="utf-8") as f:
    books_index = json.load(f)["books_index"]

# 3. 遍历每本书，读取案例并合并
added_count = 0
for book in books_index:
    book_file = BASE_DIR / "assets" / "book_cases" / book["file"]
    if not book_file.exists():
        print(f"⚠️  文件不存在: {book_file}")
        continue
    with open(book_file, "r", encoding="utf-8") as f:
        book_data = json.load(f)
        book_cases = book_data.get("cases", [])
        for c in book_cases:
            # 添加来源标记
            c["source"] = f"book:{book['id']}"
            c["source_book"] = book["title"]
            c["source_author"] = book["author"]
            all_cases.append(c)
            added_count += 1
    print(f"✅ {book['title']}: {len(book_cases)} 条案例")

# 4. 保存回主案例库
output = {"cases": all_cases}
with open(cases_path, "w", encoding="utf-8") as f:
    json.dump(output, f, ensure_ascii=False, indent=2)

print(f"\n✅ 合并完成！")
print(f"新增书籍案例: {added_count} 条")
print(f"案例库总计: {len(all_cases)} 条")
print(f"保存至: {cases_path}")
