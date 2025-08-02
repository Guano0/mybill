import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

/// 安全存储服务
/// 
/// 提供安全的本地数据存储功能，包括token管理、用户信息存储、
/// 敏感数据加密存储等功能
class SecureStorage {
  SharedPreferences? _prefs;
  static const String _encryptionKey = 'MyBill_Encryption_Key_2024';

  /// 初始化存储服务
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      throw CacheException(
        message: '初始化本地存储失败: $e',
        code: 'STORAGE_INIT_ERROR',
      );
    }
  }

  /// 确保存储服务已初始化
  void _ensureInitialized() {
    if (_prefs == null) {
      throw const CacheException(
        message: '存储服务未初始化',
        code: 'STORAGE_NOT_INITIALIZED',
      );
    }
  }

  /// 简单加密方法（用于演示，生产环境建议使用更强的加密）
  String _encrypt(String data) {
    final bytes = utf8.encode(data + _encryptionKey);
    final digest = sha256.convert(bytes);
    final encrypted = base64.encode(utf8.encode(data));
    return '$encrypted.${digest.toString().substring(0, 16)}';
  }

  /// 简单解密方法
  String? _decrypt(String encryptedData) {
    try {
      final parts = encryptedData.split('.');
      if (parts.length != 2) return null;
      
      final data = utf8.decode(base64.decode(parts[0]));
      final expectedHash = sha256.convert(utf8.encode(data + _encryptionKey))
          .toString().substring(0, 16);
      
      if (parts[1] == expectedHash) {
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 保存字符串数据
  Future<bool> setString(String key, String value) async {
    try {
      _ensureInitialized();
      return await _prefs!.setString(key, value);
    } catch (e) {
      throw CacheException(
        message: '保存字符串数据失败: $e',
        code: 'SAVE_STRING_ERROR',
      );
    }
  }

  /// 获取字符串数据
  String? getString(String key) {
    try {
      _ensureInitialized();
      return _prefs!.getString(key);
    } catch (e) {
      throw CacheException(
        message: '获取字符串数据失败: $e',
        code: 'GET_STRING_ERROR',
      );
    }
  }

  /// 保存加密字符串数据
  Future<bool> setSecureString(String key, String value) async {
    try {
      _ensureInitialized();
      final encrypted = _encrypt(value);
      return await _prefs!.setString(key, encrypted);
    } catch (e) {
      throw CacheException(
        message: '保存加密数据失败: $e',
        code: 'SAVE_SECURE_STRING_ERROR',
      );
    }
  }

  /// 获取加密字符串数据
  String? getSecureString(String key) {
    try {
      _ensureInitialized();
      final encrypted = _prefs!.getString(key);
      if (encrypted == null) return null;
      return _decrypt(encrypted);
    } catch (e) {
      throw CacheException(
        message: '获取加密数据失败: $e',
        code: 'GET_SECURE_STRING_ERROR',
      );
    }
  }

  /// 保存布尔值
  Future<bool> setBool(String key, bool value) async {
    try {
      _ensureInitialized();
      return await _prefs!.setBool(key, value);
    } catch (e) {
      throw CacheException(
        message: '保存布尔值失败: $e',
        code: 'SAVE_BOOL_ERROR',
      );
    }
  }

  /// 获取布尔值
  bool? getBool(String key) {
    try {
      _ensureInitialized();
      return _prefs!.getBool(key);
    } catch (e) {
      throw CacheException(
        message: '获取布尔值失败: $e',
        code: 'GET_BOOL_ERROR',
      );
    }
  }

  /// 保存整数
  Future<bool> setInt(String key, int value) async {
    try {
      _ensureInitialized();
      return await _prefs!.setInt(key, value);
    } catch (e) {
      throw CacheException(
        message: '保存整数失败: $e',
        code: 'SAVE_INT_ERROR',
      );
    }
  }

  /// 获取整数
  int? getInt(String key) {
    try {
      _ensureInitialized();
      return _prefs!.getInt(key);
    } catch (e) {
      throw CacheException(
        message: '获取整数失败: $e',
        code: 'GET_INT_ERROR',
      );
    }
  }

  /// 保存双精度浮点数
  Future<bool> setDouble(String key, double value) async {
    try {
      _ensureInitialized();
      return await _prefs!.setDouble(key, value);
    } catch (e) {
      throw CacheException(
        message: '保存浮点数失败: $e',
        code: 'SAVE_DOUBLE_ERROR',
      );
    }
  }

  /// 获取双精度浮点数
  double? getDouble(String key) {
    try {
      _ensureInitialized();
      return _prefs!.getDouble(key);
    } catch (e) {
      throw CacheException(
        message: '获取浮点数失败: $e',
        code: 'GET_DOUBLE_ERROR',
      );
    }
  }

  /// 保存字符串列表
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      _ensureInitialized();
      return await _prefs!.setStringList(key, value);
    } catch (e) {
      throw CacheException(
        message: '保存字符串列表失败: $e',
        code: 'SAVE_STRING_LIST_ERROR',
      );
    }
  }

  /// 获取字符串列表
  List<String>? getStringList(String key) {
    try {
      _ensureInitialized();
      return _prefs!.getStringList(key);
    } catch (e) {
      throw CacheException(
        message: '获取字符串列表失败: $e',
        code: 'GET_STRING_LIST_ERROR',
      );
    }
  }

  /// 保存JSON对象
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      throw CacheException(
        message: '保存JSON对象失败: $e',
        code: 'SAVE_JSON_ERROR',
      );
    }
  }

  /// 获取JSON对象
  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw CacheException(
        message: '获取JSON对象失败: $e',
        code: 'GET_JSON_ERROR',
      );
    }
  }

  /// 保存加密JSON对象
  Future<bool> setSecureJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setSecureString(key, jsonString);
    } catch (e) {
      throw CacheException(
        message: '保存加密JSON对象失败: $e',
        code: 'SAVE_SECURE_JSON_ERROR',
      );
    }
  }

  /// 获取加密JSON对象
  Map<String, dynamic>? getSecureJson(String key) {
    try {
      final jsonString = getSecureString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw CacheException(
        message: '获取加密JSON对象失败: $e',
        code: 'GET_SECURE_JSON_ERROR',
      );
    }
  }

  /// 删除指定键的数据
  Future<bool> remove(String key) async {
    try {
      _ensureInitialized();
      return await _prefs!.remove(key);
    } catch (e) {
      throw CacheException(
        message: '删除数据失败: $e',
        code: 'REMOVE_ERROR',
      );
    }
  }

  /// 检查键是否存在
  bool containsKey(String key) {
    try {
      _ensureInitialized();
      return _prefs!.containsKey(key);
    } catch (e) {
      throw CacheException(
        message: '检查键存在性失败: $e',
        code: 'CONTAINS_KEY_ERROR',
      );
    }
  }

  /// 获取所有键
  Set<String> getKeys() {
    try {
      _ensureInitialized();
      return _prefs!.getKeys();
    } catch (e) {
      throw CacheException(
        message: '获取所有键失败: $e',
        code: 'GET_KEYS_ERROR',
      );
    }
  }

  /// 清除所有数据
  Future<bool> clear() async {
    try {
      _ensureInitialized();
      return await _prefs!.clear();
    } catch (e) {
      throw CacheException(
        message: '清除所有数据失败: $e',
        code: 'CLEAR_ERROR',
      );
    }
  }

  // ========== 认证相关方法 ==========

  /// 保存访问token
  Future<bool> saveToken(String token) async {
    return await setSecureString(AppConstants.tokenKey, token);
  }

  /// 获取访问token
  String? getToken() {
    return getSecureString(AppConstants.tokenKey);
  }

  /// 保存刷新token
  Future<bool> saveRefreshToken(String refreshToken) async {
    return await setSecureString(AppConstants.refreshTokenKey, refreshToken);
  }

  /// 获取刷新token
  String? getRefreshToken() {
    return getSecureString(AppConstants.refreshTokenKey);
  }

  /// 保存用户信息
  Future<bool> saveUserInfo(Map<String, dynamic> userInfo) async {
    return await setSecureJson(AppConstants.userInfoKey, userInfo);
  }

  /// 获取用户信息
  Map<String, dynamic>? getUserInfo() {
    return getSecureJson(AppConstants.userInfoKey);
  }

  /// 清除认证信息
  Future<void> clearTokens() async {
    await remove(AppConstants.tokenKey);
    await remove(AppConstants.refreshTokenKey);
    await remove(AppConstants.userInfoKey);
  }

  /// 检查是否已登录
  bool isLoggedIn() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  // ========== 应用设置相关方法 ==========

  /// 保存主题模式
  Future<bool> saveThemeMode(String themeMode) async {
    return await setString(AppConstants.themeKey, themeMode);
  }

  /// 获取主题模式
  String? getThemeMode() {
    return getString(AppConstants.themeKey);
  }

  /// 保存语言代码
  Future<bool> saveLanguageCode(String languageCode) async {
    return await setString(AppConstants.languageKey, languageCode);
  }

  /// 获取语言代码
  String? getLanguageCode() {
    return getString(AppConstants.languageKey);
  }

  /// 保存货币代码
  Future<bool> saveCurrencyCode(String currencyCode) async {
    return await setString(AppConstants.currencyKey, currencyCode);
  }

  /// 获取货币代码
  String? getCurrencyCode() {
    return getString(AppConstants.currencyKey);
  }

  /// 保存是否首次启动
  Future<bool> saveFirstLaunch(bool isFirstLaunch) async {
    return await setBool(AppConstants.firstLaunchKey, isFirstLaunch);
  }

  /// 获取是否首次启动
  bool isFirstLaunch() {
    return getBool(AppConstants.firstLaunchKey) ?? true;
  }

  /// 保存生物识别启用状态
  Future<bool> saveBiometricEnabled(bool enabled) async {
    return await setBool(AppConstants.biometricEnabledKey, enabled);
  }

  /// 获取生物识别启用状态
  bool isBiometricEnabled() {
    return getBool(AppConstants.biometricEnabledKey) ?? false;
  }

  /// 保存自动同步设置
  Future<bool> saveAutoSync(bool enabled) async {
    return await setBool(AppConstants.autoSyncKey, enabled);
  }

  /// 获取自动同步设置
  bool isAutoSyncEnabled() {
    return getBool(AppConstants.autoSyncKey) ?? true;
  }
}