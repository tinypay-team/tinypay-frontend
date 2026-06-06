class WalletModel {
  final int? walletId;
  final double balance;
  final String walletAddress;
  final bool isConnected;
  final String walletStatus;
  final bool autoPaymentEnabled;

  const WalletModel({
    this.walletId,
    required this.balance,
    required this.walletAddress,
    required this.isConnected,
    this.walletStatus = '',
    this.autoPaymentEnabled = false,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      walletId: json['walletId'],
      walletAddress: json['walletAddress'] ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      walletStatus: json['walletStatus'] ?? '',
      autoPaymentEnabled: json['autoPaymentEnabled'] ?? false,
      isConnected: (json['walletAddress'] ?? '').toString().isNotEmpty,
    );
  }

  WalletModel copyWith({
    int? walletId,
    double? balance,
    String? walletAddress,
    bool? isConnected,
    String? walletStatus,
    bool? autoPaymentEnabled,
  }) {
    return WalletModel(
      walletId: walletId ?? this.walletId,
      balance: balance ?? this.balance,
      walletAddress: walletAddress ?? this.walletAddress,
      isConnected: isConnected ?? this.isConnected,
      walletStatus: walletStatus ?? this.walletStatus,
      autoPaymentEnabled:
          autoPaymentEnabled ?? this.autoPaymentEnabled,
    );
  }
}