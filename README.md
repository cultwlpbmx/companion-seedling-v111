# 陪伴小树苗 (Companion Seedling)

一个 AI 驱动的家庭教育心理学助手，帮助家长改善亲子沟通、平衡工作与生活。

## ✨ 核心功能

- **👨‍👩‍👧 家庭档案管理**：记录每个孩子的年龄、性格、兴趣，获取个性化建议
- **💬 AI 心理学家对话**：与"小树苗" BOT 进行 24/7 对话，获得情感支持和实用指导
- **📋 智能提醒系统**：每日签到、活动提醒、情绪检查、育儿建议推送
- **📚 知识库**：基于积极管教、非暴力沟通、依恋理论等专业理论
- **🔔 推送通知**：通过 FCM 发送每日建议和提醒
- **🌱 温暖设计**：自然、

## 🏗️ 技术栈

- **框架**: Flutter 3.x (Dart 3)
- **状态管理**: Riverpod
- **后端**: Firebase (Auth, Firestore, Cloud Messaging)
- **AI 服务**: OpenRouter / StepFun Step (免费额度)
- **本地存储**: Hive + SharedPreferences

## 📁 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   ├── user_model.dart       # 用户模型
│   ├── child_model.dart      # 孩子模型
│   ├── conversation_model.dart  # 对话模型
│   └── reminder_model.dart   # 提醒模型
├── services/                 # 服务层
│   ├── firebase_service.dart    # Firebase 初始化
│   ├── ai_service.dart          # AI 对话服务
│   ├── knowledge_service.dart   # 知识库查询
│   ├── knowledge_base_data.dart # 内置默认知识
│   └── notification_service.dart # 通知服务
├── screens/                  # 页面
│   ├── splash_screen.dart    # 启动页
│   ├── login_screen.dart     # 登录页
│   ├── home_screen.dart      # 首页（仪表盘）
│   ├── family_setup_screen.dart  # 家庭档案设置
│   └── chat_screen.dart      # 聊天界面
├── providers/                # Riverpod Providers
├── widgets/                  # 可复用组件
└── themes/                   # 主题配置
    └── app_theme.dart
assets/
├── images/                   # 图片资源
├── icons/                    # 图标
├── animations/               # Lottie 动画
├── knowledge_base/           # 知识库 JSON 文件
│   ├── theories.json
│   └── cases.json
└── fonts/                    # 自定义字体 (Noto Sans SC)
```

## 🚀 快速开始

### 前置要求

- Flutter SDK 3.x
- Android Studio / VS Code
- Firebase 账户（免费）
- AI API Key（OpenRouter 或 StepFun）

### 1. 克隆项目

将此项目放入你的 Flutter workspace：

```bash
# 将 companion_seedling 文件夹放到你的 Flutter 项目目录
```

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 配置 Firebase

1. 访问 [Firebase Console](https://console.firebase.google.com/)
2. 创建新项目（如 `companion-seedling`）
3. 添加 Android 应用（包名：`com.companion.seedling`）
4. 下载 `google-services.json` 放入 `android/app/`
5. 启用以下服务：
   - Authentication（Email/Password）
   - Cloud Firestore
   - Cloud Messaging (FCM)
   - Analytics（可选）

**Firestore 规则（测试阶段）：**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 4. 配置 AI API

#### 选项 A: OpenRouter（推荐，多模型免费额度）

1. 访问 [OpenRouter](https://openrouter.ai/) 注册
2. 获取 API Key
3. 在代码中配置（见下一步）

#### 选项 B: StepFun Step

1. 访问 [StepFun](https://platform.stepfun.com/) 注册
2. 获取 API Key
3. 修改 `lib/services/chat_screen.dart` 中的 `_getAIConfig()` 方法

### 5. 配置 API Key

为了安全，建议使用环境变量或配置类：

**方法 1: 使用 `.env` 文件（推荐）**

```bash
# 在项目根目录创建 .env 文件
OPENROUTER_API_KEY=your_api_key_here
```

并在 `pubspec.yaml` 中添加 `flutter_dotenv` 依赖。

**方法 2: 修改代码直接配置（仅开发测试）**

在 `lib/screens/chat_screen.dart` 中的 `_getAIConfig()` 方法填写：

```dart
return {
  'apiKey': 'your-openrouter-api-key', // 这里填
  'provider': 'openrouter',
  'model': 'mistralai/mixtral-8x7b-instruct',
};
```

### 6. 运行应用

```bash
flutter run
```

首次运行会看到启动页，然后可以：
- 登录（需先在 Firebase Auth 已有账户）
- 或注册新账户
- 完成家庭档案设置
- 开始与小树苗对话

## 📱 使用流程

1. **注册/登录** → 输入邮箱密码
2. **填写家庭档案** → 家长信息（年龄、职业、目标）→ 孩子信息（多个）
3. **进入首页** → 查看今日提醒、孩子列表、快速入口
4. **开始聊天** → 点击"和小树苗聊聊"按钮
   - 可选择针对某个孩子进行对话
   - 小树苗会基于孩子背景给出个性化建议
5. **接收推送** → 根据设置的提醒定时收到通知

## 🎨 设计风格

- **主色调**: 森林绿 (#4CAF50) + 大地橙 (#FF9800) + 米白
- **字体**: Noto Sans SC（中文字体）
- **圆角**: 12-16px
- **阴影**: 柔和 elevation 2-4
- **过渡**: 300ms ease-in-out

## 🌍 知识库内容

内置理论：
- 积极管教
- 非暴力沟通（NVC）
- 依恋理论
- 成长型思维
- 工作-生活平衡
- 青少年心理发展

内置案例（覆盖）：
- 学习动力问题
- 情绪崩溃处理
- 青春期沟通障碍
- 抑郁倾向危机干预
- 家长工作太忙
- 孩子拖拉、叛逆等

知识库文件位于 `assets/knowledge_base/`，可以后续扩展。

## 🔐 数据隐私

- 所有用户数据存储在 Firestore，仅用户自己可访问
- 不向第三方分享用户信息
- AI API 调用会发送对话内容（请查看 OpenAI / StepFun 的隐私政策）
- 如需完全离线，可后续实现本地 LLM（Ollama）

## 📈 未来功能

- [ ] 情绪分析报告
- [ ] 家庭时光线（记录重要时刻）
- [ ] 分享给配偶（多人协作）
- [ ] 语音对话（TTS/STT）
- [ ] 本地 AI 模型（Ollama 集成）
- [ ] 更多知识库和案例
- [ ] 导出数据（PDF/JSON）
- [ ] 多语言支持
- [ ] Web 端同步

## 🐛 已知问题

- 通知定时功能尚未完整实现（需要 tz 包支持）
- 部分 UI 组件待完善（如设置页、知识库页）
- AI API key 需手动配置
- 无图标资源（请补充 `assets/icons/` 和 `assets/images/`）

## 🤝 贡献

欢迎提出 Issue 和 Pull Request！

## 📄 License

MIT

---

**小树苗，伴你成长 🌱**