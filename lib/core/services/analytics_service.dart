import 'dart:convert';
import 'dart:math';
import '../storage/secure_storage.dart';
import '../utils/logger.dart';
import '../constants/app_constants.dart';

/// 数据分析服务
/// 提供用户行为分析、财务数据分析等功能
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();
  
  final Logger _logger = Logger();
  final SecureStorage _storage = SecureStorage();
  
  bool _isInitialized = false;
  
  /// 是否已初始化
  bool get isInitialized => _isInitialized;
  
  /// 初始化分析服务
  Future<bool> init() async {
    if (_isInitialized) return true;
    
    try {
      _logger.info('初始化分析服务');
      
      // 初始化用户行为追踪
      await _initUserBehaviorTracking();
      
      // 初始化财务分析
      await _initFinancialAnalysis();
      
      _isInitialized = true;
      _logger.info('分析服务初始化成功');
      return true;
    } catch (e) {
      _logger.error('分析服务初始化失败', e);
      return false;
    }
  }
  
  /// 初始化用户行为追踪
  Future<void> _initUserBehaviorTracking() async {
    // 检查是否首次启动
    final isFirstLaunch = await _storage.isFirstLaunch();
    if (isFirstLaunch) {
      await trackEvent(AnalyticsEvent.appFirstLaunch);
      await _storage.setFirstLaunch(false);
    }
    
    // 记录应用启动
    await trackEvent(AnalyticsEvent.appLaunch);
  }
  
  /// 初始化财务分析
  Future<void> _initFinancialAnalysis() async {
    // 预加载分析数据
    await _loadAnalyticsData();
  }
  
  /// 追踪事件
  Future<void> trackEvent(
    AnalyticsEvent event, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final eventData = {
        'event': event.name,
        'timestamp': DateTime.now().toIso8601String(),
        'parameters': parameters ?? {},
      };
      
      // 保存到本地
      await _saveEventToLocal(eventData);
      
      // 记录日志
      _logger.analytics('事件追踪', {
        'event': event.name,
        'parameters': parameters,
      });
      
      // 如果有网络连接，发送到服务器
      // TODO: 实现服务器端分析
      
    } catch (e) {
      _logger.error('事件追踪失败', e);
    }
  }
  
  /// 追踪用户行为
  Future<void> trackUserAction(
    String action, {
    String? screen,
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent(
      AnalyticsEvent.userAction,
      parameters: {
        'action': action,
        'screen': screen,
        'properties': properties ?? {},
      },
    );
  }
  
  /// 追踪页面访问
  Future<void> trackPageView(
    String pageName, {
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent(
      AnalyticsEvent.pageView,
      parameters: {
        'page_name': pageName,
        'properties': properties ?? {},
      },
    );
  }
  
  /// 追踪交易记录
  Future<void> trackTransaction(
    String type,
    double amount,
    String category, {
    String? description,
    String? inputMethod,
  }) async {
    await trackEvent(
      AnalyticsEvent.transactionCreated,
      parameters: {
        'type': type,
        'amount': amount,
        'category': category,
        'description': description,
        'input_method': inputMethod,
      },
    );
  }
  
  /// 追踪错误
  Future<void> trackError(
    String error,
    String? stackTrace, {
    String? screen,
    Map<String, dynamic>? context,
  }) async {
    await trackEvent(
      AnalyticsEvent.error,
      parameters: {
        'error': error,
        'stack_trace': stackTrace,
        'screen': screen,
        'context': context ?? {},
      },
    );
  }
  
  /// 追踪性能指标
  Future<void> trackPerformance(
    String metric,
    double value, {
    String? screen,
    Map<String, dynamic>? attributes,
  }) async {
    await trackEvent(
      AnalyticsEvent.performance,
      parameters: {
        'metric': metric,
        'value': value,
        'screen': screen,
        'attributes': attributes ?? {},
      },
    );
  }
  
  /// 获取用户行为统计
  Future<UserBehaviorStats> getUserBehaviorStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final events = await _getEventsInRange(startDate, endDate);
      
      return UserBehaviorStats(
        totalEvents: events.length,
        pageViews: _countEventsByType(events, AnalyticsEvent.pageView),
        userActions: _countEventsByType(events, AnalyticsEvent.userAction),
        transactions: _countEventsByType(events, AnalyticsEvent.transactionCreated),
        errors: _countEventsByType(events, AnalyticsEvent.error),
        sessionDuration: await _calculateSessionDuration(events),
        mostVisitedPages: await _getMostVisitedPages(events),
        mostUsedFeatures: await _getMostUsedFeatures(events),
      );
    } catch (e) {
      _logger.error('获取用户行为统计失败', e);
      return UserBehaviorStats.empty();
    }
  }
  
  /// 获取财务分析报告
  Future<FinancialAnalysisReport> getFinancialAnalysis({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final events = await _getEventsInRange(startDate, endDate);
      final transactionEvents = events
          .where((e) => e['event'] == AnalyticsEvent.transactionCreated.name)
          .toList();
      
      return FinancialAnalysisReport(
        totalTransactions: transactionEvents.length,
        totalIncome: _calculateTotalByType(transactionEvents, 'income'),
        totalExpense: _calculateTotalByType(transactionEvents, 'expense'),
        averageTransactionAmount: _calculateAverageAmount(transactionEvents),
        categoryDistribution: _getCategoryDistribution(transactionEvents),
        monthlyTrend: await _getMonthlyTrend(transactionEvents),
        inputMethodStats: _getInputMethodStats(transactionEvents),
        spendingPatterns: await _getSpendingPatterns(transactionEvents),
      );
    } catch (e) {
      _logger.error('获取财务分析报告失败', e);
      return FinancialAnalysisReport.empty();
    }
  }
  
  /// 获取应用使用统计
  Future<AppUsageStats> getAppUsageStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final events = await _getEventsInRange(startDate, endDate);
      
      return AppUsageStats(
        totalSessions: _countEventsByType(events, AnalyticsEvent.appLaunch),
        averageSessionDuration: await _calculateAverageSessionDuration(events),
        dailyActiveUsers: await _getDailyActiveUsers(events),
        featureUsage: await _getFeatureUsage(events),
        crashRate: await _calculateCrashRate(events),
        retentionRate: await _calculateRetentionRate(events),
      );
    } catch (e) {
      _logger.error('获取应用使用统计失败', e);
      return AppUsageStats.empty();
    }
  }
  
  /// 保存事件到本地
  Future<void> _saveEventToLocal(Map<String, dynamic> eventData) async {
    try {
      final eventsJson = await _storage.getString(StorageKeys.analyticsEvents) ?? '[]';
      final events = List<Map<String, dynamic>>.from(json.decode(eventsJson));
      
      events.add(eventData);
      
      // 限制本地存储的事件数量
      if (events.length > AppConstants.maxLocalAnalyticsEvents) {
        events.removeRange(0, events.length - AppConstants.maxLocalAnalyticsEvents);
      }
      
      await _storage.setString(StorageKeys.analyticsEvents, json.encode(events));
    } catch (e) {
      _logger.error('保存分析事件失败', e);
    }
  }
  
  /// 加载分析数据
  Future<void> _loadAnalyticsData() async {
    try {
      // 预加载常用的分析数据
      await getUserBehaviorStats();
      await getFinancialAnalysis();
    } catch (e) {
      _logger.error('加载分析数据失败', e);
    }
  }
  
  /// 获取指定时间范围内的事件
  Future<List<Map<String, dynamic>>> _getEventsInRange(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    try {
      final eventsJson = await _storage.getString(StorageKeys.analyticsEvents) ?? '[]';
      final allEvents = List<Map<String, dynamic>>.from(json.decode(eventsJson));
      
      if (startDate == null && endDate == null) {
        return allEvents;
      }
      
      return allEvents.where((event) {
        final timestampStr = event['timestamp'] as String?;
        if (timestampStr == null) return false;
        
        final timestamp = DateTime.tryParse(timestampStr);
        if (timestamp == null) return false;
        
        if (startDate != null && timestamp.isBefore(startDate)) {
          return false;
        }
        
        if (endDate != null && timestamp.isAfter(endDate)) {
          return false;
        }
        
        return true;
      }).toList();
    } catch (e) {
      _logger.error('获取事件范围失败', e);
      return [];
    }
  }
  
  /// 统计指定类型的事件数量
  int _countEventsByType(List<Map<String, dynamic>> events, AnalyticsEvent eventType) {
    return events.where((e) => e['event'] == eventType.name).length;
  }
  
  /// 计算会话持续时间
  Future<Duration> _calculateSessionDuration(List<Map<String, dynamic>> events) async {
    // 简化实现：基于应用启动和关闭事件
    final launchEvents = events
        .where((e) => e['event'] == AnalyticsEvent.appLaunch.name)
        .toList();
    
    if (launchEvents.isEmpty) return Duration.zero;
    
    // 假设平均会话时长
    return Duration(minutes: 15 * launchEvents.length);
  }
  
  /// 获取最常访问的页面
  Future<Map<String, int>> _getMostVisitedPages(List<Map<String, dynamic>> events) async {
    final pageViews = events
        .where((e) => e['event'] == AnalyticsEvent.pageView.name)
        .toList();
    
    final pageCount = <String, int>{};
    for (final event in pageViews) {
      final parameters = event['parameters'] as Map<String, dynamic>? ?? {};
      final pageName = parameters['page_name'] as String? ?? 'unknown';
      pageCount[pageName] = (pageCount[pageName] ?? 0) + 1;
    }
    
    // 按访问次数排序
    final sortedEntries = pageCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sortedEntries.take(10));
  }
  
  /// 获取最常使用的功能
  Future<Map<String, int>> _getMostUsedFeatures(List<Map<String, dynamic>> events) async {
    final userActions = events
        .where((e) => e['event'] == AnalyticsEvent.userAction.name)
        .toList();
    
    final actionCount = <String, int>{};
    for (final event in userActions) {
      final parameters = event['parameters'] as Map<String, dynamic>? ?? {};
      final action = parameters['action'] as String? ?? 'unknown';
      actionCount[action] = (actionCount[action] ?? 0) + 1;
    }
    
    // 按使用次数排序
    final sortedEntries = actionCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sortedEntries.take(10));
  }
  
  /// 计算指定类型的总金额
  double _calculateTotalByType(List<Map<String, dynamic>> events, String type) {
    double total = 0.0;
    for (final event in events) {
      final parameters = event['parameters'] as Map<String, dynamic>? ?? {};
      if (parameters['type'] == type) {
        final amount = parameters['amount'] as num? ?? 0;
        total += amount.toDouble();
      }
    }
    return total;
  }
  
  /// 计算平均交易金额
  double _calculateAverageAmount(List<Map<String, dynamic>> events) {
    if (events.isEmpty) return 0.0;
    
    double total = 0.0;
    for (final event in events) {
      final parameters = event['parameters'] as Map<String, dynamic>? ?? {};
      final amount = parameters['amount'] as num? ?? 0;
      total += amount.toDouble();
    }
    
    return total / events.length;
  }
  
  /// 获取分类分布
  Map<String, double> _getCategoryDistribution(List<Map<String, dynamic>> events) {
    final categoryTotals = <String, double>{};
    
    for (final event in events) {
      final parameters = event['parameters'] as Map<String, dynamic>? ?? {};
      final category = parameters['category'] as String? ?? 'unknown';
      final amount = parameters['amount'] as num? ?? 0;
      
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount.toDouble();
    }
    
    return categoryTotals;
  }
  
  /// 获取月度趋势
  Future<Map<String, double>> _getMonthlyTrend(List<Map<String, dynamic>> events) async {
    final monthlyTotals = <String, double>{};
    
    for (final event in events) {
      final timestampStr = event['timestamp'] as String?;
      if (timestampStr == null) continue;
      
      final timestamp = DateTime.tryParse(timestampStr);
      if (timestamp == null) continue;
      
      final monthKey = '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}';
      final parameters = event['parameters'] as Map<String, dynamic>? ?? {};
      final amount = parameters['amount'] as num? ?? 0;
      
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + amount.toDouble();
    }
    
    return monthlyTotals;
  }
  
  /// 获取输入方式统计
  Map<String, int> _getInputMethodStats(List<Map<String, dynamic>> events) {
    final methodCount = <String, int>{};
    
    for (final event in events) {
      final parameters = event['parameters'] as Map<String, dynamic>? ?? {};
      final method = parameters['input_method'] as String? ?? 'manual';
      methodCount[method] = (methodCount[method] ?? 0) + 1;
    }
    
    return methodCount;
  }
  
  /// 获取消费模式
  Future<SpendingPatterns> _getSpendingPatterns(List<Map<String, dynamic>> events) async {
    // 简化实现
    return SpendingPatterns(
      peakSpendingHour: 14, // 下午2点
      peakSpendingDay: 6, // 周六
      averageDailySpending: _calculateAverageAmount(events),
      spendingFrequency: events.length / 30, // 假设30天
    );
  }
  
  /// 计算平均会话持续时间
  Future<Duration> _calculateAverageSessionDuration(List<Map<String, dynamic>> events) async {
    return await _calculateSessionDuration(events);
  }
  
  /// 获取日活跃用户
  Future<Map<String, int>> _getDailyActiveUsers(List<Map<String, dynamic>> events) async {
    final dailyUsers = <String, Set<String>>{};
    
    for (final event in events) {
      final timestampStr = event['timestamp'] as String?;
      if (timestampStr == null) continue;
      
      final timestamp = DateTime.tryParse(timestampStr);
      if (timestamp == null) continue;
      
      final dayKey = '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
      final userId = 'user_1'; // 简化实现，单用户
      
      dailyUsers.putIfAbsent(dayKey, () => <String>{}).add(userId);
    }
    
    return dailyUsers.map((key, value) => MapEntry(key, value.length));
  }
  
  /// 获取功能使用情况
  Future<Map<String, int>> _getFeatureUsage(List<Map<String, dynamic>> events) async {
    return await _getMostUsedFeatures(events);
  }
  
  /// 计算崩溃率
  Future<double> _calculateCrashRate(List<Map<String, dynamic>> events) async {
    final totalSessions = _countEventsByType(events, AnalyticsEvent.appLaunch);
    final crashes = _countEventsByType(events, AnalyticsEvent.error);
    
    if (totalSessions == 0) return 0.0;
    return crashes / totalSessions;
  }
  
  /// 计算留存率
  Future<double> _calculateRetentionRate(List<Map<String, dynamic>> events) async {
    // 简化实现：基于应用启动事件
    final launchEvents = events
        .where((e) => e['event'] == AnalyticsEvent.appLaunch.name)
        .toList();
    
    if (launchEvents.length < 2) return 0.0;
    
    // 假设用户在7天内再次使用应用表示留存
    return 0.75; // 75%留存率
  }
  
  /// 清理旧的分析数据
  Future<void> cleanupOldData({int daysToKeep = 90}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final events = await _getEventsInRange(cutoffDate, null);
      
      await _storage.setString(StorageKeys.analyticsEvents, json.encode(events));
      
      _logger.info('清理了 ${daysToKeep} 天前的分析数据');
    } catch (e) {
      _logger.error('清理分析数据失败', e);
    }
  }
  
  /// 导出分析数据
  Future<String> exportAnalyticsData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final events = await _getEventsInRange(startDate, endDate);
      return json.encode({
        'export_date': DateTime.now().toIso8601String(),
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'events': events,
      });
    } catch (e) {
      _logger.error('导出分析数据失败', e);
      rethrow;
    }
  }
}

/// 分析事件类型
enum AnalyticsEvent {
  appLaunch,
  appFirstLaunch,
  pageView,
  userAction,
  transactionCreated,
  transactionUpdated,
  transactionDeleted,
  categoryCreated,
  budgetCreated,
  reportGenerated,
  dataSync,
  voiceInput,
  ocrInput,
  biometricAuth,
  error,
  performance,
}

/// 用户行为统计
class UserBehaviorStats {
  final int totalEvents;
  final int pageViews;
  final int userActions;
  final int transactions;
  final int errors;
  final Duration sessionDuration;
  final Map<String, int> mostVisitedPages;
  final Map<String, int> mostUsedFeatures;
  
  UserBehaviorStats({
    required this.totalEvents,
    required this.pageViews,
    required this.userActions,
    required this.transactions,
    required this.errors,
    required this.sessionDuration,
    required this.mostVisitedPages,
    required this.mostUsedFeatures,
  });
  
  factory UserBehaviorStats.empty() {
    return UserBehaviorStats(
      totalEvents: 0,
      pageViews: 0,
      userActions: 0,
      transactions: 0,
      errors: 0,
      sessionDuration: Duration.zero,
      mostVisitedPages: {},
      mostUsedFeatures: {},
    );
  }
}

/// 财务分析报告
class FinancialAnalysisReport {
  final int totalTransactions;
  final double totalIncome;
  final double totalExpense;
  final double averageTransactionAmount;
  final Map<String, double> categoryDistribution;
  final Map<String, double> monthlyTrend;
  final Map<String, int> inputMethodStats;
  final SpendingPatterns spendingPatterns;
  
  FinancialAnalysisReport({
    required this.totalTransactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.averageTransactionAmount,
    required this.categoryDistribution,
    required this.monthlyTrend,
    required this.inputMethodStats,
    required this.spendingPatterns,
  });
  
  factory FinancialAnalysisReport.empty() {
    return FinancialAnalysisReport(
      totalTransactions: 0,
      totalIncome: 0.0,
      totalExpense: 0.0,
      averageTransactionAmount: 0.0,
      categoryDistribution: {},
      monthlyTrend: {},
      inputMethodStats: {},
      spendingPatterns: SpendingPatterns.empty(),
    );
  }
}

/// 应用使用统计
class AppUsageStats {
  final int totalSessions;
  final Duration averageSessionDuration;
  final Map<String, int> dailyActiveUsers;
  final Map<String, int> featureUsage;
  final double crashRate;
  final double retentionRate;
  
  AppUsageStats({
    required this.totalSessions,
    required this.averageSessionDuration,
    required this.dailyActiveUsers,
    required this.featureUsage,
    required this.crashRate,
    required this.retentionRate,
  });
  
  factory AppUsageStats.empty() {
    return AppUsageStats(
      totalSessions: 0,
      averageSessionDuration: Duration.zero,
      dailyActiveUsers: {},
      featureUsage: {},
      crashRate: 0.0,
      retentionRate: 0.0,
    );
  }
}

/// 消费模式
class SpendingPatterns {
  final int peakSpendingHour;
  final int peakSpendingDay;
  final double averageDailySpending;
  final double spendingFrequency;
  
  SpendingPatterns({
    required this.peakSpendingHour,
    required this.peakSpendingDay,
    required this.averageDailySpending,
    required this.spendingFrequency,
  });
  
  factory SpendingPatterns.empty() {
    return SpendingPatterns(
      peakSpendingHour: 0,
      peakSpendingDay: 0,
      averageDailySpending: 0.0,
      spendingFrequency: 0.0,
    );
  }
}