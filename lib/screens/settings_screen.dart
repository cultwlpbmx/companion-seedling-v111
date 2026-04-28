import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/user_profile_service.dart';
import '../services/chat_database.dart';
import '../models/conversation_model.dart';
import 'family_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onChatCleared;

  const SettingsScreen({super.key, this.onChatCleared});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部栏 - 简笔画风格
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                    color: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '设置',
                    style: theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ===== 家庭档案卡片 =====
                    _buildSketchCard(theme: theme, isDark: isDark, child: _buildMenuTile(
                      theme: theme,
                      icon: Icons.family_restroom_rounded,
                      iconBgColor: const Color(0xFF6B9E78),
                      title: '家庭档案',
                      subtitle: '编辑孩子和家庭成员信息，让AI更了解你',
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FamilyProfileScreen()),
                        );
                        setState(() {});
                      },
                    )),

                    const SizedBox(height: 14),

                    // ===== 聊天历史 =====
                    _buildSketchCard(theme: theme, isDark: isDark, child: _buildMenuTile(
                      theme: theme,
                      icon: Icons.history_rounded,
                      iconBgColor: const Color(0xFF6B9E78),
                      title: '聊天历史',
                      subtitle: '查看过往的对话记录',
                      onTap: () => _showChatHistory(context),
                    )),

                    const SizedBox(height: 14),
                    _buildSketchCard(theme: theme, isDark: isDark, child: Column(
                      children: [
                        _buildMenuTile(
                          theme: theme,
                          icon: Icons.delete_sweep_rounded,
                          iconBgColor: const Color(0xFFE57373),
                          title: '清空聊天记录',
                          subtitle: '删除所有对话，不可恢复',
                          onTap: _showClearChatDialog,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          height: 1.2,
                          color: const Color(0xFF2D2D2D).withOpacity(isDark ? 0.15 : 0.06),
                        ),
                        _buildMenuTile(
                          theme: theme,
                          icon: Icons.person_remove_rounded,
                          iconBgColor: const Color(0xFFFFA726),
                          title: '重置用户画像',
                          subtitle: '清除AI对你的了解，重新开始',
                          onTap: _showResetProfileDialog,
                        ),
                      ],
                    )),

                    const SizedBox(height: 14),

                    // ===== 关于 =====
                    _buildSketchCard(theme: theme, isDark: isDark, child: Column(
                      children: [
                        _buildMenuTile(
                          theme: theme,
                          icon: Icons.info_outline_rounded,
                          iconBgColor: const Color(0xFF90A4AE),
                          title: '关于',
                          subtitle: '陪伴小树苗 v3.1 — 完全免费的AI陪伴',
                          trailing: null,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          height: 1.2,
                          color: const Color(0xFF2D2D2D).withOpacity(isDark ? 0.15 : 0.06),
                        ),
                        _buildMenuTile(
                          theme: theme,
                          icon: Icons.lock_outline_rounded,
                          iconBgColor: const Color(0xFF6B9E78),
                          title: '隐私说明',
                          subtitle: '所有数据仅保存在你的手机上，绝不上传',
                          trailing: null,
                        ),
                      ],
                    )),

                    const SizedBox(height: 40),

                    // 简笔画风格装饰
                    Center(
                      child: Text(
                        '🌱 用爱陪伴每一棵小树苗',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 简笔画风格卡片容器
  Widget _buildSketchCard({
    required ThemeData theme,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF2D2D2D).withOpacity(isDark ? 0.18 : 0.08),
          width: 1.4,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: child,
      ),
    );
  }

  Widget _buildMenuTile({
    required ThemeData theme,
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              // 简笔画风格图标圆圈
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBgColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: iconBgColor.withOpacity(0.18),
                    width: 1.2,
                  ),
                ),
                child: Icon(icon, size: 21, color: iconBgColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.43),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.onSurface.withOpacity(0.25),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示聊天历史记录
  void _showChatHistory(BuildContext context) async {
    // 从 SQLite 数据库加载
    final messages = await ChatDatabase.loadMessages();

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ChatHistoryScreen(messages: messages),
      ),
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('清空聊天记录', style: TextStyle(fontWeight: FontWeight.w600)),
        content: Text('确定要删除所有对话记录吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消', style: TextStyle(color: Color(0xFF8B9A8E))),
          ),
          TextButton(
            onPressed: () async {
              // 从 SQLite 数据库删除
              await ChatDatabase.deleteAllMessages();
              if (mounted) {
                Navigator.pop(ctx);
                widget.onChatCleared?.call();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('聊天记录已清空'),
                      ],
                    ),
                    backgroundColor: const Color(0xFF6B9E78),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text('清空', style: TextStyle(color: Color(0xFFE57373), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showResetProfileDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('重置用户画像', style: TextStyle(fontWeight: FontWeight.w600)),
        content: Text('AI将忘记对你的所有了解，就像初次见面一样。确定吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消', style: TextStyle(color: Color(0xFF8B9A8E))),
          ),
          TextButton(
            onPressed: () async {
              await UserProfileService().clearProfile();
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('用户画像已重置'),
                      ],
                    ),
                    backgroundColor: const Color(0xFF6B9E78),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text('重置', style: TextStyle(color: Color(0xFFFFA726), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// 聊天历史记录页面
class _ChatHistoryScreen extends StatelessWidget {
  final List<dynamic> messages; // ConversationMessage 列表

  const _ChatHistoryScreen({required this.messages});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '聊天历史',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        centerTitle: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: messages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 56,
                      color: theme.colorScheme.onSurface.withOpacity(0.15)),
                  SizedBox(height: 16),
                  Text(
                    '还没有聊天记录',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '去和小树苗聊聊天吧 🌱',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final msg = messages[index] as ConversationMessage;
                final isUser = msg.sender == MessageSender.user;
                final content = msg.content;
                if (content.isEmpty) return const SizedBox.shrink();

                final timestamp = msg.timestamp;

                return Row(
                  mainAxisAlignment:
                      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isUser) ...[
                      Container(
                        width: 30,
                        height: 30,
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
                            fit: BoxFit.fill,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFF6B9E78).withOpacity(0.1),
                              child: const Center(child: Text('🌱', style: TextStyle(fontSize: 14))),
                            ),
                          ),
                        ),
                      ),
                    ],
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.72,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isUser
                              ? const Color(0xFF6B9E78)
                              : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(6),
                            bottomRight: isUser ? const Radius.circular(6) : const Radius.circular(16),
                          ),
                          border: Border.all(
                            color: (isUser ? const Color(0xFF6B9E78) : Colors.grey)
                                .withOpacity(isUser ? 0.25 : 0.12),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                              content.replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1')
                                  .replaceAll('*', '')
                                  .replaceAll('`', ''),
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.55,
                                color: isUser ? Colors.white : theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                                '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: (isUser ? Colors.white : theme.colorScheme.onSurface).withOpacity(0.35),
                                )),
                          ],
                        ),
                      ),
                    ),
                    if (isUser)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: isDark ? const Color(0xFF3A4555) : const Color(0xFFE8E2DA),
                          child: Icon(Icons.person, size: 14,
                              color: isDark ? Colors.white70 : const Color(0xFF8B9A8E)),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}
