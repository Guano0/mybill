import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';

/// 分类数据模型
/// 用于数据层的分类信息处理
class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String icon;
  final String color;
  final CategoryType type;
  final String? parentId;
  final int sortOrder;
  final bool isDefault;
  final bool isActive;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? syncId;
  final DateTime? syncedAt;
  final bool isDeleted;
  
  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.color,
    required this.type,
    this.parentId,
    this.sortOrder = 0,
    this.isDefault = false,
    this.isActive = true,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.syncId,
    this.syncedAt,
    this.isDeleted = false,
  });
  
  /// 从JSON创建CategoryModel
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String,
      color: json['color'] as String,
      type: CategoryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CategoryType.expense,
      ),
      parentId: json['parent_id'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isDefault: json['is_default'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
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
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'type': type.name,
      'parent_id': parentId,
      'sort_order': sortOrder,
      'is_default': isDefault,
      'is_active': isActive,
      'metadata': metadata,
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
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'type': type.index,
      'parent_id': parentId,
      'sort_order': sortOrder,
      'is_default': isDefault ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'metadata': metadata.isNotEmpty ? jsonEncode(metadata) : null,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'sync_id': syncId,
      'synced_at': syncedAt?.millisecondsSinceEpoch,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }
  
  /// 从SQLite数据创建
  factory CategoryModel.fromSqlite(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      icon: map['icon'] as String,
      color: map['color'] as String,
      type: CategoryType.values[map['type'] as int],
      parentId: map['parent_id'] as String?,
      sortOrder: map['sort_order'] as int? ?? 0,
      isDefault: (map['is_default'] as int) == 1,
      isActive: (map['is_active'] as int) == 1,
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(jsonDecode(map['metadata'] as String))
          : {},
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
  Category toEntity() {
    return Category(
      id: id,
      name: name,
      description: description,
      icon: icon,
      color: color,
      type: type,
      parentId: parentId,
      sortOrder: sortOrder,
      isDefault: isDefault,
      isActive: isActive,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncId: syncId,
      syncedAt: syncedAt,
      isDeleted: isDeleted,
    );
  }
  
  /// 从领域实体创建
  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      description: category.description,
      icon: category.icon,
      color: category.color,
      type: category.type,
      parentId: category.parentId,
      sortOrder: category.sortOrder,
      isDefault: category.isDefault,
      isActive: category.isActive,
      metadata: category.metadata,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
      syncId: category.syncId,
      syncedAt: category.syncedAt,
      isDeleted: category.isDeleted,
    );
  }
  
  /// 复制并更新部分字段
  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    CategoryType? type,
    String? parentId,
    int? sortOrder,
    bool? isDefault,
    bool? isActive,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncId,
    DateTime? syncedAt,
    bool? isDeleted,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
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
    name,
    description,
    icon,
    color,
    type,
    parentId,
    sortOrder,
    isDefault,
    isActive,
    metadata,
    createdAt,
    updatedAt,
    syncId,
    syncedAt,
    isDeleted,
  ];
}

/// 分类统计数据模型
class CategoryStatsModel extends Equatable {
  final String categoryId;
  final String categoryName;
  final double totalAmount;
  final int transactionCount;
  final double averageAmount;
  final double percentage;
  final DateTime periodStart;
  final DateTime periodEnd;
  final Map<String, double> monthlyBreakdown;
  
  const CategoryStatsModel({
    required this.categoryId,
    required this.categoryName,
    required this.totalAmount,
    required this.transactionCount,
    required this.averageAmount,
    required this.percentage,
    required this.periodStart,
    required this.periodEnd,
    required this.monthlyBreakdown,
  });
  
  factory CategoryStatsModel.fromJson(Map<String, dynamic> json) {
    return CategoryStatsModel(
      categoryId: json['category_id'] as String,
      categoryName: json['category_name'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      transactionCount: json['transaction_count'] as int,
      averageAmount: (json['average_amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      monthlyBreakdown: Map<String, double>.from(
        (json['monthly_breakdown'] as Map).map(
          (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
        ),
      ),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
      'total_amount': totalAmount,
      'transaction_count': transactionCount,
      'average_amount': averageAmount,
      'percentage': percentage,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'monthly_breakdown': monthlyBreakdown,
    };
  }
  
  /// 转换为领域实体
  CategoryStats toEntity() {
    return CategoryStats(
      categoryId: categoryId,
      categoryName: categoryName,
      totalAmount: totalAmount,
      transactionCount: transactionCount,
      averageAmount: averageAmount,
      percentage: percentage,
      periodStart: periodStart,
      periodEnd: periodEnd,
      monthlyBreakdown: monthlyBreakdown,
    );
  }
  
  /// 从领域实体创建
  factory CategoryStatsModel.fromEntity(CategoryStats stats) {
    return CategoryStatsModel(
      categoryId: stats.categoryId,
      categoryName: stats.categoryName,
      totalAmount: stats.totalAmount,
      transactionCount: stats.transactionCount,
      averageAmount: stats.averageAmount,
      percentage: stats.percentage,
      periodStart: stats.periodStart,
      periodEnd: stats.periodEnd,
      monthlyBreakdown: stats.monthlyBreakdown,
    );
  }
  
  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    totalAmount,
    transactionCount,
    averageAmount,
    percentage,
    periodStart,
    periodEnd,
    monthlyBreakdown,
  ];
}

/// 预设分类数据
class DefaultCategoriesData {
  /// 获取默认支出分类
  static List<CategoryModel> getDefaultExpenseCategories() {
    final now = DateTime.now();
    
    return [
      CategoryModel(
        id: 'expense_food',
        name: '餐饮',
        description: '日常用餐、外卖、聚餐等',
        icon: 'restaurant',
        color: '#FF6B6B',
        type: CategoryType.expense,
        sortOrder: 1,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'expense_transport',
        name: '交通',
        description: '公交、地铁、打车、加油等',
        icon: 'directions_car',
        color: '#4ECDC4',
        type: CategoryType.expense,
        sortOrder: 2,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'expense_shopping',
        name: '购物',
        description: '服装、日用品、电子产品等',
        icon: 'shopping_cart',
        color: '#45B7D1',
        type: CategoryType.expense,
        sortOrder: 3,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'expense_entertainment',
        name: '娱乐',
        description: '电影、游戏、旅游等',
        icon: 'movie',
        color: '#96CEB4',
        type: CategoryType.expense,
        sortOrder: 4,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'expense_healthcare',
        name: '医疗',
        description: '看病、买药、体检等',
        icon: 'local_hospital',
        color: '#FFEAA7',
        type: CategoryType.expense,
        sortOrder: 5,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'expense_education',
        name: '教育',
        description: '学费、培训、书籍等',
        icon: 'school',
        color: '#DDA0DD',
        type: CategoryType.expense,
        sortOrder: 6,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'expense_housing',
        name: '住房',
        description: '房租、水电、物业等',
        icon: 'home',
        color: '#FAB1A0',
        type: CategoryType.expense,
        sortOrder: 7,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'expense_other',
        name: '其他',
        description: '其他支出',
        icon: 'more_horiz',
        color: '#A0A0A0',
        type: CategoryType.expense,
        sortOrder: 99,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
  
  /// 获取默认收入分类
  static List<CategoryModel> getDefaultIncomeCategories() {
    final now = DateTime.now();
    
    return [
      CategoryModel(
        id: 'income_salary',
        name: '工资',
        description: '月薪、年终奖等',
        icon: 'work',
        color: '#00B894',
        type: CategoryType.income,
        sortOrder: 1,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'income_bonus',
        name: '奖金',
        description: '绩效奖金、提成等',
        icon: 'card_giftcard',
        color: '#00CEC9',
        type: CategoryType.income,
        sortOrder: 2,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'income_investment',
        name: '投资',
        description: '股票、基金、理财收益等',
        icon: 'trending_up',
        color: '#6C5CE7',
        type: CategoryType.income,
        sortOrder: 3,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'income_freelance',
        name: '兼职',
        description: '自由职业、兼职收入等',
        icon: 'laptop',
        color: '#A29BFE',
        type: CategoryType.income,
        sortOrder: 4,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'income_gift',
        name: '礼金',
        description: '红包、礼金等',
        icon: 'redeem',
        color: '#FD79A8',
        type: CategoryType.income,
        sortOrder: 5,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'income_other',
        name: '其他',
        description: '其他收入',
        icon: 'more_horiz',
        color: '#A0A0A0',
        type: CategoryType.income,
        sortOrder: 99,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
  
  /// 获取所有默认分类
  static List<CategoryModel> getAllDefaultCategories() {
    return [
      ...getDefaultExpenseCategories(),
      ...getDefaultIncomeCategories(),
    ];
  }
}