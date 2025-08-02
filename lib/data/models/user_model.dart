import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// 用户数据模型
/// 用于数据层的用户信息处理
class UserModel extends Equatable {
  final String id;
  final String email;
  final String? username;
  final String? displayName;
  final String? avatar;
  final String? phone;
  final DateTime? birthday;
  final String? gender;
  final String? bio;
  final UserPreferences preferences;
  final UserSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isVerified;
  final String? lastLoginIp;
  final DateTime? lastLoginAt;
  
  const UserModel({
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
  
  /// 从JSON创建UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      avatar: json['avatar'] as String?,
      phone: json['phone'] as String?,
      birthday: json['birthday'] != null 
          ? DateTime.parse(json['birthday'] as String)
          : null,
      gender: json['gender'] as String?,
      bio: json['bio'] as String?,
      preferences: UserPreferences.fromJson(
        json['preferences'] as Map<String, dynamic>? ?? {},
      ),
      settings: UserSettings.fromJson(
        json['settings'] as Map<String, dynamic>? ?? {},
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      lastLoginIp: json['last_login_ip'] as String?,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
    );
  }
  
  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'display_name': displayName,
      'avatar': avatar,
      'phone': phone,
      'birthday': birthday?.toIso8601String(),
      'gender': gender,
      'bio': bio,
      'preferences': preferences.toJson(),
      'settings': settings.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'is_verified': isVerified,
      'last_login_ip': lastLoginIp,
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }
  
  /// 转换为领域实体
  User toEntity() {
    return User(
      id: id,
      email: email,
      username: username,
      displayName: displayName,
      avatar: avatar,
      phone: phone,
      birthday: birthday,
      gender: gender,
      bio: bio,
      preferences: preferences.toEntity(),
      settings: settings.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      isVerified: isVerified,
      lastLoginIp: lastLoginIp,
      lastLoginAt: lastLoginAt,
    );
  }
  
  /// 从领域实体创建
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      username: user.username,
      displayName: user.displayName,
      avatar: user.avatar,
      phone: user.phone,
      birthday: user.birthday,
      gender: user.gender,
      bio: user.bio,
      preferences: UserPreferences.fromEntity(user.preferences),
      settings: UserSettings.fromEntity(user.settings),
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      isActive: user.isActive,
      isVerified: user.isVerified,
      lastLoginIp: user.lastLoginIp,
      lastLoginAt: user.lastLoginAt,
    );
  }
  
  /// 复制并更新部分字段
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? avatar,
    String? phone,
    DateTime? birthday,
    String? gender,
    String? bio,
    UserPreferences? preferences,
    UserSettings? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isVerified,
    String? lastLoginIp,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
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
}

/// 用户偏好设置模型
class UserPreferences extends Equatable {
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
  
  const UserPreferences({
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
  
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      theme: json['theme'] as String? ?? 'system',
      language: json['language'] as String? ?? 'zh',
      currency: json['currency'] as String? ?? 'CNY',
      dateFormat: json['date_format'] as String? ?? 'yyyy-MM-dd',
      timeFormat: json['time_format'] as String? ?? '24h',
      enableNotifications: json['enable_notifications'] as bool? ?? true,
      enableBiometric: json['enable_biometric'] as bool? ?? false,
      enableAutoSync: json['enable_auto_sync'] as bool? ?? true,
      enableVoiceInput: json['enable_voice_input'] as bool? ?? false,
      enableOcrInput: json['enable_ocr_input'] as bool? ?? false,
      defaultTransactionType: json['default_transaction_type'] as int? ?? 0,
      defaultCategory: json['default_category'] as String?,
      showDecimalPlaces: json['show_decimal_places'] as bool? ?? true,
      groupTransactionsByDate: json['group_transactions_by_date'] as bool? ?? true,
      chartDefaultPeriod: json['chart_default_period'] as int? ?? 30,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'language': language,
      'currency': currency,
      'date_format': dateFormat,
      'time_format': timeFormat,
      'enable_notifications': enableNotifications,
      'enable_biometric': enableBiometric,
      'enable_auto_sync': enableAutoSync,
      'enable_voice_input': enableVoiceInput,
      'enable_ocr_input': enableOcrInput,
      'default_transaction_type': defaultTransactionType,
      'default_category': defaultCategory,
      'show_decimal_places': showDecimalPlaces,
      'group_transactions_by_date': groupTransactionsByDate,
      'chart_default_period': chartDefaultPeriod,
    };
  }
  
  /// 转换为领域实体
  UserPreferencesEntity toEntity() {
    return UserPreferencesEntity(
      theme: theme,
      language: language,
      currency: currency,
      dateFormat: dateFormat,
      timeFormat: timeFormat,
      enableNotifications: enableNotifications,
      enableBiometric: enableBiometric,
      enableAutoSync: enableAutoSync,
      enableVoiceInput: enableVoiceInput,
      enableOcrInput: enableOcrInput,
      defaultTransactionType: defaultTransactionType,
      defaultCategory: defaultCategory,
      showDecimalPlaces: showDecimalPlaces,
      groupTransactionsByDate: groupTransactionsByDate,
      chartDefaultPeriod: chartDefaultPeriod,
    );
  }
  
  /// 从领域实体创建
  factory UserPreferences.fromEntity(UserPreferencesEntity entity) {
    return UserPreferences(
      theme: entity.theme,
      language: entity.language,
      currency: entity.currency,
      dateFormat: entity.dateFormat,
      timeFormat: entity.timeFormat,
      enableNotifications: entity.enableNotifications,
      enableBiometric: entity.enableBiometric,
      enableAutoSync: entity.enableAutoSync,
      enableVoiceInput: entity.enableVoiceInput,
      enableOcrInput: entity.enableOcrInput,
      defaultTransactionType: entity.defaultTransactionType,
      defaultCategory: entity.defaultCategory,
      showDecimalPlaces: entity.showDecimalPlaces,
      groupTransactionsByDate: entity.groupTransactionsByDate,
      chartDefaultPeriod: entity.chartDefaultPeriod,
    );
  }
  
  UserPreferences copyWith({
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
    return UserPreferences(
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

/// 用户设置模型
class UserSettings extends Equatable {
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
  
  const UserSettings({
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
  
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      enableAnalytics: json['enable_analytics'] as bool? ?? true,
      enableCrashReporting: json['enable_crash_reporting'] as bool? ?? true,
      enablePerformanceMonitoring: json['enable_performance_monitoring'] as bool? ?? true,
      dataRetentionDays: json['data_retention_days'] as int? ?? 365,
      enableDataExport: json['enable_data_export'] as bool? ?? true,
      enableCloudBackup: json['enable_cloud_backup'] as bool? ?? false,
      backupFrequency: json['backup_frequency'] as String? ?? 'weekly',
      enableSecurityAlerts: json['enable_security_alerts'] as bool? ?? true,
      requireBiometricForSensitiveActions: json['require_biometric_for_sensitive_actions'] as bool? ?? false,
      sessionTimeoutMinutes: json['session_timeout_minutes'] as int? ?? 30,
      enableDeveloperMode: json['enable_developer_mode'] as bool? ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'enable_analytics': enableAnalytics,
      'enable_crash_reporting': enableCrashReporting,
      'enable_performance_monitoring': enablePerformanceMonitoring,
      'data_retention_days': dataRetentionDays,
      'enable_data_export': enableDataExport,
      'enable_cloud_backup': enableCloudBackup,
      'backup_frequency': backupFrequency,
      'enable_security_alerts': enableSecurityAlerts,
      'require_biometric_for_sensitive_actions': requireBiometricForSensitiveActions,
      'session_timeout_minutes': sessionTimeoutMinutes,
      'enable_developer_mode': enableDeveloperMode,
    };
  }
  
  /// 转换为领域实体
  UserSettingsEntity toEntity() {
    return UserSettingsEntity(
      enableAnalytics: enableAnalytics,
      enableCrashReporting: enableCrashReporting,
      enablePerformanceMonitoring: enablePerformanceMonitoring,
      dataRetentionDays: dataRetentionDays,
      enableDataExport: enableDataExport,
      enableCloudBackup: enableCloudBackup,
      backupFrequency: backupFrequency,
      enableSecurityAlerts: enableSecurityAlerts,
      requireBiometricForSensitiveActions: requireBiometricForSensitiveActions,
      sessionTimeoutMinutes: sessionTimeoutMinutes,
      enableDeveloperMode: enableDeveloperMode,
    );
  }
  
  /// 从领域实体创建
  factory UserSettings.fromEntity(UserSettingsEntity entity) {
    return UserSettings(
      enableAnalytics: entity.enableAnalytics,
      enableCrashReporting: entity.enableCrashReporting,
      enablePerformanceMonitoring: entity.enablePerformanceMonitoring,
      dataRetentionDays: entity.dataRetentionDays,
      enableDataExport: entity.enableDataExport,
      enableCloudBackup: entity.enableCloudBackup,
      backupFrequency: entity.backupFrequency,
      enableSecurityAlerts: entity.enableSecurityAlerts,
      requireBiometricForSensitiveActions: entity.requireBiometricForSensitiveActions,
      sessionTimeoutMinutes: entity.sessionTimeoutMinutes,
      enableDeveloperMode: entity.enableDeveloperMode,
    );
  }
  
  UserSettings copyWith({
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
    return UserSettings(
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