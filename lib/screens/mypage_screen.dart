import 'package:flutter/material.dart';
import '../widgets/mypage/stat_card.dart';
import '../widgets/mypage/payment_item.dart';
import '../widgets/mypage/balance_card.dart';
import '../widgets/mypage/budget_card.dart';
import '../widgets/mypage/limit_card.dart';
import '../widgets/mypage/profile_avatar.dart';
import '../widgets/mypage/payment_section_header.dart';
import '../dialogs/mypage/budget_dialog.dart';
import '../dialogs/mypage/limit_dialog.dart';
import '../dialogs/mypage/payment_history_dialog.dart';
import '../dialogs/mypage/profile_dialog.dart';
import '../dialogs/mypage/edit_profile_dialog.dart';
import '../dialogs/mypage/withdraw_dialog.dart';
import '../models/payment_model.dart';
import '../models/wallet_model.dart';
import '../models/user_model.dart';
import '../models/budget_model.dart';
import '../services/mypage_service.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  
  final MyPageService _service = MyPageService();

  WalletModel? wallet;
  UserModel? user;
  BudgetModel? budget;
  List<PaymentModel> paymentHistory = [];

  final List<String> avatarList = [
    '🐼',
    '🦊',
    '🐱',
    '🐶',
    '🐰',
    '🐻',
    '🐯',
    '🦁',
    '🐸',
    '🐷',
    '🐨',
    '🐵',
  ];

  void _showProfileDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return ProfileDialog(
        userName: user!.name,
        userEmail: user!.email,
        selectedAvatar: user!.avatar,
        onEditProfileTap: () {
          Navigator.pop(context);
          _showEditProfileDialog();
        },
        onWithdrawTap: _showWithdrawDialog,
        onLogoutTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그아웃 기능은 추후 연결 예정입니다.')),
          );
        },
      );
    },
  );
}

  void _showEditProfileDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return EditProfileDialog(
        userName: user!.name,
        selectedAvatar: user!.avatar,
        avatarList: avatarList,
        onSave: (newName, newAvatar) {
          setState(() {
            user = user!.copyWith(
              name: newName,
              avatar: newAvatar,
            );
          });
        },
      );
    },
  );
}

  void _showWithdrawDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return WithdrawDialog(
        onConfirm: () {
          Navigator.pop(context);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('...')),
          );
        },
      );
    },
  );
}

  void _showBudgetDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return BudgetDialog(
        monthlyBudget: budget!.monthlyBudget,
        monthlySpent: budget!.monthlySpent,
        onSave: (newBudget) {
          setState(() {
            budget = budget!.copyWith(monthlyBudget: newBudget);
          });
        },
      );
    },
  );
}

  void _showLimitDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return LimitDialog(
        singleLimit: budget!.singleLimit,
        onSave: (newLimit) {
          setState(() {
            budget = budget!.copyWith(singleLimit: newLimit);
          });
        },
      );
    },
  );
}

  void _showPaymentHistoryDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return PaymentHistoryDialog(
        paymentHistory: paymentHistory,
      );
    },
  );
}

  @override
  void initState() {
    super.initState();
    _loadMyPageData();
  }

  Future<void> _loadMyPageData() async {
  final walletData = await _service.getWallet();
  final userData = await _service.getUser();
  final budgetData = await _service.getBudget();
  final historyData = await _service.getPaymentHistory();

  setState(() {
    wallet = walletData;
    user = userData;
    budget = budgetData;
    paymentHistory = historyData;
  });
}

  @override
  Widget build(BuildContext context) {

    if (wallet == null || user == null || budget == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    const primaryColor = Color(0xFF5B5CF6);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'My Page',
          style: TextStyle(
            color: primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _showProfileDialog,
            child: Container(
              margin: const EdgeInsets.only(right: 18),
              child: ProfileAvatar(
                selectedAvatar: user!.avatar,
                size: 48,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BalanceCard(
              isWalletConnected: wallet!.isConnected,
              walletAddress: wallet!.walletAddress,
              balance: wallet!.balance,
              onChargeTap: () {},
            ),
            const SizedBox(height: 22),
            BudgetCard(
              monthlySpent: budget!.monthlySpent,
              monthlyBudget: budget!.monthlyBudget,
              onTap: _showBudgetDialog,
            ),
            const SizedBox(height: 18),
            LimitCard(
              singleLimit: budget!.singleLimit,
              onTap: _showLimitDialog,
            ),
            const SizedBox(height: 24),
            PaymentSectionHeader(
              onViewAllTap: _showPaymentHistoryDialog,
            ),
            const SizedBox(height: 14),
            const PaymentItem(
              icon: Icons.auto_awesome,
              title: 'GPT-4 Text Generation',
              date: '4월 7일 오후 03:29',
              amount: '-USDC 0.02',
              iconBackground: Colors.black,
              iconColor: Colors.white,
            ),
            const SizedBox(height: 12),
            const PaymentItem(
              icon: Icons.image_search_outlined,
              title: 'Image Analysis API',
              date: '4월 7일 오후 01:59',
              amount: '-USDC 0.03',
              iconBackground:  Color(0xFFE9ECFF),
              iconColor: primaryColor,
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: const StatCard(
                    icon: '📊',
                    label: '이번 달 거래',
                    value: '28건',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: const StatCard(
                    icon: '💰',
                    label: '평균 거래액',
                    value: 'USDC 0.015',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}