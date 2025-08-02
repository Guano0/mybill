import 'package:equatable/equatable.dart';
import '../../domain/entities/budget.dart';

/// Budget model for data layer
class BudgetModel extends Equatable {
  const BudgetModel({
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
  final String period; // BudgetPeriod enum value
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

  /// Create from JSON
  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      amount: (json['amount'] as num).toDouble(),
      period: json['period'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      categoryIds: (json['category_ids'] as List<dynamic>?)?.cast<String>() ?? [],
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      remaining: (json['remaining'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
      alertThreshold: (json['alert_threshold'] as num?)?.toDouble() ?? 80.0,
      isAlertEnabled: json['is_alert_enabled'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      syncId: json['sync_id'] as String?,
      syncedAt: json['synced_at'] != null ? DateTime.parse(json['synced_at'] as String) : null,
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'amount': amount,
      'period': period,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'category_ids': categoryIds,
      'spent': spent,
      'remaining': remaining,
      'is_active': isActive,
      'alert_threshold': alertThreshold,
      'is_alert_enabled': isAlertEnabled,
      'metadata': metadata,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'sync_id': syncId,
      'synced_at': syncedAt?.toIso8601String(),
      'is_deleted': isDeleted,
    };
  }

  /// Convert to SQLite map
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'amount': amount,
      'period': period,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate.millisecondsSinceEpoch,
      'category_ids': categoryIds.join(','),
      'spent': spent,
      'remaining': remaining,
      'is_active': isActive ? 1 : 0,
      'alert_threshold': alertThreshold,
      'is_alert_enabled': isAlertEnabled ? 1 : 0,
      'metadata': metadata.isNotEmpty ? metadata.toString() : null,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'sync_id': syncId,
      'synced_at': syncedAt?.millisecondsSinceEpoch,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  /// Create from SQLite map
  factory BudgetModel.fromSqlite(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      amount: (map['amount'] as num).toDouble(),
      period: map['period'] as String,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int),
      categoryIds: (map['category_ids'] as String?)?.split(',').where((id) => id.isNotEmpty).toList() ?? [],
      spent: (map['spent'] as num?)?.toDouble() ?? 0.0,
      remaining: (map['remaining'] as num?)?.toDouble() ?? 0.0,
      isActive: (map['is_active'] as int?) == 1,
      alertThreshold: (map['alert_threshold'] as num?)?.toDouble() ?? 80.0,
      isAlertEnabled: (map['is_alert_enabled'] as int?) == 1,
      metadata: map['metadata'] != null ? {} : {}, // TODO: Parse metadata string
      createdAt: map['created_at'] != null ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int) : null,
      updatedAt: map['updated_at'] != null ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int) : null,
      syncId: map['sync_id'] as String?,
      syncedAt: map['synced_at'] != null ? DateTime.fromMillisecondsSinceEpoch(map['synced_at'] as int) : null,
      isDeleted: (map['is_deleted'] as int?) == 1,
    );
  }

  /// Convert to domain entity
  Budget toEntity() {
    return Budget(
      id: id,
      userId: userId,
      name: name,
      description: description,
      amount: amount,
      period: BudgetPeriod.fromString(period),
      startDate: startDate,
      endDate: endDate,
      categoryIds: categoryIds,
      spent: spent,
      remaining: remaining,
      isActive: isActive,
      alertThreshold: alertThreshold,
      isAlertEnabled: isAlertEnabled,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncId: syncId,
      syncedAt: syncedAt,
      isDeleted: isDeleted,
    );
  }

  /// Create from domain entity
  factory BudgetModel.fromEntity(Budget entity) {
    return BudgetModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      description: entity.description,
      amount: entity.amount,
      period: entity.period.value,
      startDate: entity.startDate,
      endDate: entity.endDate,
      categoryIds: entity.categoryIds,
      spent: entity.spent,
      remaining: entity.remaining,
      isActive: entity.isActive,
      alertThreshold: entity.alertThreshold,
      isAlertEnabled: entity.isAlertEnabled,
      metadata: entity.metadata,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncId: entity.syncId,
      syncedAt: entity.syncedAt,
      isDeleted: entity.isDeleted,
    );
  }

  BudgetModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    double? amount,
    String? period,
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
    return BudgetModel(
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
    return 'BudgetModel(id: $id, name: $name, amount: $amount, period: $period)';
  }
}

/// Budget statistics model for data layer
class BudgetStatsModel extends Equatable {
  const BudgetStatsModel({
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

  /// Create from JSON
  factory BudgetStatsModel.fromJson(Map<String, dynamic> json) {
    return BudgetStatsModel(
      budgetId: json['budget_id'] as String,
      budgetName: json['budget_name'] as String,
      totalBudget: (json['total_budget'] as num).toDouble(),
      totalSpent: (json['total_spent'] as num).toDouble(),
      totalRemaining: (json['total_remaining'] as num).toDouble(),
      spentPercentage: (json['spent_percentage'] as num).toDouble(),
      remainingPercentage: (json['remaining_percentage'] as num).toDouble(),
      isOverBudget: json['is_over_budget'] as bool,
      overBudgetAmount: (json['over_budget_amount'] as num).toDouble(),
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      dailySpending: (json['daily_spending'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          ) ??
          {},
      categoryBreakdown: (json['category_breakdown'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          ) ??
          {},
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'budget_id': budgetId,
      'budget_name': budgetName,
      'total_budget': totalBudget,
      'total_spent': totalSpent,
      'total_remaining': totalRemaining,
      'spent_percentage': spentPercentage,
      'remaining_percentage': remainingPercentage,
      'is_over_budget': isOverBudget,
      'over_budget_amount': overBudgetAmount,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'daily_spending': dailySpending,
      'category_breakdown': categoryBreakdown,
    };
  }

  /// Convert to domain entity
  BudgetStats toEntity() {
    return BudgetStats(
      budgetId: budgetId,
      budgetName: budgetName,
      totalBudget: totalBudget,
      totalSpent: totalSpent,
      totalRemaining: totalRemaining,
      spentPercentage: spentPercentage,
      remainingPercentage: remainingPercentage,
      isOverBudget: isOverBudget,
      overBudgetAmount: overBudgetAmount,
      periodStart: periodStart,
      periodEnd: periodEnd,
      dailySpending: dailySpending,
      categoryBreakdown: categoryBreakdown,
    );
  }

  /// Create from domain entity
  factory BudgetStatsModel.fromEntity(BudgetStats entity) {
    return BudgetStatsModel(
      budgetId: entity.budgetId,
      budgetName: entity.budgetName,
      totalBudget: entity.totalBudget,
      totalSpent: entity.totalSpent,
      totalRemaining: entity.totalRemaining,
      spentPercentage: entity.spentPercentage,
      remainingPercentage: entity.remainingPercentage,
      isOverBudget: entity.isOverBudget,
      overBudgetAmount: entity.overBudgetAmount,
      periodStart: entity.periodStart,
      periodEnd: entity.periodEnd,
      dailySpending: entity.dailySpending,
      categoryBreakdown: entity.categoryBreakdown,
    );
  }

  BudgetStatsModel copyWith({
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
    return BudgetStatsModel(
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
    return 'BudgetStatsModel(budgetId: $budgetId, name: $budgetName, spent: $totalSpent/$totalBudget)';
  }
}