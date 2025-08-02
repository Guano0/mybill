import 'package:equatable/equatable.dart';

/// 交易记录领域实体
/// 表示应用中的交易记录概念，不依赖于具体的数据实现
class Transaction extends Equatable {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final String categoryId;
  final String? subcategoryId;
  final String? description;
  final DateTime date;
  final String? location;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final String? receiptImagePath;
  final String? voiceNotePath;
  final TransactionInputMethod inputMethod;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? syncId;
  final DateTime? syncedAt;
  final bool isDeleted;
  
  const Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.categoryId,
    this.subcategoryId,
    this.description,
    required this.date,
    this.location,
    this.tags = const [],
    this.metadata = const {},
    this.receiptImagePath,
    this.voiceNotePath,
    this.inputMethod = TransactionInputMethod.manual,
    this.status = TransactionStatus.completed,
    required this.createdAt,
    required this.updatedAt,
    this.syncId,
    this.syncedAt,
    this.isDeleted = false,
  });
  
  /// 是否为收入
  bool get isIncome => type == TransactionType.income;
  
  /// 是否为支出
  bool get isExpense => type == TransactionType.expense;
  
  /// 是否为转账
  bool get isTransfer => type == TransactionType.transfer;
  
  /// 获取带符号的金额（收入为正，支出为负）
  double get signedAmount {
    switch (type) {
      case TransactionType.income:
        return amount;
      case TransactionType.expense:
        return -amount;
      case TransactionType.transfer:
        return 0; // 转账不影响总余额
    }
  }
  
  /// 是否有附件（图片或语音）
  bool get hasAttachments => receiptImagePath != null || voiceNotePath != null;
  
  /// 是否有标签
  bool get hasTags => tags.isNotEmpty;
  
  /// 是否有位置信息
  bool get hasLocation => location != null && location!.isNotEmpty;
  
  /// 是否需要同步
  bool get needsSync => syncId == null || syncedAt == null || updatedAt.isAfter(syncedAt!);
  
  /// 是否为今天的交易
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  /// 是否为本周的交易
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }
  
  /// 是否为本月的交易
  bool get isThisMonth {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }
  
  /// 是否为本年的交易
  bool get isThisYear {
    final now = DateTime.now();
    return date.year == now.year;
  }
  
  /// 获取交易的显示标题
  String get displayTitle {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }
    return type.displayName;
  }
  
  /// 获取交易的显示副标题
  String get displaySubtitle {
    final parts = <String>[];
    
    if (location != null && location!.isNotEmpty) {
      parts.add(location!);
    }
    
    if (tags.isNotEmpty) {
      parts.add(tags.join(', '));
    }
    
    return parts.join(' • ');
  }
  
  /// 获取输入方式的显示名称
  String get inputMethodDisplayName {
    switch (inputMethod) {
      case TransactionInputMethod.manual:
        return '手动输入';
      case TransactionInputMethod.voice:
        return '语音输入';
      case TransactionInputMethod.ocr:
        return 'OCR识别';
      case TransactionInputMethod.import:
        return '数据导入';
      case TransactionInputMethod.api:
        return 'API同步';
    }
  }
  
  /// 复制并更新部分字段
  Transaction copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    double? amount,
    String? categoryId,
    String? subcategoryId,
    String? description,
    DateTime? date,
    String? location,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    String? receiptImagePath,
    String? voiceNotePath,
    TransactionInputMethod? inputMethod,
    TransactionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncId,
    DateTime? syncedAt,
    bool? isDeleted,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      voiceNotePath: voiceNotePath ?? this.voiceNotePath,
      inputMethod: inputMethod ?? this.inputMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncId: syncId ?? this.syncId,
      syncedAt: syncedAt ?? this.syncedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    amount,
    categoryId,
    subcategoryId,
    description,
    date,
    location,
    tags,
    metadata,
    receiptImagePath,
    voiceNotePath,
    inputMethod,
    status,
    createdAt,
    updatedAt,
    syncId,
    syncedAt,
    isDeleted,
  ];
  
  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, amount: $amount, description: $description)';
  }
}

/// 交易类型枚举
enum TransactionType {
  income,
  expense,
  transfer;
  
  /// 获取显示名称
  String get displayName {
    switch (this) {
      case TransactionType.income:
        return '收入';
      case TransactionType.expense:
        return '支出';
      case TransactionType.transfer:
        return '转账';
    }
  }
  
  /// 获取图标名称
  String get iconName {
    switch (this) {
      case TransactionType.income:
        return 'trending_up';
      case TransactionType.expense:
        return 'trending_down';
      case TransactionType.transfer:
        return 'swap_horiz';
    }
  }
  
  /// 获取颜色名称
  String get colorName {
    switch (this) {
      case TransactionType.income:
        return 'success';
      case TransactionType.expense:
        return 'error';
      case TransactionType.transfer:
        return 'info';
    }
  }
}

/// 交易输入方式枚举
enum TransactionInputMethod {
  manual,
  voice,
  ocr,
  import,
  api;
  
  /// 获取显示名称
  String get displayName {
    switch (this) {
      case TransactionInputMethod.manual:
        return '手动输入';
      case TransactionInputMethod.voice:
        return '语音输入';
      case TransactionInputMethod.ocr:
        return 'OCR识别';
      case TransactionInputMethod.import:
        return '数据导入';
      case TransactionInputMethod.api:
        return 'API同步';
    }
  }
  
  /// 获取图标名称
  String get iconName {
    switch (this) {
      case TransactionInputMethod.manual:
        return 'edit';
      case TransactionInputMethod.voice:
        return 'mic';
      case TransactionInputMethod.ocr:
        return 'camera_alt';
      case TransactionInputMethod.import:
        return 'file_upload';
      case TransactionInputMethod.api:
        return 'sync';
    }
  }
}

/// 交易状态枚举
enum TransactionStatus {
  pending,
  completed,
  cancelled,
  failed;
  
  /// 获取显示名称
  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return '待处理';
      case TransactionStatus.completed:
        return '已完成';
      case TransactionStatus.cancelled:
        return '已取消';
      case TransactionStatus.failed:
        return '失败';
    }
  }
  
  /// 获取颜色名称
  String get colorName {
    switch (this) {
      case TransactionStatus.pending:
        return 'warning';
      case TransactionStatus.completed:
        return 'success';
      case TransactionStatus.cancelled:
        return 'grey';
      case TransactionStatus.failed:
        return 'error';
    }
  }
}

/// 交易统计实体
class TransactionStats extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final int transactionCount;
  final double averageAmount;
  final Map<String, double> categoryBreakdown;
  final Map<String, int> monthlyCount;
  final DateTime periodStart;
  final DateTime periodEnd;
  
  const TransactionStats({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
    required this.averageAmount,
    required this.categoryBreakdown,
    required this.monthlyCount,
    required this.periodStart,
    required this.periodEnd,
  });
  
  /// 净收入（收入-支出）
  double get netIncome => totalIncome - totalExpense;
  
  /// 支出占收入的比例
  double get expenseRatio {
    if (totalIncome == 0) return 0;
    return totalExpense / totalIncome;
  }
  
  /// 储蓄率
  double get savingsRate {
    if (totalIncome == 0) return 0;
    return (totalIncome - totalExpense) / totalIncome;
  }
  
  /// 平均每日支出
  double get averageDailyExpense {
    final days = periodEnd.difference(periodStart).inDays + 1;
    if (days == 0) return 0;
    return totalExpense / days;
  }
  
  /// 平均每日收入
  double get averageDailyIncome {
    final days = periodEnd.difference(periodStart).inDays + 1;
    if (days == 0) return 0;
    return totalIncome / days;
  }
  
  /// 最大支出分类
  String? get topExpenseCategory {
    if (categoryBreakdown.isEmpty) return null;
    
    var maxAmount = 0.0;
    String? topCategory;
    
    for (final entry in categoryBreakdown.entries) {
      if (entry.value > maxAmount) {
        maxAmount = entry.value;
        topCategory = entry.key;
      }
    }
    
    return topCategory;
  }
  
  /// 获取指定分类的支出占比
  double getCategoryPercentage(String categoryId) {
    if (totalExpense == 0) return 0;
    final categoryAmount = categoryBreakdown[categoryId] ?? 0;
    return categoryAmount / totalExpense;
  }
  
  /// 是否有数据
  bool get hasData => transactionCount > 0;
  
  /// 统计期间天数
  int get periodDays => periodEnd.difference(periodStart).inDays + 1;
  
  @override
  List<Object?> get props => [
    totalIncome,
    totalExpense,
    balance,
    transactionCount,
    averageAmount,
    categoryBreakdown,
    monthlyCount,
    periodStart,
    periodEnd,
  ];
  
  @override
  String toString() {
    return 'TransactionStats(income: $totalIncome, expense: $totalExpense, balance: $balance, count: $transactionCount)';
  }
}

/// 交易查询参数
class TransactionQuery extends Equatable {
  final String? userId;
  final List<TransactionType>? types;
  final List<String>? categoryIds;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final String? searchText;
  final List<String>? tags;
  final List<TransactionInputMethod>? inputMethods;
  final List<TransactionStatus>? statuses;
  final String? sortBy; // date, amount, created_at
  final bool sortDescending;
  final int? limit;
  final int? offset;
  final bool includeDeleted;
  
  const TransactionQuery({
    this.userId,
    this.types,
    this.categoryIds,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.searchText,
    this.tags,
    this.inputMethods,
    this.statuses,
    this.sortBy = 'date',
    this.sortDescending = true,
    this.limit,
    this.offset,
    this.includeDeleted = false,
  });
  
  /// 复制并更新部分字段
  TransactionQuery copyWith({
    String? userId,
    List<TransactionType>? types,
    List<String>? categoryIds,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    String? searchText,
    List<String>? tags,
    List<TransactionInputMethod>? inputMethods,
    List<TransactionStatus>? statuses,
    String? sortBy,
    bool? sortDescending,
    int? limit,
    int? offset,
    bool? includeDeleted,
  }) {
    return TransactionQuery(
      userId: userId ?? this.userId,
      types: types ?? this.types,
      categoryIds: categoryIds ?? this.categoryIds,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      searchText: searchText ?? this.searchText,
      tags: tags ?? this.tags,
      inputMethods: inputMethods ?? this.inputMethods,
      statuses: statuses ?? this.statuses,
      sortBy: sortBy ?? this.sortBy,
      sortDescending: sortDescending ?? this.sortDescending,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }
  
  @override
  List<Object?> get props => [
    userId,
    types,
    categoryIds,
    startDate,
    endDate,
    minAmount,
    maxAmount,
    searchText,
    tags,
    inputMethods,
    statuses,
    sortBy,
    sortDescending,
    limit,
    offset,
    includeDeleted,
  ];
}