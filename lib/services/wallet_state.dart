import '../models/wallet_model.dart';

class WalletState {
  static WalletModel wallet = const WalletModel(
    balance: 0,
    walletAddress: '',
    isConnected: false,
  );

  static bool get isWalletCreated => wallet.isConnected;

  static void connectWallet() {
    wallet = const WalletModel(
      balance: 0,
      walletAddress: '0x12A4...9F3D',
      isConnected: true,
    );
  }

  static void disconnectWallet() {
    wallet = const WalletModel(
      balance: 0,
      walletAddress: '',
      isConnected: false,
    );
  }

  static void charge(double amount) {
    wallet = wallet.copyWith(
      balance: wallet.balance + amount,
    );
  }
}