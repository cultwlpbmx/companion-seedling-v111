# 🌱 陪伴小树苗 (Companion Seedling) V1.1.1

> 一款温暖治愈的 AI 家庭教育心理陪伴 App —— 你的家庭教育知心朋友

陪伴小树苗是一款基于 Flutter 的移动端 AI 心理陪伴应用，核心定位是**家庭教育心理陪伴师**。它不是冷冰冰的问答机器人，而是一株会主动打招呼、会共情、会发光的小树苗 🌱

**纯本地架构，无需登录，无需服务器，所有数据保存在你的手机上。**

## ✨ 核心特色

### 🌟 E型主动人格 AI
- 小树苗会**主动问候**，根据时间段调整开场（早安/午安/晚安/深夜关怀）
- 243 行精心设计的 System Prompt，文学化 × 故事化 × 小树苗比喻体系
- 独立人格设定文档（v3.0）：注入善良、友爱、正直、传统、诚实等核心人格底色
- 劝和不劝分，反对体罚，危机场景提供心理热线（400-161-9995）

### 🏠 家庭档案系统
- 家长信息：角色（妈妈/爸爸/爷爷/奶奶等）、教育方式（民主型/温和坚定型等）
- 孩子信息：昵称、年龄、性别、年级、性格特点、当前困扰
- AI 自动读取家庭档案，给出更个性化的建议
- 支持多个孩子，随时可编辑

### 🧠 用户画像系统
- AI 从对话中提取用户信息，逐步了解你
- 记录性格特质、优点、挑战、教育理念等 20+ 维度
- 对话高光记录（最近 20 条关键事件）
- 画像摘要自动注入 AI 上下文，让建议越来越精准

### 📴 离线 Fallback
- 网络断开时，自动切换本地 OfflineAI
- 基于 5 大育儿理论的关键词匹配回复
- 覆盖：作业拖拉、情绪管理、青春期沟通、二胎关系、电子设备管理
- 每个主题含分年龄段策略（学龄前/小学/青春期）

### 📚 知识库
- 6 大专业理论：积极管教、非暴力沟通（NVC）、情感引导、依恋理论、成长型思维、积极倾听
- 623KB 案例库：涵盖学习动力、情绪崩溃、青春期沟通、抑郁危机等
- 5 本经典育儿书摘要：正面管教、如何说孩子才会听、P.E.T.、游戏力养育、全脑教养法

## 🎨 设计风格

**简笔画 / 手绘风格** —— 像在草稿纸上画出来的一样温暖

| 元素 | 说明 |
|------|------|
| 主色 | 柔和绿 `#6B9E78` |
| 点缀色 | 温暖橙 `#F0A868` |
| 背景色 | 暖米白 `#FDFBF7` / 深蓝灰 `#1A1F2E` |
| 描边 | 手绘风格粗描边 `#2D2D2D` |
| 气泡 | 圆角不对称，用户绿 AI 白 |
| 圆角 | 14-22px，柔和亲切 |
| 暗色模式 | ✅ 完整支持，跟随系统 |

## 🏗️ 技术架构

### 架构特点
- **纯客户端**：无需服务器，无需数据库，无需登录
- **隐私友好**：所有数据存储在手机本地，绝不上传
- **消息即时落盘**：参考微信/Telegram 做法，每条消息即时写入 SQLite

### 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter 3.x (Dart 3) |
| 状态管理 | Riverpod (`flutter_riverpod`) |
| 本地数据库 | SQLite (`sqflite`) — 聊天消息即时落盘 |
| 本地存储 | SharedPreferences — 用户画像、配置 |
| 环境变量 | `flutter_dotenv` — API Key 管理 |
| UI 组件 | `flutter_svg` — SVG 图标渲染 |

### AI Provider 支持

| Provider | 模型 | 特点 |
|----------|------|------|
| **阿里云通义千问**（默认） | `qwen-plus` | 稳定可靠，中文优秀 |
| 阶跃星辰 | `step-3.5-flash` | 备选 |
| OpenRouter | `mixtral-8x7b-instruct` | 多模型切换 |
| Ollama 本地 | `seedling-counselor` | 完全离线，隐私最强 |

## 📁 项目结构

```
lib/
├── main.dart                          # 应用入口（匿名用户，自动登录）
├── models/
│   ├── conversation_model.dart        # 对话消息 + 会话模型（6 类对话分类）
│   └── user_profile_model.dart        # 用户画像模型（20+ 维度）
├── screens/
│   ├── splash_screen.dart             # 启动页（弹性缩放动画 → 聊天页）
│   ├── chat_screen.dart               # 聊天主界面（核心页面）
│   ├── family_profile_screen.dart     # 家庭档案编辑页
│   └── settings_screen.dart           # 设置页（档案/历史/清空/重置画像）
├── services/
│   ├── ai_service.dart                # AI 对话服务（4 Provider + 243行 System Prompt）
│   ├── chat_database.dart             # SQLite 数据库（即时落盘）
│   ├── local_data_service.dart        # 本地数据服务（匿名用户）
│   ├── offline_ai.dart                # 离线 AI 响应（5 大主题关键词匹配）
│   └── user_profile_service.dart      # 用户画像管理（对话提取 + 摘要生成）
├── themes/
│   └── app_theme.dart                 # 亮/暗主题（简笔画风格配色）
└── utils/
    └── app_config.dart                # 环境变量配置（Provider 优先级选择）
assets/
├── images/app_icon.png                # APP 图标
├── icons/                             # SVG 图标集
├── knowledge_base/
│   ├── theories.json                  # 6 大育儿理论
│   └── cases.json                     # 623KB 案例库
└── book_cases/                        # 5 本经典育儿书摘要
```

## 🚀 快速开始

### 前置要求

- Flutter SDK 3.x
- Android Studio / VS Code
- AI API Key（至少一个）

### 1. 克隆项目

```bash
git clone https://github.com/cultwlpbmx/companion-seedling-v111.git
cd companion-seedling-v111
```

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 配置 API Key

复制 `.env.example` 为 `.env`，填写你的 AI API Key：

```bash
# 推荐：阿里云通义千问
# 获取地址：https://dashscope.console.aliyun.com/apiKey
ALIYUN_API_KEY=your_dashscope_api_key_here
PROVIDER=aliyun

# 可选：其他 Provider
# OPENROUTER_API_KEY=your_key
# STEPFUN_API_KEY=your_key
# OLLAMA_API_URL=http://localhost:11434
```

### 4. 运行应用

```bash
flutter run
```

首次打开会看到启动页动画，然后小树苗会主动跟你打招呼 🌱

## 📱 使用流程

1. **打开 APP** → 无需注册，自动创建本地用户
2. **小树苗主动问候** → 根据时间段说早安/午安/晚安
3. **聊天** → 随便聊，快捷话题一键发送（孩子作业拖拉/亲子沟通/青春期叛逆/情绪管理）
4. **填写家庭档案** → 设置页 → 家庭档案 → 让 AI 更了解你
5. **AI 越来越懂你** → 每次对话都在积累对你的了解

## 🔐 数据隐私

| 特性 | 说明 |
|------|------|
| 本地存储 | 所有数据仅保存在手机本地（SQLite + SharedPreferences） |
| 无服务器 | 不连接任何后端服务器 |
| 无账号 | 无需注册/登录，匿名本地用户 |
| AI 调用 | 对话内容发送给 AI Provider（请查看对应隐私政策） |
| 离线可用 | 断网时自动切换本地 AI，仍可对话 |

## 🎯 AI 人格核心原则

| 原则 | 说明 |
|------|------|
| 诚实铁律 | 绝不编造历史对话，绝不假装认识用户 |
| 主动温暖 | E 型人格，主动打招呼、抛话题、关心你 |
| 文学化表达 | 用小树苗比喻体系（情绪像天气、焦虑像土壤板结...） |
| 纯文本格式 | 不用 Markdown/LaTeX，只用 emoji 和空行排版 |
| 危机检测 | 自伤/自杀场景提供 24h 心理热线 400-161-9995 |
| 陪伴非替代 | 是陪伴者，不替代医院和心理医生 |

## 🌐 官网

[www.pbxsm.com](https://www.pbxsm.com)

- ICP 备案：宁ICP备2025010683号
- 公安备案：宁公网安备64010002000202号

## 📄 License

MIT

---

**小树苗，伴你成长 🌱**
