import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import '../utils/logger.dart';
import '../storage/secure_storage.dart';

/// 生物识别服务
/// 提供指纹、面部识别等生物识别功能
class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();
  
  final LocalAuthentication _localAuth = LocalAuthentication();
  final Logger _logger = Logger();
  late final SecureStorage _secureStorage;
  
  /// 初始化服务
  void init(SecureStorage secureStorage) {
    _secureStorage = secureStorage;
  }
  
  /// 检查设备是否支持生物识别
  Future<bool> isDeviceSupported() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      _logger.info('生物识别可用性: $isAvailable, 设备支持: $isDeviceSupported');
      return isAvailable && isDeviceSupported;
    } catch (e) {
      _logger.error('检查生物识别支持失败', e);
      return false;
    }
  }
  
  /// 获取可用的生物识别类型
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      _logger.info('可用的生物识别类型: $biometrics');
      return biometrics;
    } catch (e) {
      _logger.error('获取生物识别类型失败', e);
      return [];
    }
  }
  
  /// 检查是否有已注册的生物识别
  Future<bool> hasEnrolledBiometrics() async {
    try {
      final biometrics = await getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (e) {
      _logger.error('检查已注册生物识别失败', e);
      return false;
    }
  }
  
  /// 执行生物识别认证
  Future<bool> authenticate({
    String localizedReason = '请验证您的身份',
    bool useErrorDialogs = true,
    bool stickyAuth = false,
    bool sensitiveTransaction = true,
    bool biometricOnly = false,
  }) async {
    try {
      _logger.info('开始生物识别认证');
      
      // 检查设备支持
      if (!await isDeviceSupported()) {
        _logger.warning('设备不支持生物识别');
        return false;
      }
      
      // 检查是否有已注册的生物识别
      if (!await hasEnrolledBiometrics()) {
        _logger.warning('没有已注册的生物识别');
        return false;
      }
      
      // 执行认证
      final result = await _localAuth.authenticate(
        localizedReason: localizedReason,
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: '生物识别认证',
            cancelButton: '取消',
            deviceCredentialsRequiredTitle: '需要设备凭据',
            deviceCredentialsSetupDescription: '请在设备设置中设置生物识别',
            goToSettingsButton: '去设置',
            goToSettingsDescription: '请在设置中配置生物识别',
          ),
          IOSAuthMessages(
            cancelButton: '取消',
            goToSettingsButton: '去设置',
            goToSettingsDescription: '请在设置中配置生物识别',
            lockOut: '生物识别已锁定',
          ),
        ],
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          sensitiveTransaction: sensitiveTransaction,
          biometricOnly: biometricOnly,
        ),
      );
      
      if (result) {
        _logger.info('生物识别认证成功');
        await _recordSuccessfulAuth();
      } else {
        _logger.warning('生物识别认证失败');
        await _recordFailedAuth();
      }
      
      return result;
    } catch (e) {
      _logger.error('生物识别认证异常', e);
      await _recordFailedAuth();
      return false;
    }
  }
  
  /// 快速认证（用于应用解锁）
  Future<bool> quickAuth() async {
    return await authenticate(
      localizedReason: '请验证身份以解锁应用',
      useErrorDialogs: true,
      stickyAuth: true,
      biometricOnly: true,
    );
  }
  
  /// 敏感操作认证（用于重要操作确认）
  Future<bool> sensitiveAuth(String operation) async {
    return await authenticate(
      localizedReason: '请验证身份以执行$operation',
      useErrorDialogs: true,
      stickyAuth: true,
      sensitiveTransaction: true,
    );
  }
  
  /// 检查生物识别是否已启用
  Future<bool> isBiometricEnabled() async {
    try {
      return await _secureStorage.getBiometricEnabled();
    } catch (e) {
      _logger.error('检查生物识别启用状态失败', e);
      return false;
    }
  }
  
  /// 启用生物识别
  Future<bool> enableBiometric() async {
    try {
      // 首先验证当前用户
      final authResult = await authenticate(
        localizedReason: '请验证身份以启用生物识别',
      );
      
      if (authResult) {
        await _secureStorage.setBiometricEnabled(true);
        _logger.info('生物识别已启用');
        return true;
      } else {
        _logger.warning('启用生物识别失败：认证未通过');
        return false;
      }
    } catch (e) {
      _logger.error('启用生物识别失败', e);
      return false;
    }
  }
  
  /// 禁用生物识别
  Future<bool> disableBiometric() async {
    try {
      // 验证当前用户
      final authResult = await authenticate(
        localizedReason: '请验证身份以禁用生物识别',
      );
      
      if (authResult) {
        await _secureStorage.setBiometricEnabled(false);
        _logger.info('生物识别已禁用');
        return true;
      } else {
        _logger.warning('禁用生物识别失败：认证未通过');
        return false;
      }
    } catch (e) {
      _logger.error('禁用生物识别失败', e);
      return false;
    }
  }
  
  /// 获取生物识别类型描述
  String getBiometricTypeDescription(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return '面部识别';
      case BiometricType.fingerprint:
        return '指纹识别';
      case BiometricType.iris:
        return '虹膜识别';
      case BiometricType.weak:
        return '弱生物识别';
      case BiometricType.strong:
        return '强生物识别';
    }
  }
  
  /// 获取设备支持的生物识别描述
  Future<String> getSupportedBiometricsDescription() async {
    final biometrics = await getAvailableBiometrics();
    if (biometrics.isEmpty) {
      return '不支持生物识别';
    }
    
    final descriptions = biometrics
        .map((type) => getBiometricTypeDescription(type))
        .toList();
    
    return descriptions.join('、');
  }
  
  /// 记录成功的认证
  Future<void> _recordSuccessfulAuth() async {
    try {
      final now = DateTime.now();
      await _secureStorage.setString('last_biometric_auth', now.toIso8601String());
      
      // 重置失败计数
      await _secureStorage.setInt('biometric_fail_count', 0);
    } catch (e) {
      _logger.error('记录成功认证失败', e);
    }
  }
  
  /// 记录失败的认证
  Future<void> _recordFailedAuth() async {
    try {
      final currentCount = await _secureStorage.getInt('biometric_fail_count') ?? 0;
      await _secureStorage.setInt('biometric_fail_count', currentCount + 1);
      
      final now = DateTime.now();
      await _secureStorage.setString('last_biometric_fail', now.toIso8601String());
      
      // 如果失败次数过多，可以考虑临时禁用
      if (currentCount + 1 >= 5) {
        _logger.warning('生物识别失败次数过多，考虑临时禁用');
        // 这里可以实现临时禁用逻辑
      }
    } catch (e) {
      _logger.error('记录失败认证失败', e);
    }
  }
  
  /// 获取最后认证时间
  Future<DateTime?> getLastAuthTime() async {
    try {
      final timeString = await _secureStorage.getString('last_biometric_auth');
      if (timeString != null) {
        return DateTime.parse(timeString);
      }
      return null;
    } catch (e) {
      _logger.error('获取最后认证时间失败', e);
      return null;
    }
  }
  
  /// 获取失败次数
  Future<int> getFailCount() async {
    try {
      return await _secureStorage.getInt('biometric_fail_count') ?? 0;
    } catch (e) {
      _logger.error('获取失败次数失败', e);
      return 0;
    }
  }
  
  /// 重置失败计数
  Future<void> resetFailCount() async {
    try {
      await _secureStorage.setInt('biometric_fail_count', 0);
    } catch (e) {
      _logger.error('重置失败计数失败', e);
    }
  }
  
  /// 检查是否需要重新认证（基于时间）
  Future<bool> needsReauth({Duration timeout = const Duration(minutes: 5)}) async {
    final lastAuth = await getLastAuthTime();
    if (lastAuth == null) return true;
    
    final now = DateTime.now();
    return now.difference(lastAuth) > timeout;
  }
}

/// 生物识别认证结果
enum BiometricAuthResult {
  success,
  failure,
  cancelled,
  notAvailable,
  notEnrolled,
  error,
}

/// 生物识别异常
class BiometricException implements Exception {
  final String message;
  final BiometricAuthResult result;
  final dynamic originalError;
  
  const BiometricException(
    this.message,
    this.result, [
    this.originalError,
  ]);
  
  @override
  String toString() {
    return 'BiometricException: $message (结果: $result)${originalError != null ? ' 原因: $originalError' : ''}';
  }
}