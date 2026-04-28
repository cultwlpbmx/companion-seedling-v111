/// 用户画像模型 - 记录 AI 通过对话了解到的用户信息
/// 这些数据用户看不到，只有 AI 能调用，用于提供更个性化的建议

class UserProfile {
  final String userId;
  
  // 基础信息
  final String? parentRole; // 爸爸/妈妈/其他
  final int? ageRange; // 年龄段：1=20-30, 2=31-40, 3=41-50, 4=50+
  final String? occupation; // 职业
  
  // 性格特质（多选）
  final List<String> personalityTraits;
  // 如：内向、外向、敏感、理性、感性、完美主义、随和...
  
  // 优点
  final List<String> strengths;
  // 如：有耐心、善于反思、学习能力强、共情力好...
  
  // 缺点/挑战
  final List<String> challenges;
  // 如：容易焦虑、控制欲强、沟通直接、缺乏耐心...
  
  // 思维方式
  final String? thinkingStyle;
  // 如：乐观型、悲观型、理性分析型、直觉型、完美主义型
  
  // 交流习惯
  final String? communicationStyle;
  // 如：直接型、委婉型、情绪表达型、逻辑分析型
  
  // 生活习惯
  final Map<String, dynamic>? lifestyleHabits;
  // 如：作息（早睡/晚睡）、运动（规律/偶尔/不运动）、饮食...
  
  // 家庭关系
  final Map<String, dynamic>? familyRelationships;
  // 如：亲子关系（紧张/和谐/疏离）、夫妻关系（和睦/紧张/冷战）...
  
  // 人际关系
  final String? socialStyle;
  // 如：社交活跃型、独处型、小圈子型
  
  // 人格底色
  final Map<String, dynamic>? personalityCore;
  // 如：安全感（高/中/低）、信任感、价值感、控制欲...
  
  // 教育理念
  final String? parentingPhilosophy;
  // 如：严厉型、放任型、民主型、学习型
  
  // 孩子信息快照（从对话中提取的关键信息）
  final List<Map<String, dynamic>> childrenInfo;
  // 如：[{name: '大宝', age: 8, trait: '敏感', issue: '作业拖拉'}]
  
  // 历史对话摘要（关键事件记录）
  final List<Map<String, dynamic>> conversationHighlights;
  // 如：[{date: '2026-03-14', topic: '作业拖拉', insight: '孩子可能是畏难情绪'}]
  
  // 元数据
  final DateTime createdAt;
  final DateTime updatedAt;
  final int conversationCount; // 对话次数

  UserProfile({
    required this.userId,
    this.parentRole,
    this.ageRange,
    this.occupation,
    this.personalityTraits = const [],
    this.strengths = const [],
    this.challenges = const [],
    this.thinkingStyle,
    this.communicationStyle,
    this.lifestyleHabits,
    this.familyRelationships,
    this.socialStyle,
    this.personalityCore,
    this.parentingPhilosophy,
    this.childrenInfo = const [],
    this.conversationHighlights = const [],
    required this.createdAt,
    required this.updatedAt,
    this.conversationCount = 0,
  });

  /// 从 JSON 创建
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      parentRole: json['parentRole'] as String?,
      ageRange: json['ageRange'] as int?,
      occupation: json['occupation'] as String?,
      personalityTraits: json['personalityTraits'] != null
          ? List<String>.from(json['personalityTraits'])
          : [],
      strengths: json['strengths'] != null
          ? List<String>.from(json['strengths'])
          : [],
      challenges: json['challenges'] != null
          ? List<String>.from(json['challenges'])
          : [],
      thinkingStyle: json['thinkingStyle'] as String?,
      communicationStyle: json['communicationStyle'] as String?,
      lifestyleHabits: json['lifestyleHabits'] as Map<String, dynamic>?,
      familyRelationships: json['familyRelationships'] as Map<String, dynamic>?,
      socialStyle: json['socialStyle'] as String?,
      personalityCore: json['personalityCore'] as Map<String, dynamic>?,
      parentingPhilosophy: json['parentingPhilosophy'] as String?,
      childrenInfo: json['childrenInfo'] != null
          ? List<Map<String, dynamic>>.from(json['childrenInfo'])
          : [],
      conversationHighlights: json['conversationHighlights'] != null
          ? List<Map<String, dynamic>>.from(json['conversationHighlights'])
          : [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      conversationCount: json['conversationCount'] as int? ?? 0,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'parentRole': parentRole,
      'ageRange': ageRange,
      'occupation': occupation,
      'personalityTraits': personalityTraits,
      'strengths': strengths,
      'challenges': challenges,
      'thinkingStyle': thinkingStyle,
      'communicationStyle': communicationStyle,
      'lifestyleHabits': lifestyleHabits,
      'familyRelationships': familyRelationships,
      'socialStyle': socialStyle,
      'personalityCore': personalityCore,
      'parentingPhilosophy': parentingPhilosophy,
      'childrenInfo': childrenInfo,
      'conversationHighlights': conversationHighlights,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'conversationCount': conversationCount,
    };
  }

  /// 复制并更新
  UserProfile copyWith({
    String? parentRole,
    int? ageRange,
    String? occupation,
    List<String>? personalityTraits,
    List<String>? strengths,
    List<String>? challenges,
    String? thinkingStyle,
    String? communicationStyle,
    Map<String, dynamic>? lifestyleHabits,
    Map<String, dynamic>? familyRelationships,
    String? socialStyle,
    Map<String, dynamic>? personalityCore,
    String? parentingPhilosophy,
    List<Map<String, dynamic>>? childrenInfo,
    List<Map<String, dynamic>>? conversationHighlights,
    int? conversationCount,
  }) {
    return UserProfile(
      userId: userId,
      parentRole: parentRole ?? this.parentRole,
      ageRange: ageRange ?? this.ageRange,
      occupation: occupation ?? this.occupation,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      strengths: strengths ?? this.strengths,
      challenges: challenges ?? this.challenges,
      thinkingStyle: thinkingStyle ?? this.thinkingStyle,
      communicationStyle: communicationStyle ?? this.communicationStyle,
      lifestyleHabits: lifestyleHabits ?? this.lifestyleHabits,
      familyRelationships: familyRelationships ?? this.familyRelationships,
      socialStyle: socialStyle ?? this.socialStyle,
      personalityCore: personalityCore ?? this.personalityCore,
      parentingPhilosophy: parentingPhilosophy ?? this.parentingPhilosophy,
      childrenInfo: childrenInfo ?? this.childrenInfo,
      conversationHighlights: conversationHighlights ?? this.conversationHighlights,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      conversationCount: conversationCount ?? this.conversationCount + 1,
    );
  }

  /// 获取用户画像摘要（用于 AI 调用）
  /// 包含用户主动填写的家庭档案 + AI 从对话中提取的信息
  String getSummary() {
    final buffer = StringBuffer();
    
    if (parentRole != null) {
      buffer.write('角色：$parentRole。');
    }
    
    if (parentingPhilosophy != null) {
      buffer.write('教育理念：$parentingPhilosophy。');
    }

    // 家庭备注/补充说明
    if (familyRelationships != null && familyRelationships!.isNotEmpty) {
      final note = familyRelationships!['note'];
      if (note != null && note.toString().trim().isNotEmpty) {
        buffer.write('家庭情况：$note。');
      }
    }
    
    // 孩子信息（兼容新旧字段名）
    if (childrenInfo.isNotEmpty) {
      final kids = childrenInfo.map((c) {
        final name = c['name'] ?? '孩子';
        final age = c['age'] != null ? '${c['age']}岁' : '';
        final gender = c['gender'] != null ? '${c['gender']}' : '';
        final grade = c['grade'] != null ? '${c['grade']}' : '';
        // 兼容旧字段 trait/issue 和新字段 personality/challenge
        final personality = c['personality'] ?? c['trait'];
        final challenge = c['challenge'] ?? c['issue'];
        final childNote = c['note'];
        
        final parts = <String>[];
        if (age.isNotEmpty) parts.add(age);
        if (gender.isNotEmpty) parts.add(gender);
        if (grade.isNotEmpty) parts.add(grade);
        if (personality != null && personality.toString().trim().isNotEmpty) parts.add('性格$personality');
        if (challenge != null && challenge.toString().trim().isNotEmpty) parts.add('当前困扰：$challenge');
        
        var desc = parts.join('，');
        if (childNote != null && childNote.toString().trim().isNotEmpty) {
          desc += (desc.isNotEmpty ? '；' : '') + childNote;
        }
        
        return '$name${desc.isNotEmpty ? '($desc)' : ''}';
      }).join('；');
      buffer.write('孩子信息：$kids。');
    }
    
    // 家长性格特质（AI从对话提取的）
    if (personalityTraits.isNotEmpty) {
      buffer.write('家长性格特点：${personalityTraits.join('、')}。');
    }
    
    if (strengths.isNotEmpty) {
      buffer.write('家长的优点：${strengths.join('、')}。');
    }
    
    if (challenges.isNotEmpty) {
      buffer.write('家长面临的挑战：${challenges.join('、')}。');
    }
    
    // 最近关注的话题（对话高光）
    if (conversationHighlights.isNotEmpty) {
      final recent = conversationHighlights.take(3).map((h) {
        return '${h['topic']}：${h['insight']}';
      }).join('；');
      buffer.write('最近聊到：$recent。');
    }
    
    return buffer.toString();
  }
}
