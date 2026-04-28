import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_profile_service.dart';
import '../models/user_profile_model.dart';

/// 家庭档案页面 - 编辑孩子信息和家庭情况
/// 这些信息会传递给AI，让它能更好地了解用户
class FamilyProfileScreen extends ConsumerStatefulWidget {
  const FamilyProfileScreen({super.key});

  @override
  ConsumerState<FamilyProfileScreen> createState() => _FamilyProfileScreenState();
}

class _FamilyProfileScreenState extends ConsumerState<FamilyProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = true;

  // ===== 家长信息编辑控制器 =====
  final _parentRoleController = TextEditingController();
  final _parentingStyleController = TextEditingController();
  final _familyNoteController = TextEditingController();

  // ===== 孩子列表 =====
  final List<_ChildForm> _childrenForms = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _parentRoleController.dispose();
    _parentingStyleController.dispose();
    _familyNoteController.dispose();
    for (final form in _childrenForms) {
      form.nameController.dispose();
      form.ageController.dispose();
      form.gradeController.dispose();
      form.personalityController.dispose();
      form.challengeController.dispose();
      form.noteController.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final profile = await UserProfileService().getCurrentUserProfile();

    if (mounted) {
      setState(() {
        _profile = profile;

        // 初始化家长信息
        _parentRoleController.text = profile.parentRole ?? '';
        _parentingStyleController.text = profile.parentingPhilosophy ?? '';

        // 从 childrenInfo 初始化孩子表单
        _childrenForms.clear();
        for (final child in profile.childrenInfo) {
          _childrenForms.add(_ChildForm(
            nameController: TextEditingController(text: child['name'] ?? ''),
            ageController: TextEditingController(text: _formatAge(child['age'])),
            gender: child['gender'] ?? '',
            gradeController: TextEditingController(text: child['grade'] ?? ''),
            personalityController: TextEditingController(text: child['personality'] ?? child['trait'] ?? ''),
            challengeController: TextEditingController(text: child['challenge'] ?? child['issue'] ?? ''),
            noteController: TextEditingController(text: child['note'] ?? ''),
          ));
        }

        // 如果没有孩子，默认添加一个空表单
        if (_childrenForms.isEmpty) {
          _childrenForms.add(_ChildForm());
        }

        // 家庭备注
        final family = profile.familyRelationships;
        _familyNoteController.text = family?['note'] ?? '';

        _isLoading = false;
      });
    }
  }

  String _formatAge(dynamic age) {
    if (age == null) return '';
    if (age is int) return '$age';
    return age.toString();
  }

  Future<void> _saveProfile() async {
    if (_profile == null) return;

    // 构建孩子信息列表
    final childrenInfo = _childrenForms
        .where((f) => f.nameController.text.trim().isNotEmpty)
        .map((f) => <String, dynamic>{
              'name': f.nameController.text.trim(),
              'age': int.tryParse(f.ageController.text.trim()),
              'gender': f.gender,
              'grade': f.gradeController.text.trim(),
              'personality': f.personalityController.text.trim(),
              'challenge': f.challengeController.text.trim(),
              'note': f.noteController.text.trim(),
            })
        .toList();

    final updatedProfile = _profile!.copyWith(
      parentRole: _parentRoleController.text.trim().isEmpty ? null : _parentRoleController.text.trim(),
      parentingPhilosophy: _parentingStyleController.text.trim().isEmpty ? null : _parentingStyleController.text.trim(),
      childrenInfo: childrenInfo,
      familyRelationships: _familyNoteController.text.trim().isEmpty
          ? null
          : {'note': _familyNoteController.text.trim()},
    );

    await UserProfileService().updateProfile(updatedProfile);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('档案保存成功'),
            ],
          ),
          backgroundColor: const Color(0xFF6B9E78),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _addChild() {
    setState(() {
      _childrenForms.add(_ChildForm());
    });
  }

  void _removeChild(int index) {
    setState(() {
      _childrenForms[index].dispose();
      _childrenForms.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部栏
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                    color: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '家庭档案',
                      style: theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('保存'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6B9E78),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // 内容
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 提示文字
                          _buildHintBanner(theme, isDark),
                          const SizedBox(height: 24),

                          // ===== 家长信息 =====
                          _buildSectionTitle('家长信息', theme),
                          const SizedBox(height: 12),
                          _buildInputCard(
                            theme: theme,
                            child: Column(
                              children: [
                                _buildSelectField(
                                  theme: theme,
                                  label: '你的角色',
                                  controller: _parentRoleController,
                                  hint: '选择你的身份',
                                  options: ['妈妈', '爸爸', '爷爷', '奶奶', '外公', '外婆', '其他'],
                                ),
                                const SizedBox(height: 12),
                                _buildSelectField(
                                  theme: theme,
                                  label: '教育方式',
                                  controller: _parentingStyleController,
                                  hint: '选择最接近的',
                                  options: ['民主型', '温和坚定型', '严格型', '放任型', '学习型', '不确定'],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ===== 孩子信息 =====
                          _buildSectionTitle('孩子信息', theme),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              '这些信息帮助AI给出更贴合你孩子的建议',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.4),
                              ),
                            ),
                          ),

                          ...List.generate(_childrenForms.length, (index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index < _childrenForms.length - 1 ? 16 : 0,
                              ),
                              child: _buildChildCard(theme, isDark, index),
                            );
                          }),

                          // 添加孩子按钮
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: OutlinedButton.icon(
                              onPressed: _addChild,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('添加孩子'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF6B9E78),
                                side: BorderSide(color: const Color(0xFF6B9E78).withOpacity(0.4)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ===== 家庭备注 =====
                          _buildSectionTitle('补充说明', theme),
                          const SizedBox(height: 12),
                          _buildInputCard(
                            theme: theme,
                            child: TextField(
                              controller: _familyNoteController,
                              maxLines: 4,
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface,
                                height: 1.5,
                              ),
                              decoration: InputDecoration(
                                hintText: '如：单亲家庭、双职工、老人帮忙带孩子、最近搬家转学等...',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHintBanner(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF6B9E78).withOpacity(0.1)
            : const Color(0xFF6B9E78).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6B9E78).withOpacity(0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💡', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '填写家庭档案后，AI 能更快地了解你的情况，给出更有针对性的建议。你可以随时修改。',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.65),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildInputCard({required ThemeData theme, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E2DA)),
      ),
      child: child,
    );
  }

  Widget _buildSelectField({
    required ThemeData theme,
    required String label,
    required TextEditingController controller,
    required String hint,
    required List<String> options,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = controller.text == option;
            return Material(
              color: isSelected
                  ? const Color(0xFF6B9E78)
                  : theme.colorScheme.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => setState(() => controller.text = option),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChildCard(ThemeData theme, bool isDark, int index) {
    final form = _childrenForms[index];
    final canRemove = _childrenForms.length > 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E2DA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Text(
                '👶 孩子 ${index + 1}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (canRemove)
                InkWell(
                  onTap: () => _removeChild(index),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // 姓名和年龄
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  theme: theme,
                  label: '昵称',
                  controller: form.nameController,
                  hint: '孩子的称呼',
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 80,
                child: _buildTextField(
                  theme: theme,
                  label: '年龄',
                  controller: form.ageController,
                  hint: '几岁',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 80,
                child: _buildGenderSelect(theme, form),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 年级
          _buildTextField(
            theme: theme,
            label: '年级',
            controller: form.gradeController,
            hint: '如：小学二年级、初一等',
          ),
          const SizedBox(height: 12),

          // 性格特点
          _buildTextField(
            theme: theme,
            label: '性格特点',
            controller: form.personalityController,
            hint: '如：活泼好动、安静内向、敏感细腻...',
          ),
          const SizedBox(height: 12),

          // 面临挑战
          _buildTextField(
            theme: theme,
            label: '当前困扰',
            controller: form.challengeController,
            hint: '如：作业拖拉、不愿沟通、叛逆...',
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required ThemeData theme,
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.25),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: theme.colorScheme.onSurface.withOpacity(0.08),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: theme.colorScheme.onSurface.withOpacity(0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF6B9E78),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelect(ThemeData theme, _ChildForm form) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '性别',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildGenderChip(theme, '男', '👦', form),
            const SizedBox(width: 8),
            _buildGenderChip(theme, '女', '👧', form),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderChip(ThemeData theme, String gender, String emoji, _ChildForm form) {
    final isSelected = form.gender == gender;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => form.gender = gender),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6B9E78).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF6B9E78)
                  : theme.colorScheme.onSurface.withOpacity(0.08),
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}

/// 孩子表单数据
class _ChildForm {
  final TextEditingController nameController;
  final TextEditingController ageController;
  String gender;
  final TextEditingController gradeController;
  final TextEditingController personalityController;
  final TextEditingController challengeController;
  final TextEditingController noteController;

  _ChildForm({
    TextEditingController? nameController,
    TextEditingController? ageController,
    this.gender = '',
    TextEditingController? gradeController,
    TextEditingController? personalityController,
    TextEditingController? challengeController,
    TextEditingController? noteController,
  })  : nameController = nameController ?? TextEditingController(),
        ageController = ageController ?? TextEditingController(),
        gradeController = gradeController ?? TextEditingController(),
        personalityController = personalityController ?? TextEditingController(),
        challengeController = challengeController ?? TextEditingController(),
        noteController = noteController ?? TextEditingController();

  void dispose() {
    nameController.dispose();
    ageController.dispose();
    gradeController.dispose();
    personalityController.dispose();
    challengeController.dispose();
    noteController.dispose();
  }
}
