import '../data/dummy_data.dart';
import '../models/budget_model.dart';
import '../models/payment_model.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';
import 'wallet_state.dart';

class MyPageService {
  Future<WalletModel> getWallet() async {
  await Future.delayed(const Duration(milliseconds: 300));

  if (WalletState.isWalletCreated) {
    return const WalletModel(
      balance: 0,
      walletAddress: '0x12A4...9F3D',
      isConnected: true,
    );
  }

  return dummyWallet;
}

  Future<UserModel> getUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return dummyUser;
  }

  Future<BudgetModel> getBudget() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return dummyBudget;
  }

  Future<List<PaymentModel>> getPaymentHistory() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return dummyPaymentHistory;
  }
}