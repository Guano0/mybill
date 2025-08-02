import 'dart:io';
import 'dart:typed_data';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import '../utils/logger.dart';

/// OCR文字识别服务
/// 提供图片文字识别功能，支持票据识别和自动记账
class OcrService {
  static final OcrService _instance = OcrService._internal();
  factory OcrService() => _instance;
  OcrService._internal();
  
  final Logger _logger = Logger();
  late final TextRecognizer _textRecognizer;
  
  bool _isInitialized = false;
  
  /// 是否已初始化
  bool get isInitialized => _isInitialized;
  
  /// 初始化OCR服务
  Future<bool> init() async {
    if (_isInitialized) return true;
    
    try {
      _logger.info('初始化OCR服务');
      
      // 初始化文字识别器
      _textRecognizer = TextRecognizer(
        script: TextRecognitionScript.chinese,
      );
      
      _isInitialized = true;
      _logger.info('OCR服务初始化成功');
      return true;
    } catch (e) {
      _logger.error('OCR服务初始化失败', e);
      return false;
    }
  }
  
  /// 识别图片中的文字
  Future<OcrResult> recognizeText(String imagePath) async {
    if (!_isInitialized) {
      final initialized = await init();
      if (!initialized) {
        return OcrResult.error('OCR服务初始化失败');
      }
    }
    
    try {
      _logger.info('开始识别图片文字: $imagePath');
      
      // 检查文件是否存在
      final file = File(imagePath);
      if (!await file.exists()) {
        return OcrResult.error('图片文件不存在');
      }
      
      // 预处理图片
      final processedImagePath = await _preprocessImage(imagePath);
      
      // 创建输入图片
      final inputImage = InputImage.fromFilePath(processedImagePath);
      
      // 执行文字识别
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      // 提取文字和位置信息
      final textBlocks = <OcrTextBlock>[];
      for (final block in recognizedText.blocks) {
        textBlocks.add(OcrTextBlock(
          text: block.text,
          boundingBox: block.boundingBox,
          confidence: block.confidence ?? 0.0,
          lines: block.lines.map((line) => OcrTextLine(
            text: line.text,
            boundingBox: line.boundingBox,
            confidence: line.confidence ?? 0.0,
          )).toList(),
        ));
      }
      
      // 清理临时文件
      if (processedImagePath != imagePath) {
        await File(processedImagePath).delete();
      }
      
      _logger.info('文字识别完成，识别到 ${textBlocks.length} 个文本块');
      
      return OcrResult.success(
        fullText: recognizedText.text,
        textBlocks: textBlocks,
      );
    } catch (e) {
      _logger.error('文字识别失败', e);
      return OcrResult.error('文字识别失败: $e');
    }
  }
  
  /// 识别票据信息
  Future<ReceiptResult> recognizeReceipt(String imagePath) async {
    try {
      _logger.info('开始识别票据: $imagePath');
      
      // 先进行文字识别
      final ocrResult = await recognizeText(imagePath);
      if (!ocrResult.success) {
        return ReceiptResult.error(ocrResult.error!);
      }
      
      // 解析票据信息
      final receiptInfo = _parseReceiptInfo(ocrResult.fullText, ocrResult.textBlocks);
      
      _logger.info('票据识别完成: ${receiptInfo.toString()}');
      return receiptInfo;
    } catch (e) {
      _logger.error('票据识别失败', e);
      return ReceiptResult.error('票据识别失败: $e');
    }
  }
  
  /// 预处理图片
  Future<String> _preprocessImage(String imagePath) async {
    try {
      // 读取原始图片
      final bytes = await File(imagePath).readAsBytes();
      final originalImage = img.decodeImage(bytes);
      
      if (originalImage == null) {
        throw Exception('无法解码图片');
      }
      
      // 图片预处理
      var processedImage = originalImage;
      
      // 1. 调整大小（如果图片太大）
      if (processedImage.width > 2000 || processedImage.height > 2000) {
        final ratio = 2000 / (processedImage.width > processedImage.height 
            ? processedImage.width 
            : processedImage.height);
        processedImage = img.copyResize(
          processedImage,
          width: (processedImage.width * ratio).round(),
          height: (processedImage.height * ratio).round(),
        );
      }
      
      // 2. 增强对比度
      processedImage = img.contrast(processedImage, contrast: 1.2);
      
      // 3. 调整亮度
      processedImage = img.brightness(processedImage, brightness: 1.1);
      
      // 4. 锐化
      processedImage = img.convolution(processedImage, filter: [
        0, -1, 0,
        -1, 5, -1,
        0, -1, 0
      ]);
      
      // 保存处理后的图片
      final processedPath = '${imagePath}_processed.jpg';
      await File(processedPath).writeAsBytes(img.encodeJpg(processedImage));
      
      return processedPath;
    } catch (e) {
      _logger.error('图片预处理失败', e);
      return imagePath; // 返回原始路径
    }
  }
  
  /// 解析票据信息
  ReceiptResult _parseReceiptInfo(String fullText, List<OcrTextBlock> textBlocks) {
    try {
      final receiptInfo = ReceiptInfo();
      
      // 提取商家名称
      receiptInfo.merchantName = _extractMerchantName(fullText, textBlocks);
      
      // 提取总金额
      receiptInfo.totalAmount = _extractTotalAmount(fullText);
      
      // 提取日期时间
      receiptInfo.dateTime = _extractDateTime(fullText);
      
      // 提取商品列表
      receiptInfo.items = _extractItems(fullText, textBlocks);
      
      // 提取支付方式
      receiptInfo.paymentMethod = _extractPaymentMethod(fullText);
      
      // 计算置信度
      final confidence = _calculateReceiptConfidence(receiptInfo);
      
      return ReceiptResult.success(
        receiptInfo: receiptInfo,
        confidence: confidence,
        originalText: fullText,
      );
    } catch (e) {
      _logger.error('解析票据信息失败', e);
      return ReceiptResult.error('解析票据信息失败: $e');
    }
  }
  
  /// 提取商家名称
  String? _extractMerchantName(String text, List<OcrTextBlock> textBlocks) {
    // 通常商家名称在票据顶部，字体较大
    if (textBlocks.isNotEmpty) {
      // 取第一个文本块作为可能的商家名称
      final firstBlock = textBlocks.first;
      if (firstBlock.text.length > 2 && firstBlock.text.length < 30) {
        return firstBlock.text.trim();
      }
    }
    
    // 使用正则表达式匹配常见的商家名称模式
    final merchantPatterns = [
      RegExp(r'^([\u4e00-\u9fa5]+(?:店|超市|商场|餐厅|酒店|公司))'),
      RegExp(r'^([A-Za-z\s]+(?:Store|Shop|Restaurant|Hotel|Company))', caseSensitive: false),
    ];
    
    for (final pattern in merchantPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(1)?.trim();
      }
    }
    
    return null;
  }
  
  /// 提取总金额
  double? _extractTotalAmount(String text) {
    // 匹配各种金额表达方式
    final amountPatterns = [
      RegExp(r'合计[：:]?\s*(\d+(?:\.\d{2})?)'),
      RegExp(r'总计[：:]?\s*(\d+(?:\.\d{2})?)'),
      RegExp(r'应付[：:]?\s*(\d+(?:\.\d{2})?)'),
      RegExp(r'实付[：:]?\s*(\d+(?:\.\d{2})?)'),
      RegExp(r'Total[：:]?\s*(\d+(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'Amount[：:]?\s*(\d+(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'￥\s*(\d+(?:\.\d{2})?)'),
      RegExp(r'¥\s*(\d+(?:\.\d{2})?)'),
      RegExp(r'RMB\s*(\d+(?:\.\d{2})?)', caseSensitive: false),
    ];
    
    for (final pattern in amountPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amountStr = match.group(1);
        if (amountStr != null) {
          final amount = double.tryParse(amountStr);
          if (amount != null && amount > 0) {
            return amount;
          }
        }
      }
    }
    
    return null;
  }
  
  /// 提取日期时间
  DateTime? _extractDateTime(String text) {
    // 匹配各种日期时间格式
    final dateTimePatterns = [
      RegExp(r'(\d{4})[-/年](\d{1,2})[-/月](\d{1,2})[日]?\s*(\d{1,2})[：:时](\d{1,2})[：:分]?(\d{1,2})?[秒]?'),
      RegExp(r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})\s+(\d{1,2}):(\d{1,2}):(\d{1,2})'),
      RegExp(r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})\s+(\d{1,2}):(\d{1,2})'),
      RegExp(r'(\d{4})[-/年](\d{1,2})[-/月](\d{1,2})[日]?'),
    ];
    
    for (final pattern in dateTimePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          final year = int.parse(match.group(1)!);
          final month = int.parse(match.group(2)!);
          final day = int.parse(match.group(3)!);
          
          int hour = 0;
          int minute = 0;
          int second = 0;
          
          if (match.groupCount >= 5) {
            hour = int.parse(match.group(4) ?? '0');
            minute = int.parse(match.group(5) ?? '0');
            if (match.groupCount >= 6 && match.group(6) != null) {
              second = int.parse(match.group(6)!);
            }
          }
          
          return DateTime(year, month, day, hour, minute, second);
        } catch (e) {
          continue;
        }
      }
    }
    
    return null;
  }
  
  /// 提取商品列表
  List<ReceiptItem> _extractItems(String text, List<OcrTextBlock> textBlocks) {
    final items = <ReceiptItem>[];
    
    // 简单的商品行匹配
    final lines = text.split('\n');
    for (final line in lines) {
      final itemMatch = RegExp(r'^(.+?)\s+(\d+(?:\.\d{2})?)$').firstMatch(line.trim());
      if (itemMatch != null) {
        final name = itemMatch.group(1)?.trim();
        final priceStr = itemMatch.group(2);
        
        if (name != null && priceStr != null) {
          final price = double.tryParse(priceStr);
          if (price != null && price > 0 && name.length > 1) {
            items.add(ReceiptItem(
              name: name,
              price: price,
              quantity: 1,
            ));
          }
        }
      }
    }
    
    return items;
  }
  
  /// 提取支付方式
  String? _extractPaymentMethod(String text) {
    final paymentPatterns = {
      '现金': RegExp(r'现金|cash', caseSensitive: false),
      '银行卡': RegExp(r'银行卡|刷卡|card', caseSensitive: false),
      '支付宝': RegExp(r'支付宝|alipay', caseSensitive: false),
      '微信': RegExp(r'微信|wechat|weixin', caseSensitive: false),
      '信用卡': RegExp(r'信用卡|credit', caseSensitive: false),
    };
    
    for (final entry in paymentPatterns.entries) {
      if (entry.value.hasMatch(text)) {
        return entry.key;
      }
    }
    
    return null;
  }
  
  /// 计算票据识别置信度
  double _calculateReceiptConfidence(ReceiptInfo receiptInfo) {
    double confidence = 0.0;
    
    // 商家名称
    if (receiptInfo.merchantName != null) {
      confidence += 0.2;
    }
    
    // 总金额
    if (receiptInfo.totalAmount != null) {
      confidence += 0.3;
    }
    
    // 日期时间
    if (receiptInfo.dateTime != null) {
      confidence += 0.2;
    }
    
    // 商品列表
    if (receiptInfo.items.isNotEmpty) {
      confidence += 0.2;
    }
    
    // 支付方式
    if (receiptInfo.paymentMethod != null) {
      confidence += 0.1;
    }
    
    return confidence.clamp(0.0, 1.0);
  }
  
  /// 释放资源
  Future<void> dispose() async {
    if (_isInitialized) {
      await _textRecognizer.close();
      _isInitialized = false;
    }
  }
}

/// OCR识别结果
class OcrResult {
  final bool success;
  final String fullText;
  final List<OcrTextBlock> textBlocks;
  final String? error;
  
  OcrResult._(
    this.success,
    this.fullText,
    this.textBlocks,
    this.error,
  );
  
  factory OcrResult.success({
    required String fullText,
    required List<OcrTextBlock> textBlocks,
  }) {
    return OcrResult._(true, fullText, textBlocks, null);
  }
  
  factory OcrResult.error(String error) {
    return OcrResult._(false, '', [], error);
  }
}

/// OCR文本块
class OcrTextBlock {
  final String text;
  final Rect boundingBox;
  final double confidence;
  final List<OcrTextLine> lines;
  
  OcrTextBlock({
    required this.text,
    required this.boundingBox,
    required this.confidence,
    required this.lines,
  });
}

/// OCR文本行
class OcrTextLine {
  final String text;
  final Rect boundingBox;
  final double confidence;
  
  OcrTextLine({
    required this.text,
    required this.boundingBox,
    required this.confidence,
  });
}

/// 票据识别结果
class ReceiptResult {
  final bool success;
  final ReceiptInfo? receiptInfo;
  final double? confidence;
  final String? originalText;
  final String? error;
  
  ReceiptResult._(
    this.success,
    this.receiptInfo,
    this.confidence,
    this.originalText,
    this.error,
  );
  
  factory ReceiptResult.success({
    required ReceiptInfo receiptInfo,
    required double confidence,
    required String originalText,
  }) {
    return ReceiptResult._(true, receiptInfo, confidence, originalText, null);
  }
  
  factory ReceiptResult.error(String error) {
    return ReceiptResult._(false, null, null, null, error);
  }
}

/// 票据信息
class ReceiptInfo {
  String? merchantName;
  double? totalAmount;
  DateTime? dateTime;
  List<ReceiptItem> items = [];
  String? paymentMethod;
  
  @override
  String toString() {
    return 'ReceiptInfo(merchant: $merchantName, amount: $totalAmount, date: $dateTime, items: ${items.length}, payment: $paymentMethod)';
  }
}

/// 票据商品项
class ReceiptItem {
  final String name;
  final double price;
  final int quantity;
  
  ReceiptItem({
    required this.name,
    required this.price,
    this.quantity = 1,
  });
  
  @override
  String toString() {
    return 'ReceiptItem(name: $name, price: $price, quantity: $quantity)';
  }
}