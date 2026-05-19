import '../models/payment_model.dart';
import '../models/wallet_model.dart';
import '../models/user_model.dart';
import '../models/budget_model.dart';

const dummyWallet = WalletModel(
  balance: 0,
  walletAddress: '',
  isConnected: false,
);

const dummyUser = UserModel(
  name: '김준영',
  email: '2021112090@email.com',
  avatar: '김',
);

const dummyBudget = BudgetModel(
  monthlyBudget: 20.0,
  monthlySpent: 11.5,
  singleLimit: 1.0,
);

const dummyPaymentHistory = [
  PaymentModel(
    title: 'GPT-4 Text Generation',
    time: '5월 7일 오후 04:49',
    amount: 'USDC 0.1',
  ),
  PaymentModel(
    title: 'Image Analysis API',
    time: '5월 7일 오후 03:19',
    amount: 'USDC 0.1',
  ),
];