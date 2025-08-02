import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';

/// 权限服务
/// 统一管理应用所需的各种权限
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();
  
  final Logger _logger = Logger();
  
  /// 请求相机权限
  Future<bool> requestCameraPermission() async {
    return await _requestPermission(
      Permission.camera,
      '相机权限',
      '需要相机权限来拍摄收据照片',
    );
  }
  
  /// 请求相册权限
  Future<bool> requestPhotosPermission() async {
    return await _requestPermission(
      Permission.photos,
      '相册权限',
      '需要相册权限来选择图片',
    );
  }
  
  /// 请求存储权限
  Future<bool> requestStoragePermission() async {
    return await _requestPermission(
      Permission.storage,
      '存储权限',
      '需要存储权限来保存数据和文件',
    );
  }
  
  /// 请求麦克风权限（语音记账功能）
  Future<bool> requestMicrophonePermission() async {
    return await _requestPermission(
      Permission.microphone,
      '麦克风权限',
      '需要麦克风权限来进行语音记账',
    );
  }
  
  /// 请求通知权限
  Future<bool> requestNotificationPermission() async {
    return await _requestPermission(
      Permission.notification,
      '通知权限',
      '需要通知权限来发送提醒消息',
    );
  }
  
  /// 请求位置权限（可能用于记录消费地点）
  Future<bool> requestLocationPermission() async {
    return await _requestPermission(
      Permission.location,
      '位置权限',
      '需要位置权限来记录消费地点',
    );
  }
  
  /// 请求联系人权限（多人记账功能）
  Future<bool> requestContactsPermission() async {
    return await _requestPermission(
      Permission.contacts,
      '联系人权限',
      '需要联系人权限来添加共同记账用户',
    );
  }
  
  /// 请求日历权限（预算提醒功能）
  Future<bool> requestCalendarPermission() async {
    return await _requestPermission(
      Permission.calendar,
      '日历权限',
      '需要日历权限来设置预算提醒',
    );
  }
  
  /// 请求生物识别权限
  Future<bool> requestBiometricPermission() async {
    // 生物识别权限通常不需要显式请求，但需要检查可用性
    try {
      // 这里可以集成 local_auth 包来检查生物识别可用性
      _logger.info('检查生物识别权限');
      return true; // 暂时返回true，实际实现需要集成相关包
    } catch (e) {
      _logger.error('检查生物识别权限失败', e);
      return false;
    }
  }
  
  /// 通用权限请求方法
  Future<bool> _requestPermission(
    Permission permission,
    String permissionName,
    String reason,
  ) async {
    try {
      _logger.info('请求$permissionName');
      
      // 检查当前权限状态
      final status = await permission.status;
      
      if (status.isGranted) {
        _logger.info('$permissionName已授权');
        return true;
      }
      
      if (status.isDenied) {
        // 请求权限
        final result = await permission.request();
        
        if (result.isGranted) {
          _logger.info('$permissionName授权成功');
          return true;
        } else if (result.isPermanentlyDenied) {
          _logger.warning('$permissionName被永久拒绝');
          await _showPermissionDeniedDialog(permissionName, reason);
          return false;
        } else {
          _logger.warning('$permissionName被拒绝');
          return false;
        }
      }
      
      if (status.isPermanentlyDenied) {
        _logger.warning('$permissionName已被永久拒绝');
        await _showPermissionDeniedDialog(permissionName, reason);
        return false;
      }
      
      return false;
    } catch (e) {
      _logger.error('请求$permissionName失败', e);
      return false;
    }
  }
  
  /// 显示权限被拒绝的对话框
  Future<void> _showPermissionDeniedDialog(
    String permissionName,
    String reason,
  ) async {
    // 这里需要使用NavigationService来显示对话框
    // 暂时使用日志记录，实际实现时需要显示用户友好的对话框
    _logger.warning('需要显示权限被拒绝的对话框: $permissionName - $reason');
  }
  
  /// 检查权限状态
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    try {
      return await permission.status;
    } catch (e) {
      _logger.error('检查权限状态失败', e);
      return PermissionStatus.denied;
    }
  }
  
  /// 检查多个权限状态
  Future<Map<Permission, PermissionStatus>> checkMultiplePermissions(
    List<Permission> permissions,
  ) async {
    try {
      return await permissions.request();
    } catch (e) {
      _logger.error('检查多个权限状态失败', e);
      return {};
    }
  }
  
  /// 打开应用设置页面
  Future<bool> openAppSettings() async {
    try {
      _logger.info('打开应用设置页面');
      return await openAppSettings();
    } catch (e) {
      _logger.error('打开应用设置页面失败', e);
      return false;
    }
  }
  
  /// 检查是否有基础权限（应用启动时需要的权限）
  Future<bool> hasBasicPermissions() async {
    final permissions = [
      Permission.storage,
      Permission.notification,
    ];
    
    for (final permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        return false;
      }
    }
    
    return true;
  }
  
  /// 请求基础权限
  Future<bool> requestBasicPermissions() async {
    _logger.info('请求基础权限');
    
    final storageGranted = await requestStoragePermission();
    final notificationGranted = await requestNotificationPermission();
    
    final allGranted = storageGranted && notificationGranted;
    
    if (allGranted) {
      _logger.info('基础权限全部授权成功');
    } else {
      _logger.warning('部分基础权限未授权');
    }
    
    return allGranted;
  }
  
  /// 检查是否有相机相关权限（拍照记账功能）
  Future<bool> hasCameraPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final storageStatus = await Permission.storage.status;
    
    return cameraStatus.isGranted && storageStatus.isGranted;
  }
  
  /// 请求相机相关权限
  Future<bool> requestCameraPermissions() async {
    _logger.info('请求相机相关权限');
    
    final cameraGranted = await requestCameraPermission();
    final storageGranted = await requestStoragePermission();
    
    return cameraGranted && storageGranted;
  }
  
  /// 检查是否有语音相关权限（语音记账功能）
  Future<bool> hasVoicePermissions() async {
    final microphoneStatus = await Permission.microphone.status;
    final storageStatus = await Permission.storage.status;
    
    return microphoneStatus.isGranted && storageStatus.isGranted;
  }
  
  /// 请求语音相关权限
  Future<bool> requestVoicePermissions() async {
    _logger.info('请求语音相关权限');
    
    final microphoneGranted = await requestMicrophonePermission();
    final storageGranted = await requestStoragePermission();
    
    return microphoneGranted && storageGranted;
  }
  
  /// 权限状态描述
  String getPermissionStatusDescription(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return '已授权';
      case PermissionStatus.denied:
        return '已拒绝';
      case PermissionStatus.restricted:
        return '受限制';
      case PermissionStatus.limited:
        return '有限授权';
      case PermissionStatus.permanentlyDenied:
        return '永久拒绝';
      case PermissionStatus.provisional:
        return '临时授权';
    }
  }
  
  /// 获取权限名称
  String getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return '相机';
      case Permission.photos:
        return '相册';
      case Permission.storage:
        return '存储';
      case Permission.microphone:
        return '麦克风';
      case Permission.notification:
        return '通知';
      case Permission.location:
        return '位置';
      case Permission.contacts:
        return '联系人';
      case Permission.calendar:
        return '日历';
      default:
        return '未知权限';
    }
  }
}

/// 权限状态枚举扩展
extension PermissionStatusExtension on PermissionStatus {
  /// 是否可以使用
  bool get canUse => isGranted || isLimited;
  
  /// 是否需要请求
  bool get needsRequest => isDenied;
  
  /// 是否需要打开设置
  bool get needsSettings => isPermanentlyDenied;
}