import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 应用主题配置
/// 
/// 定义应用的主题样式，包括亮色主题、暗色主题、
/// 颜色方案、文字样式、组件样式等
class AppTheme {
  // 私有构造函数
  AppTheme._();

  // ========== 颜色定义 ==========
  
  /// 主色调
  static const Color primaryColor = Color(0xFF2E7D32); // 深绿色
  static const Color primaryLightColor = Color(0xFF60AD5E);
  static const Color primaryDarkColor = Color(0xFF005005);
  
  /// 次要色调
  static const Color secondaryColor = Color(0xFFFF6F00); // 橙色
  static const Color secondaryLightColor = Color(0xFFFF9F40);
  static const Color secondaryDarkColor = Color(0xFFC43E00);
  
  /// 错误色调
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color errorLightColor = Color(0xFFFF6659);
  static const Color errorDarkColor = Color(0xFF9A0007);
  
  /// 警告色调
  static const Color warningColor = Color(0xFFF57C00);
  static const Color warningLightColor = Color(0xFFFFAD42);
  static const Color warningDarkColor = Color(0xFFBB4D00);
  
  /// 成功色调
  static const Color successColor = Color(0xFF388E3C);
  static const Color successLightColor = Color(0xFF6ABF69);
  static const Color successDarkColor = Color(0xFF00600F);
  
  /// 信息色调
  static const Color infoColor = Color(0xFF1976D2);
  static const Color infoLightColor = Color(0xFF63A4FF);
  static const Color infoDarkColor = Color(0xFF004BA0);
  
  /// 中性色调
  static const Color greyColor = Color(0xFF9E9E9E);
  static const Color greyLightColor = Color(0xFFCFCFCF);
  static const Color greyDarkColor = Color(0xFF707070);
  
  /// 背景色调
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  /// 文字色调
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);
  
  // ========== 亮色主题 ==========
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: primaryLightColor,
        onPrimaryContainer: primaryDarkColor,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        secondaryContainer: secondaryLightColor,
        onSecondaryContainer: secondaryDarkColor,
        error: errorColor,
        onError: Colors.white,
        errorContainer: errorLightColor,
        onErrorContainer: errorDarkColor,
        background: backgroundLight,
        onBackground: textPrimaryLight,
        surface: surfaceLight,
        onSurface: textPrimaryLight,
        surfaceVariant: Color(0xFFF5F5F5),
        onSurfaceVariant: textSecondaryLight,
        outline: greyColor,
        outlineVariant: greyLightColor,
      ),
      
      // AppBar主题
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      // 卡片主题
      cardTheme: CardTheme(
        color: surfaceLight,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
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
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: greyLightColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: greyLightColor),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: TextStyle(color: textSecondaryLight),
        labelStyle: const TextStyle(color: primaryColor),
      ),
      
      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: primaryColor,
        unselectedItemColor: greyColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // 浮动操作按钮主题
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      
      // 分割线主题
      dividerTheme: DividerThemeData(
        color: greyLightColor,
        thickness: 1,
        space: 1,
      ),
      
      // 文字主题
      textTheme: _buildTextTheme(textPrimaryLight, textSecondaryLight),
      
      // 图标主题
      iconTheme: const IconThemeData(
        color: greyDarkColor,
        size: 24,
      ),
      
      // 列表瓦片主题
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 40,
      ),
    );
  }
  
  // ========== 暗色主题 ==========
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryLightColor,
        onPrimary: Colors.black,
        primaryContainer: primaryDarkColor,
        onPrimaryContainer: primaryLightColor,
        secondary: secondaryLightColor,
        onSecondary: Colors.black,
        secondaryContainer: secondaryDarkColor,
        onSecondaryContainer: secondaryLightColor,
        error: errorLightColor,
        onError: Colors.black,
        errorContainer: errorDarkColor,
        onErrorContainer: errorLightColor,
        background: backgroundDark,
        onBackground: textPrimaryDark,
        surface: surfaceDark,
        onSurface: textPrimaryDark,
        surfaceVariant: Color(0xFF2C2C2C),
        onSurfaceVariant: textSecondaryDark,
        outline: greyColor,
        outlineVariant: greyDarkColor,
      ),
      
      // AppBar主题
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: textPrimaryDark,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
      ),
      
      // 卡片主题
      cardTheme: CardTheme(
        color: surfaceDark,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLightColor,
          foregroundColor: Colors.black,
          elevation: 2,
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
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLightColor,
          side: const BorderSide(color: primaryLightColor),
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
          foregroundColor: primaryLightColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: greyDarkColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: greyDarkColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryLightColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorLightColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorLightColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(color: textSecondaryDark),
        labelStyle: const TextStyle(color: primaryLightColor),
      ),
      
      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryLightColor,
        unselectedItemColor: greyColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // 浮动操作按钮主题
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondaryLightColor,
        foregroundColor: Colors.black,
        elevation: 6,
      ),
      
      // 分割线主题
      dividerTheme: const DividerThemeData(
        color: greyDarkColor,
        thickness: 1,
        space: 1,
      ),
      
      // 文字主题
      textTheme: _buildTextTheme(textPrimaryDark, textSecondaryDark),
      
      // 图标主题
      iconTheme: const IconThemeData(
        color: greyLightColor,
        size: 24,
      ),
      
      // 列表瓦片主题
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 40,
      ),
    );
  }
  
  // ========== 文字主题构建 ==========
  
  static TextTheme _buildTextTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      // 显示文字
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.12,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.16,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.22,
      ),
      
      // 标题文字
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.29,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.33,
      ),
      
      // 标题文字
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: primaryColor,
        height: 1.27,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primaryColor,
        height: 1.50,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryColor,
        height: 1.43,
      ),
      
      // 正文文字
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.50,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.33,
      ),
      
      // 标签文字
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryColor,
        height: 1.43,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: primaryColor,
        height: 1.33,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
        height: 1.45,
      ),
    );
  }
  
  // ========== 自定义颜色扩展 ==========
  
  /// 收入颜色
  static const Color incomeColor = successColor;
  static const Color incomeLightColor = successLightColor;
  static const Color incomeDarkColor = successDarkColor;
  
  /// 支出颜色
  static const Color expenseColor = errorColor;
  static const Color expenseLightColor = errorLightColor;
  static const Color expenseDarkColor = errorDarkColor;
  
  /// 转账颜色
  static const Color transferColor = infoColor;
  static const Color transferLightColor = infoLightColor;
  static const Color transferDarkColor = infoDarkColor;
  
  /// 图表颜色组合
  static const List<Color> chartColors = [
    primaryColor,
    secondaryColor,
    successColor,
    warningColor,
    infoColor,
    Color(0xFF9C27B0), // 紫色
    Color(0xFF607D8B), // 蓝灰色
    Color(0xFF795548), // 棕色
    Color(0xFFE91E63), // 粉色
    Color(0xFF00BCD4), // 青色
  ];
  
  // ========== 间距定义 ==========
  
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // ========== 圆角定义 ==========
  
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;
  
  // ========== 阴影定义 ==========
  
  static List<BoxShadow> get shadowLight => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get shadowHeavy => [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}

/// 主题模式枚举
enum ThemeMode {
  light,
  dark,
  system,
}