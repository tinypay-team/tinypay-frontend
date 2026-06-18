class PaymentModel {
  final int? paymentId;
  final String title;
  final String rawTime; // ISO 원본
  final double paidAmount;
  final String? paymentStatus;

  const PaymentModel({
    this.paymentId,
    required this.title,
    required this.rawTime,
    required this.paidAmount,
    this.paymentStatus,
  });

  // 기존 코드 호환용 getter
  String get time => rawTime;
  String get amount => '$paidAmount USDC';

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final paid = (json['paidAmount'] as num?)?.toDouble() ?? 0;
    // API가 'ExcutedAt'(오타) or 'executedAt' 둘 다 처리
    final rawTime = (json['executedAt'] ?? json['ExcutedAt'] ?? '') as String;

    return PaymentModel(
      paymentId: json['paymentId'] as int?,
      title: json['serviceName'] ?? '',
      rawTime: rawTime,
      paidAmount: paid,
      paymentStatus: json['paymentStatus'] as String?,
    );
  }
}