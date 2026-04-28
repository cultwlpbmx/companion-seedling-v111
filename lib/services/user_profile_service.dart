import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';

/// 用户画像服务 - 管理用户画像的存储、读取和更新
/// 无需登录，使用固定的 local_user ID
class UserProfileService {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  SharedPreferences? _prefs;
  UserProfile? _cachedProfile;

  static const String _profileKey = 'user_profile_local_user';

  /// 初始化
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadProfile();
  }

  /// 加载用户画像
  Future<void> _loadProfile() async {
    try {
      final data = _prefs?.getString(_profileKey);
      if (data != null && data.isNotEmpty) {
        final json = jsonDecode(data) as Map<String, dynamic>;
        _cachedProfile = UserProfile.fromJson(json);
        debugPrint('✅ 用户画像已加载');
      }
    } catch (e) {
      debugPrint('加载用户画像失败：$e');
    }
  }

  /// 获取当前用户画像
  UserProfile? get currentProfile {
    if (_cachedProfile == null) {
      _cachedProfile = UserProfile(
        userId: 'local_user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    return _cachedProfile;
  }

  /// 异步获取当前用户画像
  Future<UserProfile> getCurrentUserProfile() async {
    if (_cachedProfile != null) return _cachedProfile!;
    await _loadProfile();
    return currentProfile ?? UserProfile(
      userId: 'local_user',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 更新用户画像
  Future<void> updateProfile(UserProfile profile) async {
    if (_prefs == null) return;

    try {
      final json = profile.toJson();
      await _prefs!.setString(_profileKey, jsonEncode(json));
      _cachedProfile = profile;
      debugPrint('✅ 用户画像已更新');
    } catch (e) {
      debugPrint('保存用户画像失败：$e');
    }
  }

  /// 从对话中提取信息并更新画像
  Future<void> extractAndUpdateProfile({
    required String userMessage,
    required String aiResponse,
  }) async {
    try {
      // 调用 AI 提取用户信息
      final extractedInfo = await _extractUserInfo(userMessage, aiResponse);
      
      if (extractedInfo.isNotEmpty) {
        final profile = currentProfile ?? UserProfile(
          userId: 'local_user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // 更新画像
        final updatedProfile = profile.copyWith(
          parentRole: extractedInfo['parentRole'] ?? profile.parentRole,
          personalityTraits: _mergeLists(
            profile.personalityTraits,
            extractedInfo['personalityTraits'] as List<String>? ?? [],
          ),
          strengths: _mergeLists(
            profile.strengths,
            extractedInfo['strengths'] as List<String>? ?? [],
          ),
          challenges: _mergeLists(
            profile.challenges,
            extractedInfo['challenges'] as List<String>? ?? [],
          ),
          thinkingStyle: extractedInfo['thinkingStyle'] ?? profile.thinkingStyle,
          communicationStyle: extractedInfo['communicationStyle'] ?? profile.communicationStyle,
          parentingPhilosophy: extractedInfo['parentingPhilosophy'] ?? profile.parentingPhilosophy,
          childrenInfo: _mergeChildrenInfo(profile.childrenInfo, extractedInfo['childrenInfo']),
          conversationHighlights: _addHighlight(
            profile.conversationHighlights,
            userMessage,
            aiResponse,
          ),
        );

        await updateProfile(updatedProfile);
        debugPrint('✅ 从对话中提取并更新了用户信息');
      }
    } catch (e) {
      debugPrint('提取用户信息失败：$e');
    }
  }

  /// 合并列表（去重）
  List<String> _mergeLists(List<String> existing, List<String> newItems) {
    final merged = {...existing, ...newItems};
    return merged.toList();
  }

  /// 合并孩子信息
  List<Map<String, dynamic>> _mergeChildrenInfo(
    List<Map<String, dynamic>> existing,
    List<Map<String, dynamic>>? newInfo,
  ) {
    if (newInfo == null || newInfo.isEmpty) return existing;
    
    // 简单实现：直接合并，后续可以优化去重逻辑
    return [...existing, ...newInfo];
  }

  /// 添加对话摘要
  List<Map<String, dynamic>> _addHighlight(
    List<Map<String, dynamic>> existing,
    String userMessage,
    String aiResponse,
  ) {
    // 提取关键信息（简化版：记录话题和日期）
    final highlight = {
      'date': DateTime.now().toIso8601String().split('T')[0],
      'topic': _extractTopic(userMessage),
      'insight': _extractInsight(aiResponse),
      'userMessage': userMessage.length > 50 ? userMessage.substring(0, 50) + '...' : userMessage,
    };

    // 只保留最近 20 条
    final updated = [highlight, ...existing];
    return updated.length > 20 ? updated.sublist(0, 20) : updated;
  }

  /// 提取话题（简化版：取前 10 个字）
  String _extractTopic(String message) {
    if (message.length <= 10) return message;
    return message.substring(0, 10) + '...';
  }

  /// 提取洞察（简化版：从 AI 回复中取关键句）
  String _extractInsight(String response) {
    final lines = response.split('\n');
    // 找包含"建议""可以""试试"等关键词的句子
    for (final line in lines) {
      if (line.contains('建议') || line.contains('可以') || line.contains('试试')) {
        return line.length > 30 ? line.substring(0, 30) + '...' : line;
      }
    }
    return response.length > 30 ? response.substring(0, 30) + '...' : response;
  }

  /// 调用 AI 提取用户信息
  Future<Map<String, dynamic>> _extractUserInfo(
    String userMessage,
    String aiResponse,
  ) async {
    // 这里调用 AI 服务，让它从对话中提取用户信息
    // 简化实现：返回空 map，后续完善
    return {};
  }

  /// 获取画像摘要（供 AI 调用）
  String? getProfileSummary() {
    return currentProfile?.getSummary();
  }

  /// 清除画像
  Future<void> clearProfile() async {
    await _prefs?.remove(_profileKey);
    _cachedProfile = null;
    debugPrint('✅ 用户画像已清除');
  }
}
