import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 字符串扩展
extension StringExtensions on String {
  /// 检查字符串是否为空或null
  bool get isNullOrEmpty => isEmpty;
  
  /// 检查字符串是否不为空且不为null
  bool get isNotNullOrEmpty => isNotEmpty;
  
  /// 首字母大写
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
  
  /// 每个单词首字母大写
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }
  
  /// 移除所有空格
  String get removeSpaces => replaceAll(' ', '');
  
  /// 检查是否为有效邮箱
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
  
  /// 检查是否为有效手机号（中国）
  bool get isValidPhoneNumber {
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(this);
  }
  
  /// 检查是否为数字
  bool get isNumeric {
    return double.tryParse(this) != null;
  }
  
  /// 转换为双精度浮点数
  double? get toDouble {
    return double.tryParse(this);
  }
  
  /// 转换为整数
  int? get toInt {
    return int.tryParse(this);
  }
  
  /// 格式化金额显示（添加千分位分隔符）
  String get formatCurrency {
    final number = double.tryParse(this);
    if (number == null) return this;
    return NumberFormat('#,##0.00').format(number);
  }
  
  /// 隐藏手机号中间四位
  String get maskPhoneNumber {
    if (length != 11) return this;
    return '${substring(0, 3)}****${substring(7)}';
  }
  
  /// 隐藏邮箱用户名部分
  String get maskEmail {
    if (!isValidEmail) return this;
    final parts = split('@');
    final username = parts[0];
    final domain = parts[1];
    if (username.length <= 2) return this;
    return '${username.substring(0, 2)}***@$domain';
  }
  
  /// 截断字符串并添加省略号
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }
}

/// 数字扩展
extension NumExtensions on num {
  /// 格式化为货币字符串
  String toCurrency({String symbol = '¥', int decimalDigits = 2}) {
    return '$symbol${NumberFormat('#,##0.${'0' * decimalDigits}').format(this)}';
  }
  
  /// 格式化为百分比
  String toPercentage({int decimalDigits = 1}) {
    return '${(this * 100).toStringAsFixed(decimalDigits)}%';
  }
  
  /// 格式化为紧凑数字（如1.2K, 3.4M）
  String toCompactNumber() {
    return NumberFormat.compact().format(this);
  }
  
  /// 检查是否为正数
  bool get isPositive => this > 0;
  
  /// 检查是否为负数
  bool get isNegative => this < 0;
  
  /// 检查是否为零
  bool get isZero => this == 0;
  
  /// 安全除法（避免除零错误）
  double safeDivide(num divisor) {
    if (divisor == 0) return 0;
    return this / divisor;
  }
}

/// 双精度浮点数扩展
extension DoubleExtensions on double {
  /// 保留指定小数位数
  double toFixed(int decimalPlaces) {
    return double.parse(toStringAsFixed(decimalPlaces));
  }
  
  /// 四舍五入到指定小数位
  double roundToDecimal(int decimalPlaces) {
    final factor = pow(10, decimalPlaces) as int;
    return (this * factor).round() / factor;
  }
}

/// 日期时间扩展
extension DateTimeExtensions on DateTime {
  /// 格式化为常用日期格式
  String get formatDate => DateFormat('yyyy-MM-dd').format(this);
  
  /// 格式化为常用时间格式
  String get formatTime => DateFormat('HH:mm:ss').format(this);
  
  /// 格式化为日期时间格式
  String get formatDateTime => DateFormat('yyyy-MM-dd HH:mm:ss').format(this);
  
  /// 格式化为中文日期格式
  String get formatChineseDate => DateFormat('yyyy年MM月dd日').format(this);
  
  /// 格式化为中文日期时间格式
  String get formatChineseDateTime => DateFormat('yyyy年MM月dd日 HH:mm').format(this);
  
  /// 格式化为相对时间（如：刚刚、5分钟前、昨天等）
  String get formatRelative {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}周前';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}个月前';
    } else {
      return '${(difference.inDays / 365).floor()}年前';
    }
  }
  
  /// 检查是否为今天
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  /// 检查是否为昨天
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
  
  /// 检查是否为本周
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
           isBefore(endOfWeek.add(const Duration(days: 1)));
  }
  
  /// 检查是否为本月
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }
  
  /// 检查是否为本年
  bool get isThisYear {
    final now = DateTime.now();
    return year == now.year;
  }
  
  /// 获取月初日期
  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }
  
  /// 获取月末日期
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0, 23, 59, 59, 999);
  }
  
  /// 获取周初日期（周一）
  DateTime get startOfWeek {
    return subtract(Duration(days: weekday - 1));
  }
  
  /// 获取周末日期（周日）
  DateTime get endOfWeek {
    return add(Duration(days: 7 - weekday, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
  }
  
  /// 获取年初日期
  DateTime get startOfYear {
    return DateTime(year, 1, 1);
  }
  
  /// 获取年末日期
  DateTime get endOfYear {
    return DateTime(year, 12, 31, 23, 59, 59, 999);
  }
}

/// 颜色扩展
extension ColorExtensions on Color {
  /// 转换为十六进制字符串
  String get toHex {
    return '#${value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
  
  /// 获取对比色（黑色或白色）
  Color get contrastColor {
    // 计算亮度
    final luminance = (0.299 * red + 0.587 * green + 0.114 * blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
  
  /// 调整透明度
  Color withAlpha(int alpha) {
    return Color.fromARGB(alpha, red, green, blue);
  }
  
  /// 调整亮度
  Color adjustBrightness(double factor) {
    assert(factor >= 0 && factor <= 2, 'Factor must be between 0 and 2');
    
    if (factor == 1) return this;
    
    int adjustColor(int component) {
      if (factor < 1) {
        // 变暗
        return (component * factor).round().clamp(0, 255);
      } else {
        // 变亮
        return (component + (255 - component) * (factor - 1)).round().clamp(0, 255);
      }
    }
    
    return Color.fromARGB(
      alpha,
      adjustColor(red),
      adjustColor(green),
      adjustColor(blue),
    );
  }
}

/// 列表扩展
extension ListExtensions<T> on List<T> {
  /// 安全获取元素（避免越界）
  T? safeGet(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
  
  /// 安全设置元素
  void safeSet(int index, T value) {
    if (index >= 0 && index < length) {
      this[index] = value;
    }
  }
  
  /// 添加元素（如果不存在）
  void addIfNotExists(T item) {
    if (!contains(item)) {
      add(item);
    }
  }
  
  /// 移除所有匹配的元素
  void removeWhere(bool Function(T) test) {
    removeWhere(test);
  }
  
  /// 分组
  Map<K, List<T>> groupBy<K>(K Function(T) keySelector) {
    final map = <K, List<T>>{};
    for (final item in this) {
      final key = keySelector(item);
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }
  
  /// 去重
  List<T> get distinct {
    return toSet().toList();
  }
  
  /// 分页
  List<T> page(int pageNumber, int pageSize) {
    final startIndex = (pageNumber - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, length);
    
    if (startIndex >= length) return [];
    return sublist(startIndex, endIndex);
  }
}

/// Map扩展
extension MapExtensions<K, V> on Map<K, V> {
  /// 安全获取值
  V? safeGet(K key) {
    return containsKey(key) ? this[key] : null;
  }
  
  /// 获取值或默认值
  V getOrDefault(K key, V defaultValue) {
    return containsKey(key) ? this[key]! : defaultValue;
  }
  
  /// 过滤
  Map<K, V> whereKey(bool Function(K) test) {
    return Map.fromEntries(entries.where((entry) => test(entry.key)));
  }
  
  Map<K, V> whereValue(bool Function(V) test) {
    return Map.fromEntries(entries.where((entry) => test(entry.value)));
  }
}

/// BuildContext扩展
extension BuildContextExtensions on BuildContext {
  /// 获取主题
  ThemeData get theme => Theme.of(this);
  
  /// 获取颜色方案
  ColorScheme get colorScheme => theme.colorScheme;
  
  /// 获取文字主题
  TextTheme get textTheme => theme.textTheme;
  
  /// 获取媒体查询
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  
  /// 获取屏幕尺寸
  Size get screenSize => mediaQuery.size;
  
  /// 获取屏幕宽度
  double get screenWidth => screenSize.width;
  
  /// 获取屏幕高度
  double get screenHeight => screenSize.height;
  
  /// 获取状态栏高度
  double get statusBarHeight => mediaQuery.padding.top;
  
  /// 获取底部安全区域高度
  double get bottomPadding => mediaQuery.padding.bottom;
  
  /// 检查是否为横屏
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;
  
  /// 检查是否为竖屏
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;
  
  /// 检查是否为平板
  bool get isTablet => screenWidth >= 768;
  
  /// 检查是否为手机
  bool get isMobile => screenWidth < 768;
  
  /// 显示SnackBar
  void showSnackBar(String message, {Color? backgroundColor, Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
  
  /// 显示错误SnackBar
  void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: colorScheme.error);
  }
  
  /// 显示成功SnackBar
  void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.green);
  }
  
  /// 隐藏键盘
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
  
  /// 导航到新页面
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }
  
  /// 替换当前页面
  Future<T?> pushReplacementNamed<T, TO>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushReplacementNamed<T, TO>(routeName, arguments: arguments);
  }
  
  /// 返回上一页
  void pop<T>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }
  
  /// 返回到指定页面
  void popUntil(String routeName) {
    Navigator.of(this).popUntil(ModalRoute.withName(routeName));
  }
}

/// 导入数学库
import 'dart:math' as math;

/// 数学扩展
int pow(int base, int exponent) {
  return math.pow(base, exponent).toInt();
}