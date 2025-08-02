import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

/// 交易记录数据模型
/// 用于数据层的交易记录处理
class TransactionModel extends Equatable {
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
  
  const TransactionModel({
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
  
  /// 从JSON创建TransactionModel
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['category_id'] as String,
      subcategoryId: json['subcategory_id'] as String?,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as String?,
      tags: List<String>.from(json['tags'] as List? ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      receiptImagePath: json['receipt_image_path'] as String?,
      voiceNotePath: json['voice_note_path'] as String?,
      inputMethod: TransactionInputMethod.values.firstWhere(
        (e) => e.name == json['input_method'],
        orElse: () => TransactionInputMethod.manual,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.completed,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      syncId: json['sync_id'] as String?,
      syncedAt: json['synced_at'] != null
          ? DateTime.parse(json['synced_at'] as String)
          : null,
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }
  
  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'amount': amount,
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'tags': tags,
      'metadata': metadata,
      'receipt_image_path': receiptImagePath,
      'voice_note_path': voiceNotePath,
      'input_method': inputMethod.name,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_id': syncId,
      'synced_at': syncedAt?.toIso8601String(),
      'is_deleted': isDeleted,
    };
  }
  
  /// 转换为SQLite存储格式
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.index,
      'amount': amount,
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'location': location,
      'tags': tags.join(','),
      'metadata': metadata.isNotEmpty ? jsonEncode(metadata) : null,
      'receipt_image_path': receiptImagePath,
      'voice_note_path': voiceNotePath,
      'input_method': inputMethod.index,
      'status': status.index,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'sync_id': syncId,
      'synced_at': syncedAt?.millisecondsSinceEpoch,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }
  
  /// 从SQLite数据创建
  factory TransactionModel.fromSqlite(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      type: TransactionType.values[map['type'] as int],
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['category_id'] as String,
      subcategoryId: map['subcategory_id'] as String?,
      description: map['description'] as String?,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      location: map['location'] as String?,
      tags: map['tags'] != null 
          ? (map['tags'] as String).split(',').where((tag) => tag.isNotEmpty).toList()
          : [],
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(jsonDecode(map['metadata'] as String))
          : {},
      receiptImagePath: map['receipt_image_path'] as String?,
      voiceNotePath: map['voice_note_path'] as String?,
      inputMethod: TransactionInputMethod.values[map['input_method'] as int],
      status: TransactionStatus.values[map['status'] as int],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      syncId: map['sync_id'] as String?,
      syncedAt: map['synced_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['synced_at'] as int)
          : null,
      isDeleted: (map['is_deleted'] as int) == 1,
    );
  }
  
  /// 转换为领域实体
  Transaction toEntity() {
    return Transaction(
      id: id,
      userId: userId,
      type: type,
      amount: amount,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      description: description,
      date: date,
      location: location,
      tags: tags,
      metadata: metadata,
      receiptImagePath: receiptImagePath,
      voiceNotePath: voiceNotePath,
      inputMethod: inputMethod,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncId: syncId,
      syncedAt: syncedAt,
      isDeleted: isDeleted,
    );
  }
  
  /// 从领域实体创建
  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      userId: transaction.userId,
      type: transaction.type,
      amount: transaction.amount,
      categoryId: transaction.categoryId,
      subcategoryId: transaction.subcategoryId,
      description: transaction.description,
      date: transaction.date,
      location: transaction.location,
      tags: transaction.tags,
      metadata: transaction.metadata,
      receiptImagePath: transaction.receiptImagePath,
      voiceNotePath: transaction.voiceNotePath,
      inputMethod: transaction.inputMethod,
      status: transaction.status,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
      syncId: transaction.syncId,
      syncedAt: transaction.syncedAt,
      isDeleted: transaction.isDeleted,
    );
  }
  
  /// 复制并更新部分字段
  TransactionModel copyWith({
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
    return TransactionModel(
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
}

/// 交易统计数据模型
class TransactionStatsModel extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final int transactionCount;
  final double averageAmount;
  final Map<String, double> categoryBreakdown;
  final Map<String, int> monthlyCount;
  final DateTime periodStart;
  final DateTime periodEnd;
  
  const TransactionStatsModel({
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
  
  factory TransactionStatsModel.fromJson(Map<String, dynamic> json) {
    return TransactionStatsModel(
      totalIncome: (json['total_income'] as num).toDouble(),
      totalExpense: (json['total_expense'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      transactionCount: json['transaction_count'] as int,
      averageAmount: (json['average_amount'] as num).toDouble(),
      categoryBreakdown: Map<String, double>.from(
        (json['category_breakdown'] as Map).map(
          (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
        ),
      ),
      monthlyCount: Map<String, int>.from(
        (json['monthly_count'] as Map).map(
          (key, value) => MapEntry(key.toString(), value as int),
        ),
      ),
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'total_income': totalIncome,
      'total_expense': totalExpense,
      'balance': balance,
      'transaction_count': transactionCount,
      'average_amount': averageAmount,
      'category_breakdown': categoryBreakdown,
      'monthly_count': monthlyCount,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
    };
  }
  
  /// 转换为领域实体
  TransactionStats toEntity() {
    return TransactionStats(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: balance,
      transactionCount: transactionCount,
      averageAmount: averageAmount,
      categoryBreakdown: categoryBreakdown,
      monthlyCount: monthlyCount,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
  }
  
  /// 从领域实体创建
  factory TransactionStatsModel.fromEntity(TransactionStats stats) {
    return TransactionStatsModel(
      totalIncome: stats.totalIncome,
      totalExpense: stats.totalExpense,
      balance: stats.balance,
      transactionCount: stats.transactionCount,
      averageAmount: stats.averageAmount,
      categoryBreakdown: stats.categoryBreakdown,
      monthlyCount: stats.monthlyCount,
      periodStart: stats.periodStart,
      periodEnd: stats.periodEnd,
    );
  }
  
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
}