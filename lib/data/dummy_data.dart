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
);

const dummyPaymentHistory = [
  PaymentModel(
    title: '릴스 분석 요청',
    time: '오늘 15:42',
    amount: '0.006 USDC',
  ),
  PaymentModel(
    title: '이미지 생성',
    time: '오늘 14:17',
    amount: '0.009 USDC',
  ),
  PaymentModel(
    title: '데이터 분석 요청',
    time: '오늘 11:03',
    amount: '0.005 USDC',
  ),
  PaymentModel(
    title: 'AI 음성 생성',
    time: '어제 21:30',
    amount: '0.003 USDC',
  ),
];