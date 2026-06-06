class PaymentModel {
  final int? paymentId;
  final String title;
  final String time;
  final String amount;
  final String? paymentStatus;

  const PaymentModel({
    this.paymentId,
    required this.title,
    required this.time,
    required this.amount,
    this.paymentStatus,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
  final paidAmount =
      (json['paidAmount'] as num?)?.toDouble() ?? 0;

  return PaymentModel(
    paymentId: json['paymentId'],
    title: json['serviceName'] ?? '',
    time: json['executedAt'] ?? '',
    amount: '$paidAmount USDC',
    paymentStatus: json['paymentStatus'],
  );
}
}