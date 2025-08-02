import 'package:flutter/material.dart';

/// 导航服务
/// 提供全局导航功能，支持无Context导航
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();
  
  /// 全局导航键
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  /// 获取当前上下文
  BuildContext? get currentContext => navigatorKey.currentContext;
  
  /// 获取当前导航器状态
  NavigatorState? get currentState => navigatorKey.currentState;
  
  /// 导航到指定路由
  Future<T?> navigateTo<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return currentState!.pushNamed<T>(routeName, arguments: arguments);
  }
  
  /// 替换当前路由
  Future<T?> navigateToReplacement<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return currentState!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }
  
  /// 清除所有路由并导航到指定路由
  Future<T?> navigateToAndClearStack<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
  
  /// 返回上一页
  void goBack<T extends Object?>([T? result]) {
    if (canGoBack()) {
      currentState!.pop<T>(result);
    }
  }
  
  /// 返回到指定路由
  void goBackTo(String routeName) {
    currentState!.popUntil(ModalRoute.withName(routeName));
  }
  
  /// 返回到根路由
  void goBackToRoot() {
    currentState!.popUntil((route) => route.isFirst);
  }
  
  /// 检查是否可以返回
  bool canGoBack() {
    return currentState?.canPop() ?? false;
  }
  
  /// 显示对话框
  Future<T?> showDialogWidget<T>(Widget dialog) {
    return showDialog<T>(
      context: currentContext!,
      builder: (context) => dialog,
    );
  }
  
  /// 显示底部弹窗
  Future<T?> showBottomSheetWidget<T>(Widget bottomSheet) {
    return showModalBottomSheet<T>(
      context: currentContext!,
      builder: (context) => bottomSheet,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
  
  /// 显示确认对话框
  Future<bool?> showConfirmDialog({
    required String title,
    required String content,
    String confirmText = '确认',
    String cancelText = '取消',
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: currentContext!,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
  
  /// 显示加载对话框
  void showLoadingDialog({String? message}) {
    showDialog(
      context: currentContext!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message ?? '加载中...'),
          ],
        ),
      ),
    );
  }
  
  /// 隐藏加载对话框
  void hideLoadingDialog() {
    if (canGoBack()) {
      goBack();
    }
  }
  
  /// 显示SnackBar
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    SnackBarAction? action,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(currentContext!);
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: backgroundColor,
        action: action,
      ),
    );
  }
  
  /// 显示成功消息
  void showSuccessMessage(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.green,
    );
  }
  
  /// 显示错误消息
  void showErrorMessage(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.red,
    );
  }
  
  /// 显示警告消息
  void showWarningMessage(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.orange,
    );
  }
  
  /// 显示信息消息
  void showInfoMessage(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.blue,
    );
  }
  
  /// 获取当前路由名称
  String? get currentRouteName {
    String? routeName;
    currentState?.popUntil((route) {
      routeName = route.settings.name;
      return true;
    });
    return routeName;
  }
  
  /// 检查当前是否在指定路由
  bool isCurrentRoute(String routeName) {
    return currentRouteName == routeName;
  }
  
  /// 路由历史记录
  final List<String> _routeHistory = [];
  
  /// 添加路由到历史记录
  void addToHistory(String routeName) {
    _routeHistory.add(routeName);
    // 限制历史记录长度
    if (_routeHistory.length > 50) {
      _routeHistory.removeAt(0);
    }
  }
  
  /// 获取路由历史记录
  List<String> get routeHistory => List.unmodifiable(_routeHistory);
  
  /// 清除路由历史记录
  void clearHistory() {
    _routeHistory.clear();
  }
  
  /// 获取上一个路由名称
  String? get previousRouteName {
    if (_routeHistory.length >= 2) {
      return _routeHistory[_routeHistory.length - 2];
    }
    return null;
  }
}

/// 路由观察者
/// 用于监听路由变化，记录路由历史
class AppRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final NavigationService _navigationService = NavigationService();
  
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      _navigationService.addToHistory(route.settings.name!);
    }
  }
  
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute?.settings.name != null) {
      _navigationService.addToHistory(newRoute!.settings.name!);
    }
  }
}