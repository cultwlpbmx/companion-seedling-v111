/// 本地数据服务 - 极简版
/// 取消登录/注册，自动创建匿名本地用户
/// 所有数据存储在 SharedPreferences 中

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地用户（匿名，始终存在）
class LocalUser {
  final String uid;
  const LocalUser({required this.uid});
}

/// 模拟 Collection Reference（简化版，保留 API 兼容）
class LocalCollectionRef {
  final String collectionName;
  final SharedPreferences _prefs;

  LocalCollectionRef(this.collectionName, this._prefs);

  LocalDocRef doc(String docId) => LocalDocRef(collectionName, docId, _prefs);

  Future<List<LocalDocRef>> where(String field, String value) async {
    final key = '${collectionName}_index_$field';
    final indexData = _prefs.getString(key);
    if (indexData == null) return [];
    try {
      final index = jsonDecode(indexData) as Map<String, dynamic>;
      final docIds = (index[value] as List<dynamic>?) ?? [];
      return docIds.map((id) => LocalDocRef(collectionName, id.toString(), _prefs)).toList();
    } catch (_) {
      return [];
    }
  }
}

/// 模拟 Document Reference
class LocalDocRef {
  final String collectionName;
  final String docId;
  final SharedPreferences _prefs;

  LocalDocRef(this.collectionName, this.docId, this._prefs);

  String get _key => '${collectionName}_$docId';

  Future<void> set(Map<String, dynamic> data) async {
    await _prefs.setString(_key, jsonEncode(data));
    for (final entry in data.entries) {
      final indexKey = '${collectionName}_index_${entry.key}';
      final existing = _prefs.getString(indexKey);
      Map<String, dynamic> index = {};
      if (existing != null) {
        try { index = jsonDecode(existing); } catch (_) {}
      }
      final val = entry.value.toString();
      if (index[val] == null) {
        index[val] = [docId];
      } else {
        final list = List<String>.from(index[val] as List);
        if (!list.contains(docId)) list.add(docId);
        index[val] = list;
      }
      await _prefs.setString(indexKey, jsonEncode(index));
    }
  }

  Future<Map<String, dynamic>?> get() async {
    final data = _prefs.getString(_key);
    if (data == null) return null;
    try { return jsonDecode(data) as Map<String, dynamic>; } catch (_) { return null; }
  }
}

/// 本地数据服务（单例）- 无需登录
class LocalDataService {
  static final LocalDataService _instance = LocalDataService._internal();
  factory LocalDataService() => _instance;
  LocalDataService._internal();

  SharedPreferences? _prefs;
  late LocalUser _currentUser;

  late LocalCollectionRef usersCollection;
  late LocalCollectionRef childrenCollection;
  late LocalCollectionRef conversationsCollection;

  static const String _localUserId = 'local_user';

  /// 初始化 - 自动创建匿名用户
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    usersCollection = LocalCollectionRef('users', _prefs!);
    childrenCollection = LocalCollectionRef('children', _prefs!);
    conversationsCollection = LocalCollectionRef('conversations', _prefs!);

    _currentUser = const LocalUser(uid: _localUserId);
    debugPrint('✅ 本地服务已初始化（匿名用户）');
  }

  /// 当前用户（始终存在）
  LocalUser get currentUser => _currentUser;

  /// 始终为 true
  bool get isLoggedIn => true;
}
