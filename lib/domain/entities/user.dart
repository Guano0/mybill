import 'package:equatable/equatable.dart';

/// 用户领域实体
/// 表示应用中的用户概念，不依赖于具体的数据实现
class User extends Equatable {
  final String id;
  final String email;
  final String? username;
  final String? displayName;
  final String? avatar;
  final String? phone;
  final DateTime? birthday;
  final String? gender;
  final String? bio;
  final UserPreferencesEntity preferences;
  final UserSettingsEntity settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isVerified;
  final String? lastLoginIp;
  final DateTime? lastLoginAt;
  
  const User({
    required this.id,
    required this.email,
    this.username,
    this.displayName,
    this.avatar,
    this.phone,
    this.birthday,
    this.gender,
    this.bio,
    required this.preferences,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isVerified = false,
    this.lastLoginIp,
    this.lastLoginAt,
  });
  
  /// 获取显示名称
  String get displayNameOrUsername {
    return displayName ?? username ?? email.split('@').first;
  }
  
  /// 获取头像URL或默认头像
  String get avatarUrl {
    return avatar ?? 'https://via.placeholder.com/150';
  }
  
  /// 是否是新用户（注册不到7天）
  bool get isNewUser {
    final now = DateTime.now();
    final daysSinceCreation = now.difference(createdAt).inDays;
    return daysSinceCreation < 7;
  }
  
  /// 是否长时间未登录（超过30天）
  bool get isInactive {
    if (lastLoginAt == null) return false;
    final now = DateTime.now();
    final daysSinceLastLogin = now.difference(lastLoginAt!).inDays;
    return daysSinceLastLogin > 30;
  }
  
  /// 年龄
  int? get age {
    if (birthday == null) return null;
    final now = DateTime.now();
    int age = now.year - birthday!.year;
    if (now.month < birthday!.month || 
        (now.month == birthday!.month && now.day < birthday!.day)) {
      age--;
    }
    return age;
  }
  
  /// 复制并更新部分字段
  User copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? avatar,
    String? phone,
    DateTime? birthday,
    String? gender,
    String? bio,
    UserPreferencesEntity? preferences,
    UserSettingsEntity? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isVerified,
    String? lastLoginIp,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      preferences: preferences ?? this.preferences,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      lastLoginIp: lastLoginIp ?? this.lastLoginIp,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    email,
    username,
    displayName,
    avatar,
    phone,
    birthday,
    gender,
    bio,
    preferences,
    settings,
    createdAt,
    updatedAt,
    isActive,
    isVerified,
    lastLoginIp,
    lastLoginAt,
  ];
  
  @override
  String toString() {
    return 'User(id: $id, email: $email, displayName: $displayNameOrUsername)';
  }
}

/// 用户偏好设置实体
class UserPreferencesEntity extends Equatable {
  final String theme; // light, dark, system
  final String language; // zh, en, etc.
  final String currency; // CNY, USD, etc.
  final String dateFormat; // yyyy-MM-dd, MM/dd/yyyy, etc.
  final String timeFormat; // 24h, 12h
  final bool enableNotifications;
  final bool enableBiometric;
  final bool enableAutoSync;
  final bool enableVoiceInput;
  final bool enableOcrInput;
  final int defaultTransactionType; // 0: expense, 1: income
  final String? defaultCategory;
  final bool showDecimalPlaces;
  final bool groupTransactionsByDate;
  final int chartDefaultPeriod; // days
  
  const UserPreferencesEntity({
    this.theme = 'system',
    this.language = 'zh',
    this.currency = 'CNY',
    this.dateFormat = 'yyyy-MM-dd',
    this.timeFormat = '24h',
    this.enableNotifications = true,
    this.enableBiometric = false,
    this.enableAutoSync = true,
    this.enableVoiceInput = false,
    this.enableOcrInput = false,
    this.defaultTransactionType = 0,
    this.defaultCategory,
    this.showDecimalPlaces = true,
    this.groupTransactionsByDate = true,
    this.chartDefaultPeriod = 30,
  });
  
  /// 是否启用深色主题
  bool get isDarkTheme => theme == 'dark';
  
  /// 是否跟随系统主题
  bool get isSystemTheme => theme == 'system';
  
  /// 是否启用高级功能
  bool get hasAdvancedFeatures => enableVoiceInput || enableOcrInput;
  
  /// 获取货币符号
  String get currencySymbol {
    switch (currency) {
      case 'CNY':
        return '¥';
      case 'USD':
        return r'$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      default:
        return currency;
    }
  }
  
  /// 复制并更新部分字段
  UserPreferencesEntity copyWith({
    String? theme,
    String? language,
    String? currency,
    String? dateFormat,
    String? timeFormat,
    bool? enableNotifications,
    bool? enableBiometric,
    bool? enableAutoSync,
    bool? enableVoiceInput,
    bool? enableOcrInput,
    int? defaultTransactionType,
    String? defaultCategory,
    bool? showDecimalPlaces,
    bool? groupTransactionsByDate,
    int? chartDefaultPeriod,
  }) {
    return UserPreferencesEntity(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableBiometric: enableBiometric ?? this.enableBiometric,
      enableAutoSync: enableAutoSync ?? this.enableAutoSync,
      enableVoiceInput: enableVoiceInput ?? this.enableVoiceInput,
      enableOcrInput: enableOcrInput ?? this.enableOcrInput,
      defaultTransactionType: defaultTransactionType ?? this.defaultTransactionType,
      defaultCategory: defaultCategory ?? this.defaultCategory,
      showDecimalPlaces: showDecimalPlaces ?? this.showDecimalPlaces,
      groupTransactionsByDate: groupTransactionsByDate ?? this.groupTransactionsByDate,
      chartDefaultPeriod: chartDefaultPeriod ?? this.chartDefaultPeriod,
    );
  }
  
  @override
  List<Object?> get props => [
    theme,
    language,
    currency,
    dateFormat,
    timeFormat,
    enableNotifications,
    enableBiometric,
    enableAutoSync,
    enableVoiceInput,
    enableOcrInput,
    defaultTransactionType,
    defaultCategory,
    showDecimalPlaces,
    groupTransactionsByDate,
    chartDefaultPeriod,
  ];
}

/// 用户设置实体
class UserSettingsEntity extends Equatable {
  final bool enableAnalytics;
  final bool enableCrashReporting;
  final bool enablePerformanceMonitoring;
  final int dataRetentionDays;
  final bool enableDataExport;
  final bool enableCloudBackup;
  final String backupFrequency; // daily, weekly, monthly
  final bool enableSecurityAlerts;
  final bool requireBiometricForSensitiveActions;
  final int sessionTimeoutMinutes;
  final bool enableDeveloperMode;
  
  const UserSettingsEntity({
    this.enableAnalytics = true,
    this.enableCrashReporting = true,
    this.enablePerformanceMonitoring = true,
    this.dataRetentionDays = 365,
    this.enableDataExport = true,
    this.enableCloudBackup = false,
    this.backupFrequency = 'weekly',
    this.enableSecurityAlerts = true,
    this.requireBiometricForSensitiveActions = false,
    this.sessionTimeoutMinutes = 30,
    this.enableDeveloperMode = false,
  });
  
  /// 是否启用隐私保护模式
  bool get isPrivacyMode => !enableAnalytics && !enableCrashReporting;
  
  /// 是否启用安全模式
  bool get isSecurityMode => requireBiometricForSensitiveActions && enableSecurityAlerts;
  
  /// 会话超时时长
  Duration get sessionTimeout => Duration(minutes: sessionTimeoutMinutes);
  
  /// 数据保留时长
  Duration get dataRetentionPeriod => Duration(days: dataRetentionDays);
  
  /// 备份频率（天数）
  int get backupFrequencyDays {
    switch (backupFrequency) {
      case 'daily':
        return 1;
      case 'weekly':
        return 7;
      case 'monthly':
        return 30;
      default:
        return 7;
    }
  }
  
  /// 复制并更新部分字段
  UserSettingsEntity copyWith({
    bool? enableAnalytics,
    bool? enableCrashReporting,
    bool? enablePerformanceMonitoring,
    int? dataRetentionDays,
    bool? enableDataExport,
    bool? enableCloudBackup,
    String? backupFrequency,
    bool? enableSecurityAlerts,
    bool? requireBiometricForSensitiveActions,
    int? sessionTimeoutMinutes,
    bool? enableDeveloperMode,
  }) {
    return UserSettingsEntity(
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      enableCrashReporting: enableCrashReporting ?? this.enableCrashReporting,
      enablePerformanceMonitoring: enablePerformanceMonitoring ?? this.enablePerformanceMonitoring,
      dataRetentionDays: dataRetentionDays ?? this.dataRetentionDays,
      enableDataExport: enableDataExport ?? this.enableDataExport,
      enableCloudBackup: enableCloudBackup ?? this.enableCloudBackup,
      backupFrequency: backupFrequency ?? this.backupFrequency,
      enableSecurityAlerts: enableSecurityAlerts ?? this.enableSecurityAlerts,
      requireBiometricForSensitiveActions: requireBiometricForSensitiveActions ?? this.requireBiometricForSensitiveActions,
      sessionTimeoutMinutes: sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
      enableDeveloperMode: enableDeveloperMode ?? this.enableDeveloperMode,
    );
  }
  
  @override
  List<Object?> get props => [
    enableAnalytics,
    enableCrashReporting,
    enablePerformanceMonitoring,
    dataRetentionDays,
    enableDataExport,
    enableCloudBackup,
    backupFrequency,
    enableSecurityAlerts,
    requireBiometricForSensitiveActions,
    sessionTimeoutMinutes,
    enableDeveloperMode,
  ];
}