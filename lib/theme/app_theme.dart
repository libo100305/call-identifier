import 'package:flutter/material.dart';

/// 应用主题配置类
/// 管理应用的颜色、字体、样式等主题相关配置
class AppTheme {
  /// 私有构造函数，防止实例化
  AppTheme._();

  // ==================== 品牌颜色 ====================

  /// 主色调 - 科技蓝
  static const Color primaryColor = Color(0xFF2196F3);

  /// 主色调变体 - 深蓝
  static const Color primaryDark = Color(0xFF1976D2);

  /// 主色调浅色 - 浅蓝
  static const Color primaryLight = Color(0xFFBBDEFB);

  /// 强调色 - 活力橙
  static const Color accentColor = Color(0xFFFF9800);

  /// 成功色 - 绿色
  static const Color successColor = Color(0xFF4CAF50);

  /// 警告色 - 橙色
  static const Color warningColor = Color(0xFFFF9800);

  /// 错误色 - 红色
  static const Color errorColor = Color(0xFFF44336);

  /// 信息色 - 蓝色
  static const Color infoColor = Color(0xFF2196F3);

  // ==================== 中性颜色 ====================

  /// 背景色
  static const Color backgroundColor = Color(0xFFF5F5F5);

  /// 卡片背景色
  static const Color cardColor = Colors.white;

  /// 分割线颜色
  static const Color dividerColor = Color(0xFFE0E0E0);

  /// 文字颜色 - 主要
  static const Color textPrimary = Color(0xFF212121);

  /// 文字颜色 - 次要
  static const Color textSecondary = Color(0xFF757575);

  /// 文字颜色 - 禁用
  static const Color textDisabled = Color(0xFFBDBDBD);

  /// 文字颜色 - 反色（用于深色背景）
  static const Color textOnPrimary = Colors.white;

  // ==================== 来电状态颜色 ====================

  /// 来电识别 - 匹配成功
  static const Color callMatchedColor = Color(0xFF4CAF50);

  /// 来电识别 - 未匹配
  static const Color callUnmatchedColor = Color(0xFFFF9800);

  /// 来电识别 - 未知号码
  static const Color callUnknownColor = Color(0xFF9E9E9E);

  /// 来电识别 - 骚扰电话
  static const Color callSpamColor = Color(0xFFF44336);

  // ==================== 浅色主题 ====================

  /// 获取浅色主题配置
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // 主色调配置
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: textOnPrimary,
        primaryContainer: primaryLight,
        onPrimaryContainer: primaryDark,
        secondary: accentColor,
        onSecondary: textOnPrimary,
        secondaryContainer: Color(0xFFFFE0B2),
        onSecondaryContainer: Color(0xFFE65100),
        surface: cardColor,
        onSurface: textPrimary,
        error: errorColor,
        onError: textOnPrimary,
      ),

      // AppBar 主题
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: textOnPrimary,
        iconTheme: IconThemeData(color: textOnPrimary),
        titleTextStyle: TextStyle(
          color: textOnPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // 卡片主题
      cardTheme: CardTheme(
        elevation: 2,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: primaryColor,
          foregroundColor: textOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: primaryColor, width: 1),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        hintStyle: const TextStyle(color: textDisabled),
        labelStyle: const TextStyle(color: textSecondary),
      ),

      // 浮动操作按钮主题
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: textOnPrimary,
        elevation: 4,
      ),

      // 文本主题
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
      ),

      // 图标主题
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),

      // 分割线主题
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // 开关主题
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryLight;
          }
          return Colors.grey[300];
        }),
      ),

      // 复选框主题
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
      ),

      // 单选按钮主题
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.grey;
        }),
      ),

      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // 导航抽屉主题
      drawerTheme: const DrawerThemeData(
        backgroundColor: cardColor,
      ),

      // 对话框主题
      dialogTheme: DialogTheme(
        backgroundColor: cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: textPrimary,
        ),
      ),

      // 零食条主题
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF323232),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // 进度条主题
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: primaryLight,
      ),

      // 芯片主题
      chipTheme: ChipThemeData(
        backgroundColor: primaryLight,
        deleteIconColor: primaryDark,
        labelStyle: const TextStyle(color: primaryDark),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // ==================== 深色主题 ====================

  /// 获取深色主题配置
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // 主色调配置
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        onPrimary: textOnPrimary,
        primaryContainer: primaryDark,
        onPrimaryContainer: primaryLight,
        secondary: accentColor,
        onSecondary: textOnPrimary,
        secondaryContainer: Color(0xFFE65100),
        onSecondaryContainer: Color(0xFFFFE0B2),
        surface: Color(0xFF1E1E1E),
        onSurface: Colors.white,
        error: errorColor,
        onError: textOnPrimary,
      ),

      // AppBar 主题
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // 卡片主题
      cardTheme: CardTheme(
        elevation: 2,
        color: const Color(0xFF2C2C2C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // 背景色
      scaffoldBackgroundColor: const Color(0xFF121212),

      // 文本主题（深色模式）
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Colors.white70,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      ),
    );
  }

  // ==================== 辅助方法 ====================

  /// 获取状态颜色
  /// 
  /// 参数:
  ///   status: 状态字符串
  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'MATCHED':
        return callMatchedColor;
      case 'UNMATCHED':
        return callUnmatchedColor;
      case 'PENDING':
        return callUnknownColor;
      case 'SPAM':
        return callSpamColor;
      default:
        return callUnknownColor;
    }
  }

  /// 获取状态图标
  static IconData getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'MATCHED':
        return Icons.check_circle_outline;
      case 'UNMATCHED':
        return Icons.help_outline;
      case 'PENDING':
        return Icons.pending;
      case 'SPAM':
        return Icons.warning;
      default:
        return Icons.question_mark;
    }
  }
}
