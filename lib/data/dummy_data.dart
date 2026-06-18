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
  monthlySpent: 0.023,
  singleLimit: 0.05,
  transactionCount: 0,
  averageTransactionAmount: 0.0,
);

const dummyPaymentHistory = [
  PaymentModel(title: '릴스 분석 요청', rawTime: '', paidAmount: 0.006),
  PaymentModel(title: '이미지 생성', rawTime: '', paidAmount: 0.009),
  PaymentModel(title: '데이터 분석 요청', rawTime: '', paidAmount: 0.005),
  PaymentModel(title: 'AI 음성 생성', rawTime: '', paidAmount: 0.003),
];