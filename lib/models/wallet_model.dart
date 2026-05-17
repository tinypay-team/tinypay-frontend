class WalletModel {
  final double balance;
  final String walletAddress;
  final bool isConnected;

  const WalletModel({
    required this.balance,
    required this.walletAddress,
    required this.isConnected,
  });
}