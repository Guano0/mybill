import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../utils/logger.dart';
import '../constants/app_constants.dart';

/// 通知服务
/// 提供本地通知功能，支持定时提醒、预算警告等
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();
  
  bool _isInitialized = false;
  
  /// 初始化通知服务
  Future<bool> init() async {
    if (_isInitialized) return true;
    
    try {
      _logger.info('初始化通知服务');
      
      // 初始化时区
      tz.initializeTimeZones();
      
      // Android初始化设置
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS初始化设置
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      // 初始化设置
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      // 初始化插件
      final result = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      if (result == true) {
        _isInitialized = true;
        _logger.info('通知服务初始化成功');
        
        // 请求权限
        await _requestPermissions();
        
        return true;
      } else {
        _logger.error('通知服务初始化失败');
        return false;
      }
    } catch (e) {
      _logger.error('通知服务初始化异常', e);
      return false;
    }
  }
  
  /// 请求通知权限
  Future<bool> _requestPermissions() async {
    try {
      // Android 13+ 需要请求通知权限
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        _logger.info('Android通知权限: $granted');
      }
      
      // iOS权限请求
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        _logger.info('iOS通知权限: $granted');
      }
      
      return true;
    } catch (e) {
      _logger.error('请求通知权限失败', e);
      return false;
    }
  }
  
  /// 显示即时通知
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationPriority priority = NotificationPriority.defaultPriority,
  }) async {
    if (!_isInitialized) {
      await init();
    }
    
    try {
      final androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: _getAndroidImportance(priority),
        priority: _getAndroidPriority(priority),
        showWhen: true,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _notifications.show(id, title, body, details, payload: payload);
      
      _logger.info('显示通知: $title');
    } catch (e) {
      _logger.error('显示通知失败', e);
    }
  }
  
  /// 显示定时通知
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationPriority priority = NotificationPriority.defaultPriority,
  }) async {
    if (!_isInitialized) {
      await init();
    }
    
    try {
      final androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: _getAndroidImportance(priority),
        priority: _getAndroidPriority(priority),
        showWhen: true,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      _logger.info('定时通知已设置: $title, 时间: $scheduledDate');
    } catch (e) {
      _logger.error('设置定时通知失败', e);
    }
  }
  
  /// 显示重复通知
  Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval repeatInterval,
    String? payload,
    NotificationPriority priority = NotificationPriority.defaultPriority,
  }) async {
    if (!_isInitialized) {
      await init();
    }
    
    try {
      final androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: _getAndroidImportance(priority),
        priority: _getAndroidPriority(priority),
        showWhen: true,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _notifications.periodicallyShow(
        id,
        title,
        body,
        repeatInterval,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      
      _logger.info('重复通知已设置: $title, 间隔: $repeatInterval');
    } catch (e) {
      _logger.error('设置重复通知失败', e);
    }
  }
  
  /// 取消通知
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      _logger.info('取消通知: $id');
    } catch (e) {
      _logger.error('取消通知失败', e);
    }
  }
  
  /// 取消所有通知
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      _logger.info('取消所有通知');
    } catch (e) {
      _logger.error('取消所有通知失败', e);
    }
  }
  
  /// 获取待处理的通知
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      _logger.error('获取待处理通知失败', e);
      return [];
    }
  }
  
  /// 显示记账提醒
  Future<void> showAccountingReminder() async {
    await showNotification(
      id: NotificationIds.accountingReminder,
      title: '记账提醒',
      body: '别忘了记录今天的收支哦！',
      priority: NotificationPriority.defaultPriority,
    );
  }
  
  /// 显示预算警告
  Future<void> showBudgetWarning(String category, double spent, double budget) async {
    final percentage = (spent / budget * 100).toInt();
    await showNotification(
      id: NotificationIds.budgetWarning,
      title: '预算警告',
      body: '$category 已花费 $percentage% 的预算（¥$spent/¥$budget）',
      priority: NotificationPriority.high,
    );
  }
  
  /// 显示预算超支警告
  Future<void> showBudgetExceeded(String category, double spent, double budget) async {
    final exceeded = spent - budget;
    await showNotification(
      id: NotificationIds.budgetExceeded,
      title: '预算超支！',
      body: '$category 已超支 ¥$exceeded（¥$spent/¥$budget）',
      priority: NotificationPriority.max,
    );
  }
  
  /// 显示同步完成通知
  Future<void> showSyncCompleted() async {
    await showNotification(
      id: NotificationIds.syncCompleted,
      title: '同步完成',
      body: '数据同步已完成',
      priority: NotificationPriority.low,
    );
  }
  
  /// 显示同步失败通知
  Future<void> showSyncFailed(String error) async {
    await showNotification(
      id: NotificationIds.syncFailed,
      title: '同步失败',
      body: '数据同步失败：$error',
      priority: NotificationPriority.high,
    );
  }
  
  /// 设置每日记账提醒
  Future<void> setDailyAccountingReminder(int hour, int minute) async {
    // 取消现有提醒
    await cancelNotification(NotificationIds.dailyReminder);
    
    // 计算下次提醒时间
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    // 如果时间已过，设置为明天
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    await scheduleRepeatingNotification(
      id: NotificationIds.dailyReminder,
      title: '记账提醒',
      body: '记得记录今天的收支情况哦！',
      repeatInterval: RepeatInterval.daily,
      priority: NotificationPriority.defaultPriority,
    );
  }
  
  /// 设置每周预算检查提醒
  Future<void> setWeeklyBudgetCheck() async {
    await scheduleRepeatingNotification(
      id: NotificationIds.weeklyBudgetCheck,
      title: '预算检查',
      body: '查看本周的预算使用情况',
      repeatInterval: RepeatInterval.weekly,
      priority: NotificationPriority.defaultPriority,
    );
  }
  
  /// 设置每月账单提醒
  Future<void> setMonthlyBillReminder() async {
    await scheduleRepeatingNotification(
      id: NotificationIds.monthlyBillReminder,
      title: '账单提醒',
      body: '查看本月的收支总结',
      repeatInterval: RepeatInterval.monthly,
      priority: NotificationPriority.defaultPriority,
    );
  }
  
  /// 通知点击处理
  void _onNotificationTapped(NotificationResponse response) {
    _logger.info('通知被点击: ${response.payload}');
    
    // 根据payload处理不同的通知点击事件
    if (response.payload != null) {
      _handleNotificationPayload(response.payload!);
    }
  }
  
  /// 处理通知载荷
  void _handleNotificationPayload(String payload) {
    try {
      // 这里可以根据payload导航到不同页面
      // 例如：预算警告 -> 预算页面，记账提醒 -> 添加交易页面
      _logger.info('处理通知载荷: $payload');
    } catch (e) {
      _logger.error('处理通知载荷失败', e);
    }
  }
  
  /// 获取Android重要性级别
  Importance _getAndroidImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.min:
        return Importance.min;
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.defaultPriority:
        return Importance.defaultImportance;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.max:
        return Importance.max;
    }
  }
  
  /// 获取Android优先级
  Priority _getAndroidPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.min:
        return Priority.min;
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.defaultPriority:
        return Priority.defaultPriority;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.max:
        return Priority.max;
    }
  }
}

/// 通知优先级
enum NotificationPriority {
  min,
  low,
  defaultPriority,
  high,
  max,
}

/// 通知ID常量
class NotificationIds {
  static const int accountingReminder = 1001;
  static const int budgetWarning = 1002;
  static const int budgetExceeded = 1003;
  static const int syncCompleted = 1004;
  static const int syncFailed = 1005;
  static const int dailyReminder = 1006;
  static const int weeklyBudgetCheck = 1007;
  static const int monthlyBillReminder = 1008;
}