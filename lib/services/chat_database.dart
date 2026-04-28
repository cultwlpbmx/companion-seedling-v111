import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/conversation_model.dart';

/// 聊天消息数据库服务
/// 使用 SQLite 替代 SharedPreferences，确保每条消息即时写入磁盘
/// 参考微信/Telegram做法：消息即时落盘，退出不需要额外保存
class ChatDatabase {
  static Database? _db;
  static const String _tableName = 'chat_messages';

  /// 获取数据库实例（单例）
  static Future<Database> get database async {
    if (_db != null && _db!.isOpen) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'seedling_chat.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            sender TEXT NOT NULL,
            content TEXT NOT NULL,
            category TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            child_id TEXT,
            context TEXT
          )
        ''');
        // 创建时间索引，加速查询
        await db.execute(
          'CREATE INDEX idx_messages_timestamp ON $_tableName (timestamp)',
        );
      },
    );
  }

  /// 插入一条消息（即时写入磁盘）
  static Future<void> insertMessage(ConversationMessage msg) async {
    final db = await database;
    await db.insert(_tableName, {
      'user_id': msg.userId,
      'sender': msg.sender.name,
      'content': msg.content,
      'category': msg.category.name,
      'timestamp': msg.timestamp.millisecondsSinceEpoch,
      'child_id': msg.childId,
      'context': msg.context,
    });
  }

  /// 批量插入消息（用于从 SharedPreferences 迁移旧数据）
  static Future<void> insertMessages(List<ConversationMessage> messages) async {
    final db = await database;
    final batch = db.batch();
    for (final msg in messages) {
      batch.insert(_tableName, {
        'user_id': msg.userId,
        'sender': msg.sender.name,
        'content': msg.content,
        'category': msg.category.name,
        'timestamp': msg.timestamp.millisecondsSinceEpoch,
        'child_id': msg.childId,
        'context': msg.context,
      });
    }
    await batch.commit(noResult: true);
  }

  /// 加载所有消息（按时间排序）
  static Future<List<ConversationMessage>> loadMessages({String userId = 'local_user'}) async {
    final db = await database;
    final rows = await db.query(
      _tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp ASC',
    );

    return rows.map((row) {
      return ConversationMessage(
        id: row['id'].toString(),
        userId: row['user_id'] as String,
        sender: MessageSender.values.byName(row['sender'] as String),
        content: row['content'] as String,
        category: ConversationCategory.values.byName(row['category'] as String),
        timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
        childId: row['child_id'] as String?,
        context: row['context'] as String?,
      );
    }).toList();
  }

  /// 删除所有消息
  static Future<void> deleteAllMessages({String userId = 'local_user'}) async {
    final db = await database;
    await db.delete(_tableName, where: 'user_id = ?', whereArgs: [userId]);
  }

  /// 获取消息数量
  static Future<int> getMessageCount({String userId = 'local_user'}) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE user_id = ?',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 关闭数据库
  static Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
