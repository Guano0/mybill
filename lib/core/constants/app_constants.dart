/// 应用常量配置
/// 
/// 定义应用中使用的所有常量，包括API配置、本地存储键值、
/// 业务常量等，便于统一管理和维护
class AppConstants {
  // 私有构造函数，防止实例化
  AppConstants._();

  /// 应用信息
  static const String appName = 'MyBill';
  static const String appVersion = '1.0.0';
  static const String appDescription = '个人记账应用';

  /// API配置
  static const String baseUrl = 'https://api.mybill.com';
  static const String apiVersion = '/v1';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  /// 本地存储键值
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userInfoKey = 'user_info';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String firstLaunchKey = 'first_launch';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String autoSyncKey = 'auto_sync';
  static const String currencyKey = 'currency_code';

  /// 数据库配置
  static const String databaseName = 'mybill.db';
  static const int databaseVersion = 1;

  /// 分页配置
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  /// 文件上传配置
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];

  /// 业务常量
  static const double maxTransactionAmount = 999999999.99;
  static const double minTransactionAmount = 0.01;
  static const int maxCategoryNameLength = 20;
  static const int maxTransactionNoteLength = 200;
  static const int maxAccountNameLength = 30;

  /// 缓存配置
  static const Duration cacheExpiration = Duration(hours: 24);
  static const Duration shortCacheExpiration = Duration(minutes: 30);

  /// 动画配置
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  /// 扩展功能预留
  /// 语音记账相关常量
  static const Duration maxVoiceRecordDuration = Duration(minutes: 2);
  static const String voiceRecordFormat = 'wav';
  
  /// OCR识别相关常量
  static const double ocrConfidenceThreshold = 0.8;
  static const List<String> supportedOcrLanguages = ['zh', 'en'];
  
  /// 多人记账相关常量
  static const int maxGroupMembers = 10;
  static const int maxGroupNameLength = 30;
  
  /// 同步相关常量
  static const Duration syncInterval = Duration(minutes: 15);
  static const int maxSyncRetries = 3;
}

/// 路由常量
class RouteConstants {
  RouteConstants._();

  // 认证相关路由
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  
  // 主要功能路由
  static const String home = '/home';
  static const String addTransaction = '/add-transaction';
  static const String editTransaction = '/edit-transaction';
  static const String transactionDetail = '/transaction-detail';
  static const String transactionList = '/transaction-list';
  
  // 分类管理路由
  static const String categoryList = '/category-list';
  static const String addCategory = '/add-category';
  static const String editCategory = '/edit-category';
  
  // 统计分析路由
  static const String statistics = '/statistics';
  static const String monthlyReport = '/monthly-report';
  static const String yearlyReport = '/yearly-report';
  static const String categoryReport = '/category-report';
  
  // 设置相关路由
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String security = '/security';
  static const String theme = '/theme';
  static const String language = '/language';
  static const String about = '/about';
  
  // 扩展功能路由（预留）
  static const String voiceRecord = '/voice-record';
  static const String ocrScan = '/ocr-scan';
  static const String groupManagement = '/group-management';
  static const String backup = '/backup';
}

/// 错误代码常量
class ErrorConstants {
  ErrorConstants._();

  // 网络错误
  static const String networkError = 'NETWORK_ERROR';
  static const String timeoutError = 'TIMEOUT_ERROR';
  static const String serverError = 'SERVER_ERROR';
  
  // 认证错误
  static const String unauthorized = 'UNAUTHORIZED';
  static const String tokenExpired = 'TOKEN_EXPIRED';
  static const String invalidCredentials = 'INVALID_CREDENTIALS';
  
  // 业务错误
  static const String invalidInput = 'INVALID_INPUT';
  static const String dataNotFound = 'DATA_NOT_FOUND';
  static const String duplicateData = 'DUPLICATE_DATA';
  
  // 本地存储错误
  static const String storageError = 'STORAGE_ERROR';
  static const String databaseError = 'DATABASE_ERROR';
  
  // 权限错误
  static const String permissionDenied = 'PERMISSION_DENIED';
  static const String cameraPermissionDenied = 'CAMERA_PERMISSION_DENIED';
  static const String storagePermissionDenied = 'STORAGE_PERMISSION_DENIED';
}