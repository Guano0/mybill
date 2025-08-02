import 'package:equatable/equatable.dart';

/// Budget period enumeration
enum BudgetPeriod {
  daily('daily', 'Daily', 1),
  weekly('weekly', 'Weekly', 7),
  monthly('monthly', 'Monthly', 30),
  quarterly('quarterly', 'Quarterly', 90),
  yearly('yearly', 'Yearly', 365);

  const BudgetPeriod(this.value, this.displayName, this.days);

  final String value;
  final String displayName;
  final int days;

  static BudgetPeriod fromString(String value) {
    return BudgetPeriod.values.firstWhere(
      (period) => period.value == value,
      orElse: () => BudgetPeriod.monthly,
    );
  }
}

/// Core Budget entity for domain layer
class Budget extends Equatable {
  const Budget({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.description,
    this.categoryIds = const [],
    this.spent = 0.0,
    this.remaining = 0.0,
    this.isActive = true,
    this.alertThreshold = 80.0,
    this.isAlertEnabled = true,
    this.metadata = const {},
    this.createdAt,
    this.updatedAt,
    this.syncId,
    this.syncedAt,
    this.isDeleted = false,
  });

  final String id;
  final String userId;
  final String name;
  final String? description;
  final double amount;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> categoryIds;
  final double spent;
  final double remaining;
  final bool isActive;
  final double alertThreshold; // percentage (0-100)
  final bool isAlertEnabled;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? syncId;
  final DateTime? syncedAt;
  final bool isDeleted;

  // Derived properties
  double get spentPercentage => amount > 0 ? (spent / amount) * 100 : 0.0;
  double get remainingPercentage => amount > 0 ? (remaining / amount) * 100 : 0.0;
  bool get isOverBudget => spent > amount;
  double get overBudgetAmount => isOverBudget ? spent - amount : 0.0;
  bool get isNearLimit => spentPercentage >= alertThreshold;
  bool get shouldAlert => isAlertEnabled && (isNearLimit || isOverBudget);
  
  Duration get duration => endDate.difference(startDate);
  int get totalDays => duration.inDays;
  int get remainingDays => endDate.difference(DateTime.now()).inDays.clamp(0, totalDays);
  int get elapsedDays => totalDays - remainingDays;
  
  double get dailyBudget => totalDays > 0 ? amount / totalDays : 0.0;
  double get dailySpent => elapsedDays > 0 ? spent / elapsedDays : 0.0;
  double get dailyRemaining => remainingDays > 0 ? remaining / remainingDays : 0.0;
  
  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isUpcoming => DateTime.now().isBefore(startDate);
  bool get isCurrent => !isExpired && !isUpcoming;
  
  String get statusText {
    if (isExpired) return 'Expired';
    if (isUpcoming) return 'Upcoming';
    if (isOverBudget) return 'Over Budget';
    if (isNearLimit) return 'Near Limit';
    return 'On Track';
  }
  
  String get progressText => '${spentPercentage.toStringAsFixed(1)}%';
  String get formattedAmount => amount.toStringAsFixed(2);
  String get formattedSpent => spent.toStringAsFixed(2);
  String get formattedRemaining => remaining.toStringAsFixed(2);
  
  bool get hasCategories => categoryIds.isNotEmpty;
  bool get isAllCategories => categoryIds.isEmpty;
  bool get needsSync => syncId == null || (updatedAt != null && syncedAt != null && updatedAt!.isAfter(syncedAt!));
  bool get isSynced => syncId != null && syncedAt != null;

  Budget copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    double? amount,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categoryIds,
    double? spent,
    double? remaining,
    bool? isActive,
    double? alertThreshold,
    bool? isAlertEnabled,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncId,
    DateTime? syncedAt,
    bool? isDeleted,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryIds: categoryIds ?? this.categoryIds,
      spent: spent ?? this.spent,
      remaining: remaining ?? this.remaining,
      isActive: isActive ?? this.isActive,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      isAlertEnabled: isAlertEnabled ?? this.isAlertEnabled,
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
        userId,
        name,
        description,
        amount,
        period,
        startDate,
        endDate,
        categoryIds,
        spent,
        remaining,
        isActive,
        alertThreshold,
        isAlertEnabled,
        metadata,
        createdAt,
        updatedAt,
        syncId,
        syncedAt,
        isDeleted,
      ];

  @override
  String toString() {
    return 'Budget(id: $id, name: $name, amount: $amount, period: $period)';
  }
}

/// Budget statistics entity
class BudgetStats extends Equatable {
  const BudgetStats({
    required this.budgetId,
    required this.budgetName,
    required this.totalBudget,
    required this.totalSpent,
    required this.totalRemaining,
    required this.spentPercentage,
    required this.remainingPercentage,
    required this.isOverBudget,
    required this.overBudgetAmount,
    required this.periodStart,
    required this.periodEnd,
    this.dailySpending = const {},
    this.categoryBreakdown = const {},
  });

  final String budgetId;
  final String budgetName;
  final double totalBudget;
  final double totalSpent;
  final double totalRemaining;
  final double spentPercentage;
  final double remainingPercentage;
  final bool isOverBudget;
  final double overBudgetAmount;
  final DateTime periodStart;
  final DateTime periodEnd;
  final Map<String, double> dailySpending; // date -> amount
  final Map<String, double> categoryBreakdown; // categoryId -> amount

  // Derived properties
  bool get hasSpending => totalSpent > 0;
  bool get isOnTrack => !isOverBudget && spentPercentage <= 80.0;
  bool get isNearLimit => spentPercentage >= 80.0 && !isOverBudget;
  
  Duration get periodDuration => periodEnd.difference(periodStart);
  int get totalDays => periodDuration.inDays;
  int get remainingDays => periodEnd.difference(DateTime.now()).inDays.clamp(0, totalDays);
  int get elapsedDays => totalDays - remainingDays;
  
  double get dailyAverage => elapsedDays > 0 ? totalSpent / elapsedDays : 0.0;
  double get projectedTotal => totalDays > 0 ? (totalSpent / elapsedDays) * totalDays : 0.0;
  double get recommendedDailySpending => remainingDays > 0 ? totalRemaining / remainingDays : 0.0;
  
  String get statusText {
    if (isOverBudget) return 'Over Budget';
    if (isNearLimit) return 'Near Limit';
    if (isOnTrack) return 'On Track';
    return 'Good';
  }
  
  String get formattedSpentPercentage => '${spentPercentage.toStringAsFixed(1)}%';
  String get formattedTotalBudget => totalBudget.toStringAsFixed(2);
  String get formattedTotalSpent => totalSpent.toStringAsFixed(2);
  String get formattedTotalRemaining => totalRemaining.toStringAsFixed(2);
  String get formattedDailyAverage => dailyAverage.toStringAsFixed(2);
  String get formattedProjectedTotal => projectedTotal.toStringAsFixed(2);
  
  List<String> get activeDays => dailySpending.keys.where((date) => dailySpending[date]! > 0).toList();
  double get highestDailySpending => dailySpending.values.isNotEmpty ? dailySpending.values.reduce((a, b) => a > b ? a : b) : 0.0;
  double get lowestDailySpending => dailySpending.values.isNotEmpty ? dailySpending.values.reduce((a, b) => a < b ? a : b) : 0.0;
  
  List<String> get topCategories => categoryBreakdown.entries
      .where((entry) => entry.value > 0)
      .toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..map((entry) => entry.key)
      .toList();
  
  String? get topCategory => topCategories.isNotEmpty ? topCategories.first : null;
  double get topCategoryAmount => topCategory != null ? categoryBreakdown[topCategory!] ?? 0.0 : 0.0;

  BudgetStats copyWith({
    String? budgetId,
    String? budgetName,
    double? totalBudget,
    double? totalSpent,
    double? totalRemaining,
    double? spentPercentage,
    double? remainingPercentage,
    bool? isOverBudget,
    double? overBudgetAmount,
    DateTime? periodStart,
    DateTime? periodEnd,
    Map<String, double>? dailySpending,
    Map<String, double>? categoryBreakdown,
  }) {
    return BudgetStats(
      budgetId: budgetId ?? this.budgetId,
      budgetName: budgetName ?? this.budgetName,
      totalBudget: totalBudget ?? this.totalBudget,
      totalSpent: totalSpent ?? this.totalSpent,
      totalRemaining: totalRemaining ?? this.totalRemaining,
      spentPercentage: spentPercentage ?? this.spentPercentage,
      remainingPercentage: remainingPercentage ?? this.remainingPercentage,
      isOverBudget: isOverBudget ?? this.isOverBudget,
      overBudgetAmount: overBudgetAmount ?? this.overBudgetAmount,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      dailySpending: dailySpending ?? this.dailySpending,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
    );
  }

  @override
  List<Object?> get props => [
        budgetId,
        budgetName,
        totalBudget,
        totalSpent,
        totalRemaining,
        spentPercentage,
        remainingPercentage,
        isOverBudget,
        overBudgetAmount,
        periodStart,
        periodEnd,
        dailySpending,
        categoryBreakdown,
      ];

  @override
  String toString() {
    return 'BudgetStats(budgetId: $budgetId, name: $budgetName, spent: $totalSpent/$totalBudget)';
  }
}

/// Budget query parameters for filtering and sorting
class BudgetQuery {
  const BudgetQuery({
    this.userId,
    this.isActive,
    this.periods,
    this.categoryIds,
    this.isOverBudget,
    this.isNearLimit,
    this.searchText,
    this.dateRange,
    this.sortBy = BudgetSortBy.createdAt,
    this.sortOrder = SortOrder.descending,
    this.limit,
    this.offset,
    this.includeDeleted = false,
  });

  final String? userId;
  final bool? isActive;
  final List<BudgetPeriod>? periods;
  final List<String>? categoryIds;
  final bool? isOverBudget;
  final bool? isNearLimit;
  final String? searchText;
  final DateRange? dateRange;
  final BudgetSortBy sortBy;
  final SortOrder sortOrder;
  final int? limit;
  final int? offset;
  final bool includeDeleted;

  BudgetQuery copyWith({
    String? userId,
    bool? isActive,
    List<BudgetPeriod>? periods,
    List<String>? categoryIds,
    bool? isOverBudget,
    bool? isNearLimit,
    String? searchText,
    DateRange? dateRange,
    BudgetSortBy? sortBy,
    SortOrder? sortOrder,
    int? limit,
    int? offset,
    bool? includeDeleted,
  }) {
    return BudgetQuery(
      userId: userId ?? this.userId,
      isActive: isActive ?? this.isActive,
      periods: periods ?? this.periods,
      categoryIds: categoryIds ?? this.categoryIds,
      isOverBudget: isOverBudget ?? this.isOverBudget,
      isNearLimit: isNearLimit ?? this.isNearLimit,
      searchText: searchText ?? this.searchText,
      dateRange: dateRange ?? this.dateRange,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }
}

/// Budget sorting options
enum BudgetSortBy {
  name('name'),
  amount('amount'),
  spent('spent'),
  remaining('remaining'),
  spentPercentage('spent_percentage'),
  startDate('start_date'),
  endDate('end_date'),
  createdAt('created_at'),
  updatedAt('updated_at');

  const BudgetSortBy(this.value);
  final String value;
}

/// Sort order enumeration
enum SortOrder {
  ascending('asc'),
  descending('desc');

  const SortOrder(this.value);
  final String value;
}

/// Date range class for filtering
class DateRange extends Equatable {
  const DateRange({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;

  bool contains(DateTime date) {
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
           date.isBefore(end.add(const Duration(days: 1)));
  }

  Duration get duration => end.difference(start);
  int get days => duration.inDays;

  @override
  List<Object?> get props => [start, end];

  @override
  String toString() {
    return 'DateRange(start: $start, end: $end)';
  }
}