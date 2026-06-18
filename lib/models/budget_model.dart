class BudgetModel {
  final double monthlyBudget;
  final double monthlySpent;
  final double singleLimit;
  final int transactionCount;
  final double averageTransactionAmount;

  const BudgetModel({
    required this.monthlyBudget,
    required this.monthlySpent,
    required this.singleLimit,
    required this.transactionCount,
    required this.averageTransactionAmount,
  });

  factory BudgetModel.fromMyPageJson(
    Map<String, dynamic> json,
  ) {
    final monthly = json['monthlyBudget'] as Map<String, dynamic>? ?? {};
    final summary = json['monthlyTransactionSummary'] as Map<String, dynamic>? ?? {};
    return BudgetModel(
      monthlyBudget: (monthly['limitAmount'] as num?)?.toDouble() ?? 0.0,
      monthlySpent: (monthly['usedAmount'] as num?)?.toDouble() ?? 0.0,
      singleLimit: (json['perPaymentLimit'] as num?)?.toDouble() ?? 0.0,
      transactionCount: (summary['transactionCount'] as num?)?.toInt() ?? 0,
      averageTransactionAmount: (summary['averageTransactionAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  BudgetModel copyWith({
    double? monthlyBudget,
    double? monthlySpent,
    double? singleLimit,
    int? transactionCount,
    double? averageTransactionAmount,
  }) {
    return BudgetModel(
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      monthlySpent: monthlySpent ?? this.monthlySpent,
      singleLimit: singleLimit ?? this.singleLimit,
      transactionCount: transactionCount ?? this.transactionCount,
      averageTransactionAmount: averageTransactionAmount ?? this.averageTransactionAmount,
    );
  }
}