class WalletModel {
  final double balance;
  final String walletAddress;
  final bool isConnected;

  const WalletModel({
    required this.balance,
    required this.walletAddress,
    required this.isConnected,
  });

  WalletModel copyWith({
    double? balance,
    String? walletAddress,
    bool? isConnected,
  }) {
    return WalletModel(
      balance: balance ?? this.balance,
      walletAddress: walletAddress ?? this.walletAddress,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}