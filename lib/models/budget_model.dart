class BudgetModel {
  final double monthlyBudget;
  final double monthlySpent;
  final double singleLimit;

  const BudgetModel({
    required this.monthlyBudget,
    required this.monthlySpent,
    required this.singleLimit,
  });

  factory BudgetModel.fromMyPageJson(
    Map<String, dynamic> json,
  ) {
    return BudgetModel(
      monthlyBudget:
          (json['monthlyBudget']['limitAmount'] as num).toDouble(),
      monthlySpent:
          (json['monthlyBudget']['usedAmount'] as num).toDouble(),
      singleLimit:
          (json['perPaymentLimit'] as num).toDouble(),
    );
  }

  BudgetModel copyWith({
    double? monthlyBudget,
    double? monthlySpent,
    double? singleLimit,
  }) {
    return BudgetModel(
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      monthlySpent: monthlySpent ?? this.monthlySpent,
      singleLimit: singleLimit ?? this.singleLimit,
    );
  }
}