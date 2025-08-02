import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage.dart';
import '../utils/logger.dart';

/// API客户端封装
/// 
/// 基于Dio的网络请求封装，提供统一的请求处理、错误处理、
/// 认证管理、请求拦截等功能
class ApiClient {
  late final Dio _dio;
  final SecureStorage _secureStorage;
  final Logger _logger;

  ApiClient({
    required SecureStorage secureStorage,
    required Logger logger,
  }) : _secureStorage = secureStorage,
       _logger = logger {
    _initializeDio();
  }

  /// 初始化Dio配置
  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl + AppConstants.apiVersion,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 添加拦截器
    _dio.interceptors.addAll([
      _createAuthInterceptor(),
      _createLoggingInterceptor(),
      _createErrorInterceptor(),
    ]);
  }

  /// 创建认证拦截器
  Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 添加认证token
        final token = await _secureStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // 处理token过期
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            // 重试原请求
            final options = error.requestOptions;
            final token = await _secureStorage.getToken();
            options.headers['Authorization'] = 'Bearer $token';
            
            try {
              final response = await _dio.fetch(options);
              handler.resolve(response);
              return;
            } catch (e) {
              // 重试失败，继续原错误流程
            }
          }
        }
        handler.next(error);
      },
    );
  }

  /// 创建日志拦截器
  Interceptor _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.info('API Request: ${options.method} ${options.path}');
        _logger.debug('Request Headers: ${options.headers}');
        _logger.debug('Request Data: ${options.data}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.info('API Response: ${response.statusCode} ${response.requestOptions.path}');
        _logger.debug('Response Data: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) {
        _logger.error('API Error: ${error.message}');
        _logger.error('Error Response: ${error.response?.data}');
        handler.next(error);
      },
    );
  }

  /// 创建错误处理拦截器
  Interceptor _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        final exception = _handleDioError(error);
        handler.reject(DioException(
          requestOptions: error.requestOptions,
          error: exception,
          type: error.type,
          response: error.response,
        ));
      },
    );
  }

  /// 处理Dio错误
  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException(
          message: '请求超时，请检查网络连接',
          code: 'TIMEOUT',
        );
      
      case DioExceptionType.connectionError:
        return const NetworkException(
          message: '网络连接失败，请检查网络设置',
          code: 'CONNECTION_ERROR',
        );
      
      case DioExceptionType.badResponse:
        return _handleResponseError(error.response!);
      
      case DioExceptionType.cancel:
        return const NetworkException(
          message: '请求已取消',
          code: 'REQUEST_CANCELLED',
        );
      
      default:
        return NetworkException(
          message: error.message ?? '未知网络错误',
          code: 'UNKNOWN_ERROR',
        );
    }
  }

  /// 处理响应错误
  AppException _handleResponseError(Response response) {
    final statusCode = response.statusCode;
    final data = response.data;
    
    String message = '服务器错误';
    String? code;
    
    if (data is Map<String, dynamic>) {
      message = data['message'] ?? message;
      code = data['code']?.toString();
    }

    switch (statusCode) {
      case 400:
        return ValidationException(
          message: message,
          code: code ?? 'BAD_REQUEST',
          data: data,
        );
      
      case 401:
        return AuthException(
          message: '认证失败，请重新登录',
          code: code ?? 'UNAUTHORIZED',
          data: data,
        );
      
      case 403:
        return PermissionException(
          message: '权限不足',
          code: code ?? 'FORBIDDEN',
          data: data,
        );
      
      case 404:
        return ServerException(
          message: '请求的资源不存在',
          code: code ?? 'NOT_FOUND',
          data: data,
        );
      
      case 422:
        return ValidationException(
          message: message,
          code: code ?? 'VALIDATION_ERROR',
          data: data,
        );
      
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message: '服务器内部错误',
          code: code ?? 'SERVER_ERROR',
          data: data,
        );
      
      default:
        return ServerException(
          message: message,
          code: code ?? 'HTTP_ERROR',
          data: data,
        );
    }
  }

  /// 刷新token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Authorization': null}, // 移除旧token
        ),
      );

      final newToken = response.data['access_token'];
      final newRefreshToken = response.data['refresh_token'];
      
      await _secureStorage.saveToken(newToken);
      if (newRefreshToken != null) {
        await _secureStorage.saveRefreshToken(newRefreshToken);
      }
      
      return true;
    } catch (e) {
      _logger.error('Token refresh failed: $e');
      await _secureStorage.clearTokens();
      return false;
    }
  }

  /// 检查网络连接
  Future<bool> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// GET请求
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (!await _checkConnectivity()) {
      throw const NetworkException(
        message: '网络连接不可用',
        code: 'NO_INTERNET',
      );
    }

    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      rethrow;
    }
  }

  /// POST请求
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (!await _checkConnectivity()) {
      throw const NetworkException(
        message: '网络连接不可用',
        code: 'NO_INTERNET',
      );
    }

    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      rethrow;
    }
  }

  /// PUT请求
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (!await _checkConnectivity()) {
      throw const NetworkException(
        message: '网络连接不可用',
        code: 'NO_INTERNET',
      );
    }

    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      rethrow;
    }
  }

  /// DELETE请求
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (!await _checkConnectivity()) {
      throw const NetworkException(
        message: '网络连接不可用',
        code: 'NO_INTERNET',
      );
    }

    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      rethrow;
    }
  }

  /// 上传文件
  Future<Response<T>> uploadFile<T>(
    String path,
    String filePath, {
    String? fileName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    if (!await _checkConnectivity()) {
      throw const NetworkException(
        message: '网络连接不可用',
        code: 'NO_INTERNET',
      );
    }

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
        ...?data,
      });

      return await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      rethrow;
    }
  }

  /// 下载文件
  Future<Response> downloadFile(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    if (!await _checkConnectivity()) {
      throw const NetworkException(
        message: '网络连接不可用',
        code: 'NO_INTERNET',
      );
    }

    try {
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      rethrow;
    }
  }

  /// 取消所有请求
  void cancelRequests([String? reason]) {
    _dio.close(force: true);
  }
}