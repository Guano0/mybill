import 'package:equatable/equatable.dart';

/// Category type enumeration
enum CategoryType {
  expense('expense', 'Expense', 'expense_icon', 'expense_color'),
  income('income', 'Income', 'income_icon', 'income_color');

  const CategoryType(this.value, this.displayName, this.iconName, this.colorName);

  final String value;
  final String displayName;
  final String iconName;
  final String colorName;

  static CategoryType fromString(String value) {
    return CategoryType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CategoryType.expense,
    );
  }
}

/// Core Category entity for domain layer
class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.icon,
    this.color,
    this.parentId,
    this.sortOrder = 0,
    this.isDefault = false,
    this.isActive = true,
    this.metadata = const {},
    this.createdAt,
    this.updatedAt,
    this.syncId,
    this.syncedAt,
    this.isDeleted = false,
  });

  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final CategoryType type;
  final String? parentId;
  final int sortOrder;
  final bool isDefault;
  final bool isActive;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? syncId;
  final DateTime? syncedAt;
  final bool isDeleted;

  // Derived properties
  bool get isParent => parentId == null;
  bool get isChild => parentId != null;
  bool get isExpense => type == CategoryType.expense;
  bool get isIncome => type == CategoryType.income;
  bool get needsSync => syncId == null || (updatedAt != null && syncedAt != null && updatedAt!.isAfter(syncedAt!));
  bool get isSynced => syncId != null && syncedAt != null;
  
  String get displayIcon => icon ?? (isExpense ? 'expense' : 'income');
  String get displayColor => color ?? (isExpense ? 'red' : 'green');
  String get displayName => name.isNotEmpty ? name : 'Unnamed Category';
  String get statusText => isActive ? 'Active' : 'Inactive';
  String get typeText => type.displayName;

  Category copyWith({
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
    return Category(
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

  @override
  String toString() {
    return 'Category(id: $id, name: $name, type: $type, isActive: $isActive)';
  }
}

/// Category statistics entity
class CategoryStats extends Equatable {
  const CategoryStats({
    required this.categoryId,
    required this.categoryName,
    required this.totalAmount,
    required this.transactionCount,
    required this.averageAmount,
    required this.percentage,
    required this.periodStart,
    required this.periodEnd,
    this.monthlyBreakdown = const {},
  });

  final String categoryId;
  final String categoryName;
  final double totalAmount;
  final int transactionCount;
  final double averageAmount;
  final double percentage;
  final DateTime periodStart;
  final DateTime periodEnd;
  final Map<String, double> monthlyBreakdown; // month -> amount

  // Derived properties
  bool get hasTransactions => transactionCount > 0;
  bool get isSignificant => percentage >= 5.0; // 5% or more
  String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';
  String get formattedAmount => totalAmount.toStringAsFixed(2);
  String get formattedAverage => averageAmount.toStringAsFixed(2);
  
  Duration get periodDuration => periodEnd.difference(periodStart);
  int get periodDays => periodDuration.inDays;
  double get dailyAverage => periodDays > 0 ? totalAmount / periodDays : 0.0;
  
  List<String> get activeMonths => monthlyBreakdown.keys.where((month) => monthlyBreakdown[month]! > 0).toList();
  double get highestMonthlyAmount => monthlyBreakdown.values.isNotEmpty ? monthlyBreakdown.values.reduce((a, b) => a > b ? a : b) : 0.0;
  double get lowestMonthlyAmount => monthlyBreakdown.values.isNotEmpty ? monthlyBreakdown.values.reduce((a, b) => a < b ? a : b) : 0.0;

  CategoryStats copyWith({
    String? categoryId,
    String? categoryName,
    double? totalAmount,
    int? transactionCount,
    double? averageAmount,
    double? percentage,
    DateTime? periodStart,
    DateTime? periodEnd,
    Map<String, double>? monthlyBreakdown,
  }) {
    return CategoryStats(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      totalAmount: totalAmount ?? this.totalAmount,
      transactionCount: transactionCount ?? this.transactionCount,
      averageAmount: averageAmount ?? this.averageAmount,
      percentage: percentage ?? this.percentage,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      monthlyBreakdown: monthlyBreakdown ?? this.monthlyBreakdown,
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

  @override
  String toString() {
    return 'CategoryStats(categoryId: $categoryId, name: $categoryName, amount: $totalAmount, count: $transactionCount)';
  }
}

/// Category query parameters for filtering and sorting
class CategoryQuery {
  const CategoryQuery({
    this.userId,
    this.types,
    this.parentId,
    this.isActive,
    this.isDefault,
    this.searchText,
    this.sortBy = CategorySortBy.sortOrder,
    this.sortOrder = SortOrder.ascending,
    this.limit,
    this.offset,
    this.includeDeleted = false,
  });

  final String? userId;
  final List<CategoryType>? types;
  final String? parentId; // null for root categories, specific ID for children
  final bool? isActive;
  final bool? isDefault;
  final String? searchText;
  final CategorySortBy sortBy;
  final SortOrder sortOrder;
  final int? limit;
  final int? offset;
  final bool includeDeleted;

  CategoryQuery copyWith({
    String? userId,
    List<CategoryType>? types,
    String? parentId,
    bool? isActive,
    bool? isDefault,
    String? searchText,
    CategorySortBy? sortBy,
    SortOrder? sortOrder,
    int? limit,
    int? offset,
    bool? includeDeleted,
  }) {
    return CategoryQuery(
      userId: userId ?? this.userId,
      types: types ?? this.types,
      parentId: parentId ?? this.parentId,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      searchText: searchText ?? this.searchText,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }
}

/// Category sorting options
enum CategorySortBy {
  name('name'),
  type('type'),
  sortOrder('sort_order'),
  createdAt('created_at'),
  updatedAt('updated_at');

  const CategorySortBy(this.value);
  final String value;
}

/// Sort order enumeration
enum SortOrder {
  ascending('asc'),
  descending('desc');

  const SortOrder(this.value);
  final String value;
}