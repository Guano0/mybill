import 'package:equatable/equatable.dart';

/// 失败基类
/// 
/// 使用Equatable来比较失败对象，便于测试和状态管理
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic data;

  const Failure({
    required this.message,
    this.code,
    this.data,
  });

  @override
  List<Object?> get props => [message, code, data];
}

/// 服务器失败
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// 网络连接失败
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// 缓存失败
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// 认证失败
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// 验证失败
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// 权限失败
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// 数据库失败
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// 文件操作失败
class FileFailure extends Failure {
  const FileFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// 业务逻辑失败
class BusinessFailure extends Failure {
  const BusinessFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// 未知失败
class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// 扩展功能失败（预留）
/// 语音识别失败
class VoiceRecognitionFailure extends Failure {
  const VoiceRecognitionFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// OCR识别失败
class OcrFailure extends Failure {
  const OcrFailure({
    required super.message,
    super.code,
    super.data,
  });
}

/// 同步失败
class SyncFailure extends Failure {
  const SyncFailure({
    required super.message,
    super.code,
    super.data,
  });
}