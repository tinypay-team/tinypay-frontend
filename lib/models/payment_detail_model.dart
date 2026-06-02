class ApiUsageModel {
  final String apiName;
  final double cost;

  const ApiUsageModel({
    required this.apiName,
    required this.cost,
  });

  factory ApiUsageModel.fromJson(Map<String, dynamic> json) {
    return ApiUsageModel(
      apiName: json['apiName'] ?? '',
      cost: (json['cost'] as num?)?.toDouble() ?? 0,
    );
  }
}

class PaymentDetailModel {
  final List<ApiUsageModel> apiUsages;

  const PaymentDetailModel({
    required this.apiUsages,
  });

  factory PaymentDetailModel.fromJson(Map<String, dynamic> json) {
    return PaymentDetailModel(
      apiUsages: (json['apiUsages'] as List<dynamic>? ?? [])
          .map((e) => ApiUsageModel.fromJson(e))
          .toList(),
    );
  }
}