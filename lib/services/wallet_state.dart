import 'package:shared_preferences/shared_preferences.dart';

import '../models/wallet_model.dart';

class WalletState {
  static WalletModel wallet = const WalletModel(
    balance: 0,
    walletAddress: '',
    isConnected: false,
  );

  static bool get isWalletCreated => wallet.isConnected;

  static Future<void> loadWalletState() async {
    final prefs = await SharedPreferences.getInstance();
    final walletId = prefs.getInt('walletId');

    if (walletId != null) {
      wallet = WalletModel(
        walletId: walletId,
        balance: wallet.balance,
        walletAddress: '0x12A4...9F3D',
        isConnected: true,
        walletStatus: 'ACTIVE',
        autoPaymentEnabled: wallet.autoPaymentEnabled,
      );
    }
  }

  static Future<void> connectWallet({
    required int walletId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('walletId', walletId);

    wallet = WalletModel(
      walletId: walletId,
      balance: 0,
      walletAddress: '0x12A4...9F3D',
      isConnected: true,
      walletStatus: 'ACTIVE',
    );
  }

  static Future<void> disconnectWallet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('walletId');

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