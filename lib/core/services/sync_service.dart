import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../network/api_client.dart';
import '../storage/secure_storage.dart';
import '../utils/logger.dart';
import '../constants/app_constants.dart';

/// 数据同步服务
/// 负责本地数据与服务器数据的同步
class SyncService {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;
  final Logger _logger;
  final Connectivity _connectivity = Connectivity();
  
  SyncService({
    required ApiClient apiClient,
    required SecureStorage secureStorage,
    required Logger logger,
  }) : _apiClient = apiClient,
       _secureStorage = secureStorage,
       _logger = logger;
  
  /// 同步状态流控制器
  final StreamController<SyncStatus> _syncStatusController = StreamController<SyncStatus>.broadcast();
  
  /// 同步状态流
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  
  /// 当前同步状态
  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;
  
  /// 是否正在同步
  bool get isSyncing => _currentStatus == SyncStatus.syncing;
  
  /// 自动同步定时器
  Timer? _autoSyncTimer;
  
  /// 初始化同步服务
  Future<void> init() async {
    _logger.info('初始化同步服务');
    
    // 监听网络状态变化
    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    
    // 启动自动同步
    await _startAutoSync();
  }
  
  /// 执行完整同步
  Future<SyncResult> performFullSync() async {
    if (isSyncing) {
      _logger.warning('同步正在进行中，跳过本次同步');
      return SyncResult.skipped('同步正在进行中');
    }
    
    _updateSyncStatus(SyncStatus.syncing);
    
    try {
      _logger.info('开始完整同步');
      
      // 检查网络连接
      if (!await _isNetworkAvailable()) {
        throw SyncException('网络连接不可用');
      }
      
      // 检查用户认证
      if (!await _isUserAuthenticated()) {
        throw SyncException('用户未认证');
      }
      
      final result = SyncResult();
      
      // 1. 上传本地待同步数据
      await _uploadPendingData(result);
      
      // 2. 下载服务器数据
      await _downloadServerData(result);
      
      // 3. 解决冲突
      await _resolveConflicts(result);
      
      // 4. 更新同步时间戳
      await _updateLastSyncTime();
      
      _updateSyncStatus(SyncStatus.completed);
      _logger.info('完整同步完成: ${result.toString()}');
      
      return result;
    } catch (e) {
      _updateSyncStatus(SyncStatus.failed);
      _logger.error('完整同步失败', e);
      return SyncResult.failed(e.toString());
    }
  }
  
  /// 执行增量同步
  Future<SyncResult> performIncrementalSync() async {
    if (isSyncing) {
      _logger.warning('同步正在进行中，跳过本次同步');
      return SyncResult.skipped('同步正在进行中');
    }
    
    _updateSyncStatus(SyncStatus.syncing);
    
    try {
      _logger.info('开始增量同步');
      
      // 检查网络连接
      if (!await _isNetworkAvailable()) {
        throw SyncException('网络连接不可用');
      }
      
      // 检查用户认证
      if (!await _isUserAuthenticated()) {
        throw SyncException('用户未认证');
      }
      
      final lastSyncTime = await _getLastSyncTime();
      final result = SyncResult();
      
      // 1. 上传本地变更
      await _uploadChangedData(lastSyncTime, result);
      
      // 2. 下载服务器变更
      await _downloadChangedData(lastSyncTime, result);
      
      // 3. 解决冲突
      await _resolveConflicts(result);
      
      // 4. 更新同步时间戳
      await _updateLastSyncTime();
      
      _updateSyncStatus(SyncStatus.completed);
      _logger.info('增量同步完成: ${result.toString()}');
      
      return result;
    } catch (e) {
      _updateSyncStatus(SyncStatus.failed);
      _logger.error('增量同步失败', e);
      return SyncResult.failed(e.toString());
    }
  }
  
  /// 强制同步（忽略冲突，以服务器数据为准）
  Future<SyncResult> performForceSync() async {
    _updateSyncStatus(SyncStatus.syncing);
    
    try {
      _logger.info('开始强制同步');
      
      // 检查网络连接
      if (!await _isNetworkAvailable()) {
        throw SyncException('网络连接不可用');
      }
      
      // 检查用户认证
      if (!await _isUserAuthenticated()) {
        throw SyncException('用户未认证');
      }
      
      final result = SyncResult();
      
      // 1. 备份本地数据
      await _backupLocalData();
      
      // 2. 清除本地数据
      await _clearLocalData();
      
      // 3. 下载所有服务器数据
      await _downloadAllServerData(result);
      
      // 4. 更新同步时间戳
      await _updateLastSyncTime();
      
      _updateSyncStatus(SyncStatus.completed);
      _logger.info('强制同步完成: ${result.toString()}');
      
      return result;
    } catch (e) {
      _updateSyncStatus(SyncStatus.failed);
      _logger.error('强制同步失败', e);
      
      // 尝试恢复本地数据
      await _restoreLocalData();
      
      return SyncResult.failed(e.toString());
    }
  }
  
  /// 上传待同步数据
  Future<void> _uploadPendingData(SyncResult result) async {
    _logger.info('上传待同步数据');
    
    // 获取待上传的交易记录
    final pendingTransactions = await _getPendingTransactions();
    for (final transaction in pendingTransactions) {
      try {
        await _apiClient.post('/transactions', data: transaction.toJson());
        await _markTransactionAsSynced(transaction.id);
        result.uploadedTransactions++;
      } catch (e) {
        _logger.error('上传交易记录失败: ${transaction.id}', e);
        result.failedUploads++;
      }
    }
    
    // 获取待上传的分类
    final pendingCategories = await _getPendingCategories();
    for (final category in pendingCategories) {
      try {
        await _apiClient.post('/categories', data: category.toJson());
        await _markCategoryAsSynced(category.id);
        result.uploadedCategories++;
      } catch (e) {
        _logger.error('上传分类失败: ${category.id}', e);
        result.failedUploads++;
      }
    }
  }
  
  /// 下载服务器数据
  Future<void> _downloadServerData(SyncResult result) async {
    _logger.info('下载服务器数据');
    
    try {
      // 下载交易记录
      final transactionsResponse = await _apiClient.get('/transactions');
      final transactions = transactionsResponse.data['data'] as List;
      for (final transactionData in transactions) {
        await _saveTransaction(transactionData);
        result.downloadedTransactions++;
      }
      
      // 下载分类
      final categoriesResponse = await _apiClient.get('/categories');
      final categories = categoriesResponse.data['data'] as List;
      for (final categoryData in categories) {
        await _saveCategory(categoryData);
        result.downloadedCategories++;
      }
    } catch (e) {
      _logger.error('下载服务器数据失败', e);
      rethrow;
    }
  }
  
  /// 上传变更数据
  Future<void> _uploadChangedData(DateTime? lastSyncTime, SyncResult result) async {
    _logger.info('上传变更数据，上次同步时间: $lastSyncTime');
    
    // 获取自上次同步后变更的数据
    final changedTransactions = await _getChangedTransactions(lastSyncTime);
    for (final transaction in changedTransactions) {
      try {
        if (transaction.isNew) {
          await _apiClient.post('/transactions', data: transaction.toJson());
        } else {
          await _apiClient.put('/transactions/${transaction.id}', data: transaction.toJson());
        }
        await _markTransactionAsSynced(transaction.id);
        result.uploadedTransactions++;
      } catch (e) {
        _logger.error('上传变更交易记录失败: ${transaction.id}', e);
        result.failedUploads++;
      }
    }
  }
  
  /// 下载变更数据
  Future<void> _downloadChangedData(DateTime? lastSyncTime, SyncResult result) async {
    _logger.info('下载变更数据，上次同步时间: $lastSyncTime');
    
    try {
      final params = lastSyncTime != null 
          ? {'since': lastSyncTime.toIso8601String()}
          : null;
      
      // 下载变更的交易记录
      final transactionsResponse = await _apiClient.get('/transactions/changes', queryParameters: params);
      final transactions = transactionsResponse.data['data'] as List;
      for (final transactionData in transactions) {
        await _saveTransaction(transactionData);
        result.downloadedTransactions++;
      }
    } catch (e) {
      _logger.error('下载变更数据失败', e);
      rethrow;
    }
  }
  
  /// 解决冲突
  Future<void> _resolveConflicts(SyncResult result) async {
    _logger.info('解决数据冲突');
    
    // 获取冲突的数据
    final conflicts = await _getConflicts();
    
    for (final conflict in conflicts) {
      try {
        // 默认策略：服务器数据优先
        await _resolveConflict(conflict, ConflictResolution.serverWins);
        result.resolvedConflicts++;
      } catch (e) {
        _logger.error('解决冲突失败: ${conflict.id}', e);
        result.unresolvedConflicts++;
      }
    }
  }
  
  /// 检查网络可用性
  Future<bool> _isNetworkAvailable() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      _logger.error('检查网络连接失败', e);
      return false;
    }
  }
  
  /// 检查用户认证状态
  Future<bool> _isUserAuthenticated() async {
    try {
      final token = await _secureStorage.getAuthToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      _logger.error('检查用户认证状态失败', e);
      return false;
    }
  }
  
  /// 获取上次同步时间
  Future<DateTime?> _getLastSyncTime() async {
    try {
      final timeString = await _secureStorage.getString('last_sync_time');
      if (timeString != null) {
        return DateTime.parse(timeString);
      }
      return null;
    } catch (e) {
      _logger.error('获取上次同步时间失败', e);
      return null;
    }
  }
  
  /// 更新同步时间
  Future<void> _updateLastSyncTime() async {
    try {
      final now = DateTime.now();
      await _secureStorage.setString('last_sync_time', now.toIso8601String());
    } catch (e) {
      _logger.error('更新同步时间失败', e);
    }
  }
  
  /// 更新同步状态
  void _updateSyncStatus(SyncStatus status) {
    _currentStatus = status;
    _syncStatusController.add(status);
  }
  
  /// 网络连接状态变化处理
  void _onConnectivityChanged(ConnectivityResult result) {
    _logger.info('网络连接状态变化: $result');
    
    if (result != ConnectivityResult.none) {
      // 网络恢复，执行自动同步
      _performAutoSync();
    }
  }
  
  /// 启动自动同步
  Future<void> _startAutoSync() async {
    final autoSyncEnabled = await _secureStorage.getAutoSyncEnabled();
    if (!autoSyncEnabled) {
      _logger.info('自动同步已禁用');
      return;
    }
    
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(
      const Duration(minutes: AppConstants.autoSyncIntervalMinutes),
      (_) => _performAutoSync(),
    );
    
    _logger.info('自动同步已启动，间隔: ${AppConstants.autoSyncIntervalMinutes}分钟');
  }
  
  /// 执行自动同步
  Future<void> _performAutoSync() async {
    if (!await _isNetworkAvailable()) {
      _logger.info('网络不可用，跳过自动同步');
      return;
    }
    
    if (!await _isUserAuthenticated()) {
      _logger.info('用户未认证，跳过自动同步');
      return;
    }
    
    _logger.info('执行自动同步');
    await performIncrementalSync();
  }
  
  /// 停止自动同步
  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    _logger.info('自动同步已停止');
  }
  
  /// 释放资源
  void dispose() {
    stopAutoSync();
    _syncStatusController.close();
  }
  
  // 以下方法需要根据实际的数据模型和数据库实现
  Future<List<dynamic>> _getPendingTransactions() async {
    // TODO: 实现获取待同步交易记录
    return [];
  }
  
  Future<List<dynamic>> _getPendingCategories() async {
    // TODO: 实现获取待同步分类
    return [];
  }
  
  Future<void> _markTransactionAsSynced(String id) async {
    // TODO: 实现标记交易记录为已同步
  }
  
  Future<void> _markCategoryAsSynced(String id) async {
    // TODO: 实现标记分类为已同步
  }
  
  Future<void> _saveTransaction(Map<String, dynamic> data) async {
    // TODO: 实现保存交易记录
  }
  
  Future<void> _saveCategory(Map<String, dynamic> data) async {
    // TODO: 实现保存分类
  }
  
  Future<List<dynamic>> _getChangedTransactions(DateTime? since) async {
    // TODO: 实现获取变更的交易记录
    return [];
  }
  
  Future<List<dynamic>> _getConflicts() async {
    // TODO: 实现获取冲突数据
    return [];
  }
  
  Future<void> _resolveConflict(dynamic conflict, ConflictResolution resolution) async {
    // TODO: 实现冲突解决
  }
  
  Future<void> _backupLocalData() async {
    // TODO: 实现本地数据备份
  }
  
  Future<void> _clearLocalData() async {
    // TODO: 实现清除本地数据
  }
  
  Future<void> _downloadAllServerData(SyncResult result) async {
    // TODO: 实现下载所有服务器数据
  }
  
  Future<void> _restoreLocalData() async {
    // TODO: 实现恢复本地数据
  }
}

/// 同步状态
enum SyncStatus {
  idle,
  syncing,
  completed,
  failed,
}

/// 冲突解决策略
enum ConflictResolution {
  serverWins,
  clientWins,
  merge,
  manual,
}

/// 同步结果
class SyncResult {
  int uploadedTransactions = 0;
  int uploadedCategories = 0;
  int downloadedTransactions = 0;
  int downloadedCategories = 0;
  int resolvedConflicts = 0;
  int unresolvedConflicts = 0;
  int failedUploads = 0;
  int failedDownloads = 0;
  String? errorMessage;
  bool success = true;
  
  SyncResult();
  
  SyncResult.failed(this.errorMessage) : success = false;
  
  SyncResult.skipped(this.errorMessage) : success = false;
  
  @override
  String toString() {
    return 'SyncResult(success: $success, uploaded: ${uploadedTransactions + uploadedCategories}, downloaded: ${downloadedTransactions + downloadedCategories}, conflicts: $resolvedConflicts/$unresolvedConflicts, errors: ${failedUploads + failedDownloads})';
  }
}

/// 同步异常
class SyncException implements Exception {
  final String message;
  final dynamic originalError;
  
  const SyncException(this.message, [this.originalError]);
  
  @override
  String toString() {
    return 'SyncException: $message${originalError != null ? ' (原因: $originalError)' : ''}';
  }
}