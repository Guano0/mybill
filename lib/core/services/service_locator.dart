import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../network/api_client.dart';
import '../storage/secure_storage.dart';
import '../utils/logger.dart';
import 'navigation_service.dart';
import 'permission_service.dart';
import 'biometric_service.dart';
import 'notification_service.dart';
import 'sync_service.dart';
import 'voice_service.dart';
import 'ocr_service.dart';
import 'analytics_service.dart';

/// 服务定位器 - 依赖注入容器
/// 使用GetIt实现依赖注入，管理应用中的所有服务实例
class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;
  
  /// 获取服务实例
  static T get<T extends Object>() => _getIt.get<T>();
  
  /// 检查服务是否已注册
  static bool isRegistered<T extends Object>() => _getIt.isRegistered<T>();
  
  /// 初始化所有服务
  static Future<void> init() async {
    await _registerExternalDependencies();
    await _registerCoreServices();
    await _registerBusinessServices();
    await _registerExtensionServices();
  }
  
  /// 注册外部依赖
  static Future<void> _registerExternalDependencies() async {
    // SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    _getIt.registerSingleton<SharedPreferences>(sharedPreferences);
    
    // Dio
    final dio = Dio();
    _getIt.registerSingleton<Dio>(dio);
    
    // Connectivity
    _getIt.registerSingleton<Connectivity>(Connectivity());
    
    // DeviceInfo
    _getIt.registerSingleton<DeviceInfoPlugin>(DeviceInfoPlugin());
  }
  
  /// 注册核心服务
  static Future<void> _registerCoreServices() async {
    // Logger
    _getIt.registerSingleton<Logger>(Logger());
    
    // SecureStorage
    _getIt.registerSingleton<SecureStorage>(
      SecureStorage(_getIt<SharedPreferences>()),
    );
    
    // ApiClient
    _getIt.registerSingleton<ApiClient>(
      ApiClient(
        dio: _getIt<Dio>(),
        secureStorage: _getIt<SecureStorage>(),
        connectivity: _getIt<Connectivity>(),
        logger: _getIt<Logger>(),
      ),
    );
    
    // NavigationService
    _getIt.registerSingleton<NavigationService>(NavigationService());
    
    // PermissionService
    _getIt.registerSingleton<PermissionService>(PermissionService());
  }
  
  /// 注册业务服务
  static Future<void> _registerBusinessServices() async {
    // BiometricService
    _getIt.registerSingleton<BiometricService>(BiometricService());
    
    // NotificationService
    _getIt.registerSingleton<NotificationService>(NotificationService());
    
    // SyncService
    _getIt.registerSingleton<SyncService>(
      SyncService(
        apiClient: _getIt<ApiClient>(),
        secureStorage: _getIt<SecureStorage>(),
        logger: _getIt<Logger>(),
      ),
    );
    
    // AnalyticsService
    _getIt.registerSingleton<AnalyticsService>(AnalyticsService());
  }
  
  /// 注册扩展服务（为未来功能预留）
  static Future<void> _registerExtensionServices() async {
    // VoiceService - 语音识别服务
    _getIt.registerSingleton<VoiceService>(VoiceService());
    
    // OcrService - OCR识别服务
    _getIt.registerSingleton<OcrService>(OcrService());
  }
  
  /// 重置所有服务（主要用于测试）
  static Future<void> reset() async {
    await _getIt.reset();
  }
  
  /// 注册测试依赖（用于单元测试）
  static void registerTestDependencies() {
    // 在测试环境中注册模拟服务
  }
}

/// 服务初始化异常
class ServiceInitializationException implements Exception {
  final String message;
  final dynamic originalError;
  
  const ServiceInitializationException(this.message, [this.originalError]);
  
  @override
  String toString() {
    return 'ServiceInitializationException: $message${originalError != null ? ' (原因: $originalError)' : ''}';
  }
}