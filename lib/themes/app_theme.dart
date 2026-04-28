import 'package:flutter/material.dart';

/// 陪伴小树苗 - 粗描简笔画风格配色方案
/// 米白底色 + 柔和绿主色 + 温暖橙点缀 + 手绘边框
class AppTheme {
  // ===== 核心色板 =====
  // 主色：柔和绿
  static const Color primary = Color(0xFF6B9E78);
  static const Color primaryLight = Color(0xFFA8CDB3);
  static const Color primaryDark = Color(0xFF4A7A55);

  // 点缀色：温暖橙
  static const Color accent = Color(0xFFF0A868);
  static const Color accentLight = Color(0xFFF5C8A0);

  // 背景色 - 更暖的米白（简笔画纸张感）
  static const Color bgLight = Color(0xFFFDFBF7);     // 暖米白
  static const Color bgDark = Color(0xFF1A1F2E);      // 深蓝灰

  // 表面色
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF232A3A);

  // 文字色
  static const Color textPrimaryLight = Color(0xFF2D3A2E);
  static const Color textSecondaryLight = Color(0xFF8B9A8E);
  static const Color textPrimaryDark = Color(0xFFF0EDE8);
  static const Color textSecondaryDark = Color(0xFF8898A0);

  // 简笔画描边色
  static const Color sketchLine = Color(0xFF2D2D2D);      // 深灰描边
  static const Color sketchLineLight = Color(0x266B9E78);  // 绿色淡描边

  // 用户消息气泡
  static const Color userBubbleLight = Color(0xFF6B9E78);
  static const Color userBubbleDark = Color(0xFF4A7A55);

  // AI消息气泡
  static const Color botBubbleLight = Color(0xFFFFFFFF);
  static const Color botBubbleDark = Color(0xFF2A3344);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: accent,
        tertiary: primaryLight,
        surface: surfaceLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryLight,
        error: const Color(0xFFE57373),
      ),
      scaffoldBackgroundColor: bgLight,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        foregroundColor: textPrimaryLight,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimaryLight,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: Color(0xFFE8E2DA).withOpacity(0.5), width: 1.3),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: Color(0xFFE8E2DA).withOpacity(0.6), width: 1.3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: primary, width: 1.8),
        ),
        hintStyle: TextStyle(color: textSecondaryLight, fontSize: 15),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: primaryDark.withOpacity(0.25), width: 1.3),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      dividerColor: Color(0xFFE8E2DA),
      textTheme: TextTheme(
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimaryLight, height: 1.3),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimaryLight, height: 1.4),
        bodyLarge: TextStyle(fontSize: 15, color: textPrimaryLight, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondaryLight, height: 1.5),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimaryLight),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryLight,
        secondary: accent,
        tertiary: primary,
        surface: surfaceDark,
        onPrimary: const Color(0xFF1A2E20),
        onSecondary: Colors.white,
        onSurface: textPrimaryDark,
        error: const Color(0xFFE57373),
      ),
      scaffoldBackgroundColor: bgDark,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        foregroundColor: textPrimaryDark,
        centerTitle: false,
        titleTextStyle: TextStyle(color: textPrimaryDark, fontSize: 18, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: Color(0xFF2E3848), width: 1.3),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide(color: Color(0xFF2E3848).withOpacity(0.6), width: 1.3)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide(color: primaryLight, width: 1.8)),
        hintStyle: TextStyle(color: textSecondaryDark, fontSize: 15),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: const Color(0xFF1A2E20),
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: primary.withOpacity(0.18), width: 1.3),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: primaryLight)),
      dividerColor: Color(0xFF2E3848),
      textTheme: TextTheme(
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimaryDark, height: 1.3),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimaryDark, height: 1.4),
        bodyLarge: TextStyle(fontSize: 15, color: textPrimaryDark, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondaryDark, height: 1.5),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimaryDark),
      ),
    );
  }
}
