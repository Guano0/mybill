import 'dart:developer' as developer;
import 'dart:io';
import 'package:path/path.dart' as path;
import '../constants/app_constants.dart';

/// 日志级别枚举
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

/// 日志工具类
/// 
/// 提供统一的日志记录功能，支持不同级别的日志输出、
/// 文件日志记录、日志过滤等功能
class Logger {
  static Logger? _instance;
  static const String _logFileName = 'app.log';
  static const int _maxLogFileSize = 5 * 1024 * 1024; // 5MB
  static const int _maxLogFiles = 3;
  
  late final String _logFilePath;
  LogLevel _minLevel = LogLevel.debug;
  bool _enableFileLogging = false;
  bool _enableConsoleLogging = true;

  Logger._internal();

  /// 获取Logger单例
  static Logger get instance {
    _instance ??= Logger._internal();
    return _instance!;
  }

  /// 初始化日志系统
  Future<void> init({
    LogLevel minLevel = LogLevel.debug,
    bool enableFileLogging = false,
    bool enableConsoleLogging = true,
    String? logDirectory,
  }) async {
    _minLevel = minLevel;
    _enableFileLogging = enableFileLogging;
    _enableConsoleLogging = enableConsoleLogging;

    if (_enableFileLogging) {
      await _initFileLogging(logDirectory);
    }

    info('Logger initialized with level: ${minLevel.name}');
  }

  /// 初始化文件日志
  Future<void> _initFileLogging(String? logDirectory) async {
    try {
      String logDir;
      if (logDirectory != null) {
        logDir = logDirectory;
      } else {
        // 获取应用文档目录
        final appDocDir = Directory.systemTemp.path; // 简化处理，实际应用中应使用path_provider
        logDir = path.join(appDocDir, 'logs');
      }

      final logDirObj = Directory(logDir);
      if (!await logDirObj.exists()) {
        await logDirObj.create(recursive: true);
      }

      _logFilePath = path.join(logDir, _logFileName);
      await _rotateLogFiles();
    } catch (e) {
      _enableFileLogging = false;
      error('Failed to initialize file logging: $e');
    }
  }

  /// 轮转日志文件
  Future<void> _rotateLogFiles() async {
    try {
      final logFile = File(_logFilePath);
      if (await logFile.exists()) {
        final stat = await logFile.stat();
        if (stat.size > _maxLogFileSize) {
          // 轮转日志文件
          for (int i = _maxLogFiles - 1; i > 0; i--) {
            final oldFile = File('$_logFilePath.$i');
            final newFile = File('$_logFilePath.${i + 1}');
            if (await oldFile.exists()) {
              if (i == _maxLogFiles - 1) {
                await oldFile.delete();
              } else {
                await oldFile.rename(newFile.path);
              }
            }
          }
          await logFile.rename('$_logFilePath.1');
        }
      }
    } catch (e) {
      // 轮转失败时继续使用当前文件
    }
  }

  /// 写入日志到文件
  Future<void> _writeToFile(String message) async {
    if (!_enableFileLogging) return;

    try {
      await _rotateLogFiles();
      final logFile = File(_logFilePath);
      await logFile.writeAsString(
        '$message\n',
        mode: FileMode.append,
      );
    } catch (e) {
      // 文件写入失败时不影响应用运行
    }
  }

  /// 格式化日志消息
  String _formatMessage(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase().padRight(7);
    final tagStr = tag != null ? '[$tag] ' : '';
    
    var formattedMessage = '$timestamp $levelStr $tagStr$message';
    
    if (error != null) {
      formattedMessage += '\nError: $error';
    }
    
    if (stackTrace != null) {
      formattedMessage += '\nStackTrace: $stackTrace';
    }
    
    return formattedMessage;
  }

  /// 记录日志
  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < _minLevel.index) return;

    final formattedMessage = _formatMessage(
      level,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );

    // 控制台输出
    if (_enableConsoleLogging) {
      switch (level) {
        case LogLevel.debug:
          developer.log(formattedMessage, name: 'DEBUG');
          break;
        case LogLevel.info:
          developer.log(formattedMessage, name: 'INFO');
          break;
        case LogLevel.warning:
          developer.log(formattedMessage, name: 'WARNING');
          break;
        case LogLevel.error:
        case LogLevel.fatal:
          developer.log(
            formattedMessage,
            name: level.name.toUpperCase(),
            error: error,
            stackTrace: stackTrace,
          );
          break;
      }
    }

    // 文件输出
    _writeToFile(formattedMessage);
  }

  /// 调试日志
  void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.debug,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// 信息日志
  void info(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.info,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// 警告日志
  void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.warning,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// 错误日志
  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// 致命错误日志
  void fatal(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.fatal,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// 网络请求日志
  void network(
    String message, {
    String? method,
    String? url,
    int? statusCode,
    Object? error,
  }) {
    final tag = 'NETWORK';
    var logMessage = message;
    
    if (method != null && url != null) {
      logMessage = '$method $url - $message';
    }
    
    if (statusCode != null) {
      logMessage += ' (Status: $statusCode)';
    }

    if (error != null) {
      this.error(logMessage, tag: tag, error: error);
    } else {
      info(logMessage, tag: tag);
    }
  }

  /// 数据库操作日志
  void database(
    String message, {
    String? operation,
    String? table,
    Object? error,
  }) {
    final tag = 'DATABASE';
    var logMessage = message;
    
    if (operation != null && table != null) {
      logMessage = '$operation on $table - $message';
    }

    if (error != null) {
      this.error(logMessage, tag: tag, error: error);
    } else {
      debug(logMessage, tag: tag);
    }
  }

  /// 用户行为日志
  void userAction(
    String action, {
    Map<String, dynamic>? parameters,
  }) {
    final tag = 'USER_ACTION';
    var message = 'User action: $action';
    
    if (parameters != null && parameters.isNotEmpty) {
      message += ' with parameters: $parameters';
    }
    
    info(message, tag: tag);
  }

  /// 性能日志
  void performance(
    String operation,
    Duration duration, {
    Map<String, dynamic>? metadata,
  }) {
    final tag = 'PERFORMANCE';
    var message = '$operation took ${duration.inMilliseconds}ms';
    
    if (metadata != null && metadata.isNotEmpty) {
      message += ' - metadata: $metadata';
    }
    
    info(message, tag: tag);
  }

  /// 设置最小日志级别
  void setMinLevel(LogLevel level) {
    _minLevel = level;
    info('Log level changed to: ${level.name}');
  }

  /// 启用/禁用控制台日志
  void setConsoleLogging(bool enabled) {
    _enableConsoleLogging = enabled;
    info('Console logging ${enabled ? 'enabled' : 'disabled'}');
  }

  /// 启用/禁用文件日志
  Future<void> setFileLogging(bool enabled, [String? logDirectory]) async {
    if (enabled && !_enableFileLogging) {
      await _initFileLogging(logDirectory);
    }
    _enableFileLogging = enabled;
    info('File logging ${enabled ? 'enabled' : 'disabled'}');
  }

  /// 清理日志文件
  Future<void> clearLogs() async {
    if (!_enableFileLogging) return;

    try {
      final logFile = File(_logFilePath);
      if (await logFile.exists()) {
        await logFile.delete();
      }
      
      // 删除轮转的日志文件
      for (int i = 1; i <= _maxLogFiles; i++) {
        final rotatedFile = File('$_logFilePath.$i');
        if (await rotatedFile.exists()) {
          await rotatedFile.delete();
        }
      }
      
      info('Log files cleared');
    } catch (e) {
      error('Failed to clear log files: $e');
    }
  }

  /// 获取日志文件路径
  String? get logFilePath => _enableFileLogging ? _logFilePath : null;

  /// 获取当前日志级别
  LogLevel get currentLevel => _minLevel;

  /// 检查是否启用文件日志
  bool get isFileLoggingEnabled => _enableFileLogging;

  /// 检查是否启用控制台日志
  bool get isConsoleLoggingEnabled => _enableConsoleLogging;
}

/// 全局日志实例
final logger = Logger.instance;