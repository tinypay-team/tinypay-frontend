class BudgetModel {
  final double monthlyBudget;
  final double monthlySpent;
  final double singleLimit;

  const BudgetModel({
    required this.monthlyBudget,
    required this.monthlySpent,
    required this.singleLimit,
  });

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