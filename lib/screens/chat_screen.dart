import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversation_model.dart';
import '../services/ai_service.dart';
import '../services/chat_database.dart';
import '../services/offline_ai.dart';
import '../services/user_profile_service.dart';
import '../utils/app_config.dart';
import 'settings_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  final List<ConversationMessage> _messages = [];
  bool _isLoading = false;
  SharedPreferences? _prefs;
  bool _hasGreeted = false; // 是否已发送过主动问候

  // 双击退出机制
  DateTime? _lastBackPressTime;

  // SharedPreferences 旧数据迁移标记
  static const String _migratedKey = 'chat_db_migrated_v1';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPrefsAndLoad();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // SQLite 即时落盘，不需要在 lifecycle 变化时做任何保存操作
    // 消息在发送/接收时已经写入数据库
    debugPrint('[ChatScreen] lifecycle: $state (no save needed - SQLite)');
  }

  Future<void> _initPrefsAndLoad() async {
    _prefs = await SharedPreferences.getInstance();
    // 迁移 SharedPreferences 旧数据到 SQLite（仅执行一次）
    await _migrateFromSharedPreferences();
    // 从 SQLite 加载消息
    await _loadMessages();
  }

  /// 从 SharedPreferences 迁移旧聊天数据到 SQLite（一次性操作）
  Future<void> _migrateFromSharedPreferences() async {
    if (_prefs == null) return;
    final migrated = _prefs!.getBool(_migratedKey) ?? false;
    if (migrated) return; // 已迁移过，跳过

    final oldKey = 'chat_messages_local_user';
    final oldData = _prefs!.getString(oldKey);
    if (oldData != null && oldData.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(oldData);
        final oldMessages = jsonList
            .map((m) => ConversationMessage.fromMap(m as Map<String, dynamic>, 'local_user'))
            .toList();
        if (oldMessages.isNotEmpty) {
          await ChatDatabase.insertMessages(oldMessages);
          debugPrint('[ChatScreen] Migrated ${oldMessages.length} messages from SharedPreferences to SQLite');
        }
      } catch (e) {
        debugPrint('[ChatScreen] Migration error (non-critical): $e');
      }
    }
    // 标记已迁移
    await _prefs!.setBool(_migratedKey, true);
    // 清理旧数据释放空间
    await _prefs!.remove(oldKey);
    await _prefs!.commit();
  }

  /// 从 SQLite 加载消息
  Future<void> _loadMessages() async {
    try {
      final loaded = await ChatDatabase.loadMessages();
      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(loaded);
          _hasGreeted = loaded.isNotEmpty; // 有历史消息说明已经问候过了
        });
      }
      _scrollToBottom();
      debugPrint('[ChatScreen] Loaded ${loaded.length} messages from SQLite');

      // 没有历史消息 → 发送主动问候
      if (loaded.isEmpty && !_hasGreeted) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted && !_hasGreeted) {
            _sendProactiveGreeting();
          }
        });
      }
    } catch (e) {
      debugPrint('[ChatScreen] Failed to load messages: $e');
      // 没有历史消息 → 发送主动问候
      if (!_hasGreeted) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted && !_hasGreeted) {
            _sendProactiveGreeting();
          }
        });
      }
    }
  }

  /// 发送主动E型人格问候
  void _sendProactiveGreeting() {
    final now = DateTime.now();
    String timeGreeting;
    final hour = now.hour;
    if (hour < 6) {
      timeGreeting = '夜深了';
    } else if (hour < 9) {
      timeGreeting = '早上好呀';
    } else if (hour < 12) {
      timeGreeting = '上午好';
    } else if (hour < 14) {
      timeGreeting = '中午好';
    } else if (hour < 18) {
      timeGreeting = '下午好';
    } else if (hour < 22) {
      timeGreeting = '晚上好';
    } else {
      timeGreeting = '夜深了';
    }

    setState(() {
      _hasGreeted = true;
      _isLoading = true; // 防止用户在AI回复时重复发送
    });

    // 直接调用 AI 获取主动问候
    _sendAIMessageForGreeting(timeGreeting);
  }

  Future<void> _sendAIMessageForGreeting(String timeGreeting) async {
    try {
      final provider = AppConfig.provider;
      final apiKey = AppConfig.aiApiKey;
      final model = AppConfig.model;

      final aiService = AIService(
        apiKey: apiKey,
        provider: provider,
        model: model,
      );

      final userProfileContext = UserProfileService().getProfileSummary();

      // 构造主动问候的提示词
      final greetingPrompt = '【系统指令：请用温暖、主动、E型人格的方式开场】\n\n'
          '$timeGreeting！我是小树苗 🌱\n\n'
          '请你主动地跟用户打个招呼，并自然地引导话题。你可以：\n'
          '- 根据时间问一句贴心的话（比如"今天过得怎么样？""早上忙吗？"）\n'
          '- 如果有家庭档案信息，可以温柔地提及（用孩子的昵称或自然地称呼"小朋友""宝贝"等，**绝对不要用XX或某某这种代号称呼孩子！这是不礼貌的**）\n'
          '- 抛出1-2个轻松的话题引导用户开口（比如最近孩子有趣的事、家长的困扰、或者随便聊聊天）\n'
          '- 如果用户还没有填写家庭档案，可以温柔提醒一下（"如果你愿意的话，可以在设置里补充家庭档案，这样我能更好地陪你聊～"）\n\n'
          '要求：简短、真诚、像老朋友一样自然，不要长篇大论。100字以内。';

      final botMessageIndex = _messages.length;
      setState(() {
        _messages.add(ConversationMessage(
          userId: 'local_user',
          sender: MessageSender.bot,
          content: '',
          category: ConversationCategory.generalChat,
          timestamp: DateTime.now(),
        ));
      });

      String botResponse = '';
      await for (final chunk in aiService.chatStream(
        history: [],
        userMessage: greetingPrompt,
        userProfileContext: userProfileContext,
        category: ConversationCategory.generalChat,
      )) {
        botResponse = chunk;
        if (mounted) {
          setState(() {
            _messages[botMessageIndex] = ConversationMessage(
              userId: 'local_user',
              sender: MessageSender.bot,
              content: botResponse,
              category: ConversationCategory.generalChat,
              timestamp: DateTime.now(),
            );
          });
          _scrollToBottom();
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
        // AI 问候完成，即时写入数据库
        await ChatDatabase.insertMessage(_messages[botMessageIndex]);
      }
    } catch (e) {
      debugPrint('[ChatScreen] Greeting error: $e');
      // fallback 固定问候语
      if (mounted) {
        final fallbackMsg = '$timeGreeting～ 小树苗来啦 🌱\n\n'
            '我是一株专门陪着你聊家庭教育的小树苗。'
            '有什么想说的、想问的、甚至只是想发发牢骚——都可以慢慢讲。\n\n'
            '我在这里，扎根听 🌿';
        if (_messages.isNotEmpty &&
            _messages.last.sender == MessageSender.bot &&
            _messages.last.content.isEmpty) {
          setState(() {
            _messages[_messages.length - 1] = ConversationMessage(
              userId: 'local_user',
              sender: MessageSender.bot,
              content: fallbackMsg,
              category: ConversationCategory.generalChat,
              timestamp: DateTime.now(),
            );
          });
        } else {
          setState(() {
            _messages.add(ConversationMessage(
              userId: 'local_user',
              sender: MessageSender.bot,
              content: fallbackMsg,
              category: ConversationCategory.generalChat,
              timestamp: DateTime.now(),
            ));
          });
        }
        setState(() => _isLoading = false);
        // 即时写入数据库（fallback 问候语）
        await ChatDatabase.insertMessage(_messages.last);
        _scrollToBottom();
      }
    }
  }

  /// 保存消息（兼容旧调用，SQLite模式下不需要手动保存，消息已即时落盘）
  Future<void> _saveMessages() async {
    // SQLite 模式：每条消息在添加时已经即时写入数据库
    // 此方法保留为空，仅兼容旧代码调用
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _isLoading = true;
      _messages.add(ConversationMessage(
        userId: 'local_user',
        sender: MessageSender.user,
        content: text,
        category: ConversationCategory.generalChat,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
    });
    // 即时写入数据库（用户消息）
    await ChatDatabase.insertMessage(_messages.last);
    _scrollToBottom();

    try {
      final provider = AppConfig.provider;
      final apiKey = AppConfig.aiApiKey;
      final model = AppConfig.model;

      if (provider != 'ollama' && apiKey.isEmpty) {
        throw Exception('未配置 API Key');
      }

      final aiService = AIService(
        apiKey: apiKey,
        provider: provider,
        model: model,
      );

      final userProfileContext = UserProfileService().getProfileSummary();

      final historyForAI = _messages
          .where((m) => m.sender == MessageSender.user || m.sender == MessageSender.bot)
          .where((m) => m.content.isNotEmpty)
          .toList();

      // 添加空的 bot 消息占位
      final botMessageIndex = _messages.length;
      setState(() {
        _messages.add(ConversationMessage(
          userId: 'local_user',
          sender: MessageSender.bot,
          content: '',
          category: ConversationCategory.generalChat,
          timestamp: DateTime.now(),
        ));
      });

      String botResponse = '';
      await for (final chunk in aiService.chatStream(
        history: historyForAI,
        userMessage: text,
        userProfileContext: userProfileContext,
        category: ConversationCategory.generalChat,
      )) {
        botResponse = chunk;
        if (mounted) {
          setState(() {
            _messages[botMessageIndex] = ConversationMessage(
              userId: 'local_user',
              sender: MessageSender.bot,
              content: botResponse,
              category: ConversationCategory.generalChat,
              timestamp: DateTime.now(),
            );
          });
          _scrollToBottom();
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
        // AI 回复完成，即时写入数据库
        await ChatDatabase.insertMessage(_messages[botMessageIndex]);

        final fullResponse =
            _messages.lastWhere((m) => m.sender == MessageSender.bot).content;
        UserProfileService().extractAndUpdateProfile(
          userMessage: text,
          aiResponse: fullResponse,
        );
      }
    } catch (e) {
      debugPrint('Chat error: $e');
      String fallbackResponse;
      try {
        fallbackResponse = OfflineAI.generateResponse(text, null);
      } catch (_) {
        fallbackResponse = '抱歉，网络好像有问题 😅\n\n请检查一下网络连接，稍后再试。\n\n如果持续无法使用，也可以把问题写下来，等网络恢复后再来找我聊 💕';
      }

      if (mounted) {
        setState(() {
          if (_messages.isNotEmpty &&
              _messages.last.sender == MessageSender.bot &&
              _messages.last.content.isEmpty) {
            _messages.removeLast();
          }
          _messages.add(ConversationMessage(
            userId: 'local_user',
            sender: MessageSender.bot,
            content: fallbackResponse,
            category: ConversationCategory.generalChat,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
        // 即时写入数据库（fallback 回复）
        await ChatDatabase.insertMessage(_messages.last);
        _scrollToBottom();
      }
    }
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('清空对话', style: TextStyle(fontWeight: FontWeight.w600)),
        content: Text('确定要清空所有聊天记录吗？这个操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: TextStyle(color: Color(0xFF8B9A8E))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
              });
              // 从数据库删除所有消息
              ChatDatabase.deleteAllMessages();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('聊天记录已清空'),
                    ],
                  ),
                  backgroundColor: Color(0xFF6B9E78),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: Text('清空', style: TextStyle(color: Color(0xFFE57373), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // SQLite 模式：消息已即时落盘，不需要在 dispose 时保存
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ===== 简笔画风格配色 =====
    final bgColor = isDark ? const Color(0xFF1A1F2E) : const Color(0xFFFDFBF7); // 更暖的米白
    final primaryColor = const Color(0xFF6B9E78);
    final outlineColor = const Color(0xFF2D2D2D); // 粗描边颜色
    final surfaceColor = isDark ? const Color(0xFF232A3A) : Colors.white;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        // 防止 SplashScreen pushReplacement 时误触发
        if (_prefs == null) return;

        // 双击退出：第一次显示提示，第二次才退出APP
        final now = DateTime.now();
        if (_lastBackPressTime != null &&
            now.difference(_lastBackPressTime!).inMilliseconds < 2000) {
          // 第二次按返回 → 直接退出APP（消息已即时写入数据库，无需保存）
          SystemNavigator.pop();
        } else {
          // 第一次按返回 → 显示提示
          _lastBackPressTime = now;

          // 显示 Toast 提示
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app_rounded, color: Colors.white70, size: 16),
                    SizedBox(width: 8),
                    Text('再滑动一次退出', style: TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
                backgroundColor: const Color(0xFF6B9E78),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                duration: const Duration(seconds: 2),
              ),
            );
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
            // AppBar - 简笔画风格
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF2D2D2D).withOpacity(isDark ? 0.3 : 0.08),
                    width: 1.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // 小树苗图标（填满容器，无空余）
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 38,
                      height: 38,
                      fit: BoxFit.fill, // fill 强制填满，不留空
                      errorBuilder: (_, __, ___) => Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(child: Text('🌱', style: TextStyle(fontSize: 22))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 标题
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '陪伴小树苗',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '你的家庭教育心理陪伴师',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 设置按钮
                  _buildSketchIconButton(
                    icon: Icons.menu_rounded,
                    onTap: () async {
                      _inputFocusNode.unfocus();
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(
                            onChatCleared: () {
                              if (mounted) {
                                setState(() {
                                  _messages.clear();
                                });
                              }
                            },
                          ),
                        ),
                      );
                      _loadMessages();
                    },
                    tooltip: '设置',
                  ),
                ],
              ),
            ),

            // 消息列表
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState(theme, isDark)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(_messages[index], theme, isDark);
                      },
                    ),
            ),

            // 输入区域 - 简笔画风格
            _buildSketchInputArea(theme, isDark),
          ],
        ),
      ),
      ),
    );
  }

  // ===== 简笔画风格图标按钮 =====
  Widget _buildSketchIconButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 22, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 简笔画风格头像容器 - 带手绘边框
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF6B9E78).withOpacity(0.25),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B9E78).withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFF5F0EB),
                        child: const Center(
                          child: Text('🌱', style: TextStyle(fontSize: 42)),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // 手绘风格标题
              Text(
                '你好呀，我是小树苗 💕',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '你的家庭教育心理陪伴师',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.45),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 28),
              // 快捷话题 - 简笔画风格 Chip
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _buildSketchChip('孩子作业拖拉', theme),
                  _buildSketchChip('亲子沟通困难', theme),
                  _buildSketchChip('青春期叛逆', theme),
                  _buildSketchChip('情绪管理', theme),
                ],
              ),
              const SizedBox(height: 24),
              // 手绘风格装饰线
              Container(
                width: 60,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B9E78).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 简笔画风格快捷话题 Chip
  Widget _buildSketchChip(String text, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.15),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            _messageController.text = text;
            _sendMessage();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===== 简笔画风格消息气泡 =====
  Widget _buildMessageBubble(
    ConversationMessage message,
    ThemeData theme,
    bool isDark,
  ) {
    final isUser = message.sender == MessageSender.user;
    final cleanContent = _cleanMarkdownText(message.content);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            // AI 头像 - 简笔画边框
            Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF6B9E78).withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/app_icon.png',
                  width: 35,
                  height: 35,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: isDark ? const Color(0xFF3A4555) : const Color(0xFFE8E2DA),
                      child: const Center(
                        child: Text('🌱', style: TextStyle(fontSize: 19)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          // 消息气泡 - 简笔画风格
          Flexible(
            child: GestureDetector(
              onLongPress: () => _copyToClipboard(cleanContent),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  color: isUser
                      ? (isDark ? const Color(0xFF4A7A55) : const Color(0xFF6B9E78))
                      : (isDark ? const Color(0xFF2A3344) : Colors.white),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(6),
                    bottomRight: isUser ? const Radius.circular(6) : const Radius.circular(18),
                  ),
                  border: Border.all(
                    color: (isUser
                            ? (isDark ? const Color(0xFF4A7A55) : const Color(0xFF6B9E78))
                            : Colors.white)
                        .withOpacity(isUser ? 0.3 : 0.5),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isUser
                              ? (isDark ? const Color(0xFF4A7A55) : const Color(0xFF6B9E78))
                              : Colors.black)
                          .withOpacity(isUser ? 0.15 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      cleanContent,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.65,
                        color: isUser ? Colors.white : theme.colorScheme.onSurface,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            fontSize: 10.5,
                            color: (isUser
                                    ? Colors.white.withOpacity(0.65)
                                    : theme.colorScheme.onSurface.withOpacity(0.35)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isUser) ...[
            // 用户头像 - 简笔画圆圈
            Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3A4555) : const Color(0xFFE8E2DA),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.onSurface.withOpacity(0.08),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 18,
                  color: isDark ? Colors.white70 : const Color(0xFF8B9A8E),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 清理消息内容中的 Markdown / LaTeX 等格式符号
  String _cleanMarkdownText(String text) {
    var result = text;

    result = result.replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => m.group(1) ?? '');
    result = result.replaceAllMapped(RegExp(r'\*(.+?)\*'), (m) => m.group(1) ?? '');
    result = result.replaceAll('`', '');
    result = result.replaceAll(RegExp(r'\n?\s*---+\s*\n?'), '\n');
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // 清除所有 $ 符号及 LaTeX 残留
    result = result.replaceAll('\$', '');

    return result.trim();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('已复制到剪贴板'),
          ],
        ),
        backgroundColor: const Color(0xFF4A7A55),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 40),
      ),
    );
  }

  // ===== 简笔画风格输入区域 =====
  Widget _buildSketchInputArea(ThemeData theme, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 免责声明
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 12, color: isDark ? Colors.white54 : const Color(0xFFB0A898)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '小树苗是AI陪伴与支持，不替代医院与专业心理咨询',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark ? Colors.white54 : const Color(0xFFB0A898),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 输入框区域 - 简笔画手绘风格
        Container(
          margin: const EdgeInsets.fromLTRB(10, 4, 10, 8),
          padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2535) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFF2D2D2D).withOpacity(isDark ? 0.2 : 0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                blurRadius: 14,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  focusNode: _inputFocusNode,
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: 0.2,
                  ),
                  decoration: InputDecoration(
                    hintText: '说点什么...',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.28),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 6),

              // 发送按钮 - 简笔画风格圆形
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: _isLoading ? null : _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isLoading
                          ? theme.colorScheme.primary.withOpacity(0.3)
                          : const Color(0xFF6B9E78),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6B9E78).withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withOpacity(0.85),
                                ),
                              ),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
