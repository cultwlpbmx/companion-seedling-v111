import 'package:flutter/foundation.dart';

enum MessageSender { user, bot }

enum ConversationCategory {
  dailyCheckIn,    // 日常签到
  emotionalSupport, // 情绪支持
  educationAdvice, // 教育建议
  workLifeBalance, // 工作生活平衡
  crisis,          // 危机干预
  generalChat,     // 一般聊天
}

class ConversationMessage {
  final String? id;
  final String userId;
  final String? childId; // 如果针对性对话
  final MessageSender sender;
  final String content;
  final ConversationCategory category;
  final DateTime timestamp;
  final String? context; // 引用上下文（如特定问题主题）

  ConversationMessage({
    this.id,
    required this.userId,
    this.childId,
    required this.sender,
    required this.content,
    required this.category,
    required this.timestamp,
    this.context,
  });

  factory ConversationMessage.fromMap(
      Map<String, dynamic> data, String userId) {
    DateTime parseTimestamp(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value.toString().contains('Timestamp')) {
        try {
          final seconds = value.seconds as int? ?? 0;
          final nanoseconds = value.nanoseconds as int? ?? 0;
          return DateTime.fromMillisecondsSinceEpoch(
              seconds * 1000 + nanoseconds ~/ 1000000);
        } catch (_) {
          return DateTime.now();
        }
      }
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value * 1000);
      }
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return ConversationMessage(
      id: data['id'],
      userId: userId,
      childId: data['childId'],
      sender: MessageSender.values.byName(data['sender']),
      content: data['content'] ?? '',
      category: ConversationCategory.values.byName(data['category']),
      timestamp: parseTimestamp(data['timestamp']),
      context: data['context'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'childId': childId,
      'sender': sender.name,
      'content': content,
      'category': category.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'context': context,
    };
  }
}

class ConversationSession {
  final String? id;
  final String userId;
  final String? childId;
  final ConversationCategory category;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int messageCount;
  final String? summary; // 对话摘要

  ConversationSession({
    this.id,
    required this.userId,
    this.childId,
    required this.category,
    required this.startedAt,
    this.endedAt,
    required this.messageCount,
    this.summary,
  });

  factory ConversationSession.fromMap(
      Map<String, dynamic> data, String userId) {
    DateTime parseTimestamp(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value.toString().contains('Timestamp')) {
        try {
          final seconds = value.seconds as int? ?? 0;
          final nanoseconds = value.nanoseconds as int? ?? 0;
          return DateTime.fromMillisecondsSinceEpoch(
              seconds * 1000 + nanoseconds ~/ 1000000);
        } catch (_) {
          return DateTime.now();
        }
      }
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value * 1000);
      }
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return ConversationSession(
      id: data['id'],
      userId: userId,
      childId: data['childId'],
      category: ConversationCategory.values.byName(data['category']),
      startedAt: parseTimestamp(data['startedAt']),
      endedAt: parseTimestamp(data['endedAt']),
      messageCount: data['messageCount'] ?? 0,
      summary: data['summary'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'childId': childId,
      'category': category.name,
      'startedAt': startedAt.millisecondsSinceEpoch,
      'endedAt': endedAt?.millisecondsSinceEpoch,
      'messageCount': messageCount,
      'summary': summary,
    };
  }
}