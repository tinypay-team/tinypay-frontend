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
import '../dialogs/mypage/wallet_dialog.dart';
import '../theme/app_colors.dart';
import 'wallet/phone_verification_screen.dart';
import 'wallet/charge_screen.dart';
import '../widgets/mypage/auto_payment_card.dart';
import '../widgets/mypage/ai_service_usage_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  
  final MyPageService _service = MyPageService();
  bool autoPaymentEnabled = true;

  void _showWalletDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return WalletDialog(
        wallet: wallet!,
        autoPaymentEnabled: autoPaymentEnabled,
        onToggleAutoPayment: () {
          setState(() {
            autoPaymentEnabled = !autoPaymentEnabled;
          });

          Navigator.pop(context);
          _showWalletDialog();
        },
      );
    },
  );
}

Future<void> _goToPhoneVerification() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const PhoneVerificationScreen(),
    ),
  );

  if (result == true) {
    setState(() {
      wallet = const WalletModel(
        balance: 0,
        walletAddress: '0x12A4...9F3D',
        isConnected: true,
      );
    });
  }
}

Future<void> _goToChargeScreen() async {
  final chargedAmount = await Navigator.push<double>(
    context,
    MaterialPageRoute(
      builder: (_) => const ChargeScreen(),
    ),
  );

  if (chargedAmount != null) {
    setState(() {
      wallet = wallet!.copyWith(
        balance: wallet!.balance + chargedAmount,
      );
    });
  }
}

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
  final parentContext = context;

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return ProfileDialog(
        userName: user!.name,
        userEmail: user!.email,
        selectedAvatar: user!.avatar,
        onEditProfileTap: () {
          Navigator.pop(dialogContext);
          _showEditProfileDialog();
        },
        onWithdrawTap: _showWithdrawDialog,
        onLogoutTap: () async {
          Navigator.pop(dialogContext);

          try {
            final authService = AuthService();
            await authService.logout();
          } catch (e) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('accessToken');
            await prefs.remove('refreshToken');
            await prefs.setBool('isLoggedIn', false);
          }

          if (!mounted) return;

          Navigator.pushAndRemoveUntil(
            parentContext,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
            (route) => false,
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
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
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
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
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
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
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


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'My Page',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _showProfileDialog,
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              child: ProfileAvatar(
                selectedAvatar: user!.avatar,
                size: 50,
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
              onChargeTap: _goToChargeScreen,
              onWalletTap: wallet!.isConnected
                ? _showWalletDialog
                : _goToPhoneVerification,
            ),
            const SizedBox(height: 18),
            AutoPaymentCard(
              enabled: autoPaymentEnabled,
              onToggle: () {
                setState(() {
                  autoPaymentEnabled = !autoPaymentEnabled;
                });
              },
            ),
            const SizedBox(height: 18),
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

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text(
      'AI 서비스 사용 내역',
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    ),

    GestureDetector(
      onTap: _showPaymentHistoryDialog,
      child: const Text(
        '전체보기',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  ],
),

const SizedBox(height: 16),

Container(
  padding: const EdgeInsets.fromLTRB(18, 18, 18, 2),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(28),
    border: Border.all(color: AppColors.border),
  ),
  child: const Column(
    children: [
      AiServiceUsageItem(
        icon: Icons.video_collection_rounded,
        title: '릴스 분석 요청',
        time: '오늘 15:42',
        amount: '0.006 USDC',
        iconBackground: Color(0xFFFFEAF3),
        iconColor: Color(0xFFE84393),
      ),

      AiServiceUsageItem(
        icon: Icons.image_rounded,
        title: '이미지 생성',
        time: '오늘 14:17',
        amount: '0.009 USDC',
        iconBackground: Color(0xFFEAF0FF),
        iconColor: AppColors.primary,
      ),

      AiServiceUsageItem(
        icon: Icons.bar_chart_rounded,
        title: '데이터 분석 요청',
        time: '오늘 11:03',
        amount: '0.005 USDC',
        iconBackground: Color(0xFFEFF8FF),
        iconColor: Color(0xFF3B82F6),
      ),

      AiServiceUsageItem(
        icon: Icons.mic_rounded,
        title: 'AI 음성 생성',
        time: '어제 21:30',
        amount: '0.003 USDC',
        iconBackground: Color(0xFFF3F0FF),
        iconColor: Color(0xFF7C3AED),
      ),
    ],
  ),
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