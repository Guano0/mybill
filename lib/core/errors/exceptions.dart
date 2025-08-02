/// 应用异常类定义
/// 
/// 定义应用中可能出现的各种异常类型，用于在数据层抛出具体的异常，
/// 然后在Repository层转换为对应的Failure

/// 异常基类
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic data;

  const AppException({
    required this.message,
    this.code,
    this.data,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// 服务器异常
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.data,
  });
}

/// 网络异常
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.data,
  });
}

/// 缓存异常
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.data,
  });
}

/// 认证异常
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.data,
  });
}

/// 验证异常
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.data,
  });
}

/// 权限异常
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
    super.data,
  });
}

/// 数据库异常
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code,
    super.data,
  });
}

/// 文件操作异常
class FileException extends AppException {
  const FileException({
    required super.message,
    super.code,
    super.data,
  });
}

/// 业务逻辑异常
class BusinessException extends AppException {
  const BusinessException({
    required super.message,
    super.code,
    super.data,
  });
}

/// 超时异常
class TimeoutException extends AppException {
  const TimeoutException({
    required super.message,
    super.code,
    super.data,
  });
}

/// 格式异常
class FormatException extends AppException {
  const FormatException({
    required super.message,
    super.code,
    super.data,
  });
}

/// 扩展功能异常（预留）
/// 语音识别异常
class VoiceRecognitionException extends AppException {
  const VoiceRecognitionException({
    required super.message,
    super.code,
    super.data,
  });
}

/// OCR识别异常
class OcrException extends AppException {
  const OcrException({
    required super.message,
    super.code,
    super.data,
  });
}

/// 同步异常
class SyncException extends AppException {
  const SyncException({
    required super.message,
    super.code,
    super.data,
  });
}

/// 生物识别异常
class BiometricException extends AppException {
  const BiometricException({
    required super.message,
    super.code,
    super.data,
  });
}