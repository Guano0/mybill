import 'dart:async';
import 'dart:io';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';
import '../constants/app_constants.dart';

/// 语音识别服务
/// 提供语音转文字功能，支持语音记账
class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();
  
  final SpeechToText _speechToText = SpeechToText();
  final Logger _logger = Logger();
  
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastRecognizedText = '';
  
  /// 语音识别结果流控制器
  final StreamController<VoiceRecognitionResult> _resultController = 
      StreamController<VoiceRecognitionResult>.broadcast();
  
  /// 语音识别结果流
  Stream<VoiceRecognitionResult> get resultStream => _resultController.stream;
  
  /// 是否正在监听
  bool get isListening => _isListening;
  
  /// 是否已初始化
  bool get isInitialized => _isInitialized;
  
  /// 最后识别的文本
  String get lastRecognizedText => _lastRecognizedText;
  
  /// 初始化语音服务
  Future<bool> init() async {
    if (_isInitialized) return true;
    
    try {
      _logger.info('初始化语音识别服务');
      
      // 检查权限
      final hasPermission = await _checkMicrophonePermission();
      if (!hasPermission) {
        _logger.error('麦克风权限未授权');
        return false;
      }
      
      // 初始化语音识别
      final available = await _speechToText.initialize(
        onError: _onError,
        onStatus: _onStatus,
        debugLogging: false,
      );
      
      if (available) {
        _isInitialized = true;
        _logger.info('语音识别服务初始化成功');
        return true;
      } else {
        _logger.error('语音识别服务不可用');
        return false;
      }
    } catch (e) {
      _logger.error('语音识别服务初始化失败', e);
      return false;
    }
  }
  
  /// 开始语音识别
  Future<bool> startListening({
    String localeId = 'zh_CN',
    Duration timeout = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 3),
  }) async {
    if (!_isInitialized) {
      final initialized = await init();
      if (!initialized) return false;
    }
    
    if (_isListening) {
      _logger.warning('语音识别已在进行中');
      return false;
    }
    
    try {
      _logger.info('开始语音识别');
      
      await _speechToText.listen(
        onResult: _onResult,
        localeId: localeId,
        listenFor: timeout,
        pauseFor: pauseFor,
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
      
      _isListening = true;
      _emitResult(VoiceRecognitionResult.listening());
      
      return true;
    } catch (e) {
      _logger.error('开始语音识别失败', e);
      _emitResult(VoiceRecognitionResult.error('开始语音识别失败: $e'));
      return false;
    }
  }
  
  /// 停止语音识别
  Future<void> stopListening() async {
    if (!_isListening) return;
    
    try {
      _logger.info('停止语音识别');
      await _speechToText.stop();
      _isListening = false;
      _emitResult(VoiceRecognitionResult.stopped());
    } catch (e) {
      _logger.error('停止语音识别失败', e);
      _emitResult(VoiceRecognitionResult.error('停止语音识别失败: $e'));
    }
  }
  
  /// 取消语音识别
  Future<void> cancelListening() async {
    if (!_isListening) return;
    
    try {
      _logger.info('取消语音识别');
      await _speechToText.cancel();
      _isListening = false;
      _emitResult(VoiceRecognitionResult.cancelled());
    } catch (e) {
      _logger.error('取消语音识别失败', e);
      _emitResult(VoiceRecognitionResult.error('取消语音识别失败: $e'));
    }
  }
  
  /// 获取支持的语言列表
  Future<List<LocaleName>> getSupportedLocales() async {
    if (!_isInitialized) {
      await init();
    }
    
    try {
      return await _speechToText.locales();
    } catch (e) {
      _logger.error('获取支持的语言列表失败', e);
      return [];
    }
  }
  
  /// 检查语音识别是否可用
  Future<bool> isAvailable() async {
    try {
      return await _speechToText.initialize();
    } catch (e) {
      _logger.error('检查语音识别可用性失败', e);
      return false;
    }
  }
  
  /// 语音记账 - 解析语音文本为交易信息
  VoiceTransactionResult parseVoiceToTransaction(String text) {
    try {
      _logger.info('解析语音文本: $text');
      
      // 清理文本
      final cleanText = _cleanText(text);
      
      // 提取金额
      final amount = _extractAmount(cleanText);
      
      // 提取交易类型（收入/支出）
      final type = _extractTransactionType(cleanText);
      
      // 提取分类
      final category = _extractCategory(cleanText);
      
      // 提取描述
      final description = _extractDescription(cleanText, amount, type, category);
      
      // 提取日期（如果有）
      final date = _extractDate(cleanText);
      
      return VoiceTransactionResult(
        success: true,
        amount: amount,
        type: type,
        category: category,
        description: description,
        date: date,
        originalText: text,
        confidence: _calculateConfidence(amount, type, category),
      );
    } catch (e) {
      _logger.error('解析语音文本失败', e);
      return VoiceTransactionResult(
        success: false,
        originalText: text,
        error: '解析失败: $e',
      );
    }
  }
  
  /// 清理文本
  String _cleanText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[，。！？；：]'), ',')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
  
  /// 提取金额
  double? _extractAmount(String text) {
    // 匹配各种金额表达方式
    final patterns = [
      RegExp(r'(\d+(?:\.\d+)?)\s*元'),
      RegExp(r'(\d+(?:\.\d+)?)\s*块'),
      RegExp(r'(\d+(?:\.\d+)?)\s*钱'),
      RegExp(r'花了\s*(\d+(?:\.\d+)?)'),
      RegExp(r'收入\s*(\d+(?:\.\d+)?)'),
      RegExp(r'(\d+(?:\.\d+)?)'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amountStr = match.group(1);
        if (amountStr != null) {
          return double.tryParse(amountStr);
        }
      }
    }
    
    return null;
  }
  
  /// 提取交易类型
  String _extractTransactionType(String text) {
    // 支出关键词
    final expenseKeywords = ['花', '买', '支出', '付', '消费', '花了', '买了', '付了'];
    // 收入关键词
    final incomeKeywords = ['收入', '赚', '工资', '奖金', '收到', '赚了'];
    
    for (final keyword in expenseKeywords) {
      if (text.contains(keyword)) {
        return 'expense';
      }
    }
    
    for (final keyword in incomeKeywords) {
      if (text.contains(keyword)) {
        return 'income';
      }
    }
    
    // 默认为支出
    return 'expense';
  }
  
  /// 提取分类
  String? _extractCategory(String text) {
    // 预定义分类关键词映射
    final categoryKeywords = {
      '餐饮': ['吃', '喝', '餐', '饭', '菜', '饮料', '咖啡', '茶', '早餐', '午餐', '晚餐', '夜宵'],
      '交通': ['打车', '地铁', '公交', '出租车', '滴滴', 'uber', '车费', '油费', '停车'],
      '购物': ['买', '购', '商场', '超市', '淘宝', '京东', '衣服', '鞋子', '包'],
      '娱乐': ['电影', '游戏', 'ktv', '酒吧', '旅游', '景点', '门票'],
      '医疗': ['医院', '药', '看病', '体检', '医疗', '挂号'],
      '教育': ['书', '课程', '培训', '学费', '教育'],
      '住房': ['房租', '水费', '电费', '燃气费', '物业费', '房贷'],
      '工资': ['工资', '薪水', '薪资', '奖金', '提成'],
      '投资': ['股票', '基金', '理财', '投资', '分红'],
    };
    
    for (final entry in categoryKeywords.entries) {
      final category = entry.key;
      final keywords = entry.value;
      
      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          return category;
        }
      }
    }
    
    return null;
  }
  
  /// 提取描述
  String _extractDescription(String text, double? amount, String type, String? category) {
    // 移除已识别的金额、类型、分类信息，剩余部分作为描述
    String description = text;
    
    // 移除金额相关文字
    if (amount != null) {
      description = description.replaceAll(RegExp(r'\d+(?:\.\d+)?\s*[元块钱]?'), '');
    }
    
    // 移除类型关键词
    final typeKeywords = ['花', '买', '支出', '付', '消费', '收入', '赚', '工资', '奖金'];
    for (final keyword in typeKeywords) {
      description = description.replaceAll(keyword, '');
    }
    
    // 移除分类关键词
    if (category != null) {
      // 这里可以根据分类移除相关关键词
    }
    
    return description.trim();
  }
  
  /// 提取日期
  DateTime? _extractDate(String text) {
    final now = DateTime.now();
    
    // 相对日期
    if (text.contains('今天')) {
      return now;
    } else if (text.contains('昨天')) {
      return now.subtract(const Duration(days: 1));
    } else if (text.contains('前天')) {
      return now.subtract(const Duration(days: 2));
    }
    
    // 具体日期匹配（简单实现）
    final datePattern = RegExp(r'(\d{1,2})月(\d{1,2})日');
    final match = datePattern.firstMatch(text);
    if (match != null) {
      final month = int.tryParse(match.group(1)!);
      final day = int.tryParse(match.group(2)!);
      if (month != null && day != null) {
        return DateTime(now.year, month, day);
      }
    }
    
    return null;
  }
  
  /// 计算识别置信度
  double _calculateConfidence(double? amount, String type, String? category) {
    double confidence = 0.0;
    
    // 金额识别加分
    if (amount != null && amount > 0) {
      confidence += 0.4;
    }
    
    // 类型识别加分
    confidence += 0.3;
    
    // 分类识别加分
    if (category != null) {
      confidence += 0.3;
    }
    
    return confidence.clamp(0.0, 1.0);
  }
  
  /// 检查麦克风权限
  Future<bool> _checkMicrophonePermission() async {
    try {
      final status = await Permission.microphone.status;
      if (status.isGranted) {
        return true;
      }
      
      if (status.isDenied) {
        final result = await Permission.microphone.request();
        return result.isGranted;
      }
      
      return false;
    } catch (e) {
      _logger.error('检查麦克风权限失败', e);
      return false;
    }
  }
  
  /// 语音识别结果回调
  void _onResult(SpeechRecognitionResult result) {
    _lastRecognizedText = result.recognizedWords;
    _logger.info('语音识别结果: ${result.recognizedWords}, 置信度: ${result.confidence}');
    
    _emitResult(VoiceRecognitionResult.result(
      result.recognizedWords,
      result.finalResult,
      result.confidence,
    ));
    
    if (result.finalResult) {
      _isListening = false;
    }
  }
  
  /// 语音识别错误回调
  void _onError(SpeechRecognitionError error) {
    _logger.error('语音识别错误: ${error.errorMsg}');
    _isListening = false;
    _emitResult(VoiceRecognitionResult.error(error.errorMsg));
  }
  
  /// 语音识别状态回调
  void _onStatus(String status) {
    _logger.info('语音识别状态: $status');
    
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
    }
  }
  
  /// 发送识别结果
  void _emitResult(VoiceRecognitionResult result) {
    _resultController.add(result);
  }
  
  /// 释放资源
  void dispose() {
    _resultController.close();
  }
}

/// 语音识别结果
class VoiceRecognitionResult {
  final VoiceRecognitionStatus status;
  final String? text;
  final bool? isFinal;
  final double? confidence;
  final String? error;
  
  VoiceRecognitionResult._({
    required this.status,
    this.text,
    this.isFinal,
    this.confidence,
    this.error,
  });
  
  factory VoiceRecognitionResult.listening() {
    return VoiceRecognitionResult._(status: VoiceRecognitionStatus.listening);
  }
  
  factory VoiceRecognitionResult.result(String text, bool isFinal, double confidence) {
    return VoiceRecognitionResult._(
      status: VoiceRecognitionStatus.result,
      text: text,
      isFinal: isFinal,
      confidence: confidence,
    );
  }
  
  factory VoiceRecognitionResult.stopped() {
    return VoiceRecognitionResult._(status: VoiceRecognitionStatus.stopped);
  }
  
  factory VoiceRecognitionResult.cancelled() {
    return VoiceRecognitionResult._(status: VoiceRecognitionStatus.cancelled);
  }
  
  factory VoiceRecognitionResult.error(String error) {
    return VoiceRecognitionResult._(
      status: VoiceRecognitionStatus.error,
      error: error,
    );
  }
}

/// 语音识别状态
enum VoiceRecognitionStatus {
  listening,
  result,
  stopped,
  cancelled,
  error,
}

/// 语音交易解析结果
class VoiceTransactionResult {
  final bool success;
  final double? amount;
  final String? type;
  final String? category;
  final String? description;
  final DateTime? date;
  final String originalText;
  final double? confidence;
  final String? error;
  
  VoiceTransactionResult({
    required this.success,
    this.amount,
    this.type,
    this.category,
    this.description,
    this.date,
    required this.originalText,
    this.confidence,
    this.error,
  });
  
  @override
  String toString() {
    if (!success) {
      return 'VoiceTransactionResult(success: false, error: $error)';
    }
    
    return 'VoiceTransactionResult(amount: $amount, type: $type, category: $category, description: $description, confidence: $confidence)';
  }
}