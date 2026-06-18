import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/mypage/stat_card.dart';
import '../widgets/mypage/balance_card.dart';
import '../widgets/mypage/budget_card.dart';
import '../widgets/mypage/limit_card.dart';
import '../widgets/mypage/profile_avatar.dart';
import '../dialogs/mypage/budget_dialog.dart';
import '../dialogs/mypage/limit_dialog.dart';
import 'mypage/payment_history_page.dart';
import '../dialogs/mypage/wallet_dialog.dart';
import '../models/payment_model.dart';
import '../models/wallet_model.dart';
import '../models/user_model.dart';
import '../models/budget_model.dart';
import '../services/mypage_service.dart';
import '../services/wallet_api_service.dart';
import '../theme/app_colors.dart';
import 'wallet/phone_verification_screen.dart';
import 'wallet/charge_screen.dart';
import '../widgets/mypage/ai_service_usage_item.dart';
import 'mypage/profile_page.dart';
import 'mypage/wallet_page.dart';
import '../utils/format_utils.dart';
import '../utils/auto_payment_notifier.dart';
import '../utils/payment_notifier.dart';


class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  
  final MyPageService _service = MyPageService();
  bool autoPaymentEnabled = false;

  Future<void> _goToWalletPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalletPage(
          wallet: wallet!,
          autoPaymentEnabled: autoPaymentEnabled,
          onAutoPaymentChanged: (value) {
            setState(() => autoPaymentEnabled = value);
          },
        ),
      ),
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

  Future<void> _showProfileDialog() async {
  if (user == null) {
    try {
      final userData = await _service.getUser();
      if (!mounted) return;
      setState(() => user = userData);
    } catch (e) {
      print('LOAD USER ERROR: $e');
      return;
    }
  }

  if (!mounted) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProfilePage(
        user: user!,
        onUserUpdated: (updated) {
          setState(() => user = updated);
        },
      ),
    ),
  );
}


  Future<void> _showBudgetDialog() async {
    final newBudget = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BudgetDialog(
        monthlyBudget: budget!.monthlyBudget,
        monthlySpent: budget!.monthlySpent,
      ),
    );

    print('[DIALOG] pop value: $newBudget');
    if (newBudget == null || !mounted) return;

    try {
      final saved = await _service.updateMonthlyBudget(newBudget);
      print('[API] budget saved: $saved');
      if (!mounted) return;
      print('[setState] before: ${budget?.monthlyBudget}');
      setState(() {
        budget = budget!.copyWith(monthlyBudget: saved);
      });
      print('[setState] after: ${budget?.monthlyBudget}');
    } catch (e) {
      print('[ERROR] $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('예산 저장 실패: $e')),
      );
    }
  }

  Future<void> _showLimitDialog() async {
    final newLimit = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LimitDialog(
        singleLimit: budget!.singleLimit,
      ),
    );

    if (newLimit == null || !mounted) return;

    try {
      final saved = await _service.updatePerPaymentLimit(newLimit);
      print('limit saved: $saved');
      if (!mounted) return;
      setState(() {
        budget = budget!.copyWith(singleLimit: saved);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('한도 저장 실패: $e')),
      );
    }
  }

  void _showPaymentHistoryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PaymentHistoryPage(),
      ),
    );
  }
  Future<void> _toggleAutoPayment() async {
    final nextValue = !autoPaymentEnabled;

    try {
      String? pin;

      if (nextValue == true) {
        pin = await _showPinDialog();

        if (pin == null || pin.length != 6) return;
      }

      final savedValue = await WalletApiService().updateAutoPayment(
        enabled: nextValue,
        walletPassword: pin,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('autoPaymentEnabled', savedValue);
      autoPaymentNotifier.value = savedValue;

      if (!mounted) return;

      setState(() {
        autoPaymentEnabled = savedValue;
        wallet = wallet?.copyWith(
          autoPaymentEnabled: savedValue,
        );
      });
    } catch (e) {
      print('UPDATE AUTO PAYMENT ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<String?> _showPinDialog() async {
    final pinController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7FF),
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/tinypay1.png',
                  width: 92,
                  height: 92,
                ),

                const SizedBox(height: 12),

                const Text(
                  '자동결제 활성화',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  '자동결제를 켜려면\n6자리 결제 PIN을 입력해주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                    ),
                    decoration: const InputDecoration(
                      hintText: '••••••',
                      counterText: '',
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(
                              color: AppColors.border,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            '취소',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            final pin = pinController.text.trim();

                            if (pin.length != 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('6자리 PIN을 입력해주세요.'),
                                ),
                              );
                              return;
                            }

                            Navigator.pop(dialogContext, pin);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            '확인',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    paymentCompletedNotifier.addListener(_onPaymentCompleted);
    _loadMyPageData();
  }

  void _onPaymentCompleted() {
    // 결제 완료 시 잔액 포함 마이페이지 데이터 재조회
    _loadMyPageData();
  }

  @override
  void dispose() {
    paymentCompletedNotifier.removeListener(_onPaymentCompleted);
    super.dispose();
  }


  Future<void> _loadMyPageData() async {
  try {
    final results = await Future.wait([
      _service.getMyPage(),
      _service.getUser(),
    ]);

    final myPageData = results[0] as Map<String, dynamic>;
    final userData = results[1] as dynamic;

    final prefs = await SharedPreferences.getInstance();
    final savedAutoPaymentEnabled =
        prefs.getBool('autoPaymentEnabled') ?? false;

    final hasWallet = myPageData['balance'] != null;

    final walletData = WalletModel(
      balance: (myPageData['balance'] as num?)?.toDouble() ?? 0,
      walletAddress: '',
      isConnected: hasWallet,
      walletStatus: hasWallet ? 'ACTIVE' : '',
      autoPaymentEnabled: savedAutoPaymentEnabled,
    );

    final budgetData = BudgetModel.fromMyPageJson(myPageData);
    print('NEW BUDGET FROM API: ${budgetData.monthlyBudget}, LIMIT: ${budgetData.singleLimit}');

    final recentPayments =
        (myPageData['recentPayments'] as List? ?? [])
            .map((e) => PaymentModel.fromJson(e))
            .toList();

    if (!mounted) {
      print('NOT MOUNTED - setState skipped');
      return;
    }

    setState(() {
      wallet = walletData;
      user = userData;
      budget = budgetData;
      paymentHistory = recentPayments;
      autoPaymentEnabled = walletData.autoPaymentEnabled;
    });
    print('setState DONE - budget: ${budget?.monthlyBudget}, limit: ${budget?.singleLimit}');
  } catch (e) {
    print('LOAD MYPAGE ERROR: $e');
  }
}


  @override
  Widget build(BuildContext context) {

    if (wallet == null || budget == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    print('[BUILD] budget.monthlyBudget = ${budget!.monthlyBudget}');
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
                selectedAvatar: user?.avatar ?? '🐼',
                size: 36,
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
                ? _goToWalletPage
                : _goToPhoneVerification,
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
    Row(
      children: [
        const Icon(
          Icons.access_time_rounded,
          color: AppColors.textPrimary,
          size: 22,
        ),
        const SizedBox(width: 8),
        const Text(
          '최근 결제된 서비스',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),

    GestureDetector(
      onTap: _showPaymentHistoryPage,
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
  child: paymentHistory.isEmpty
      ? const Padding(
          padding: EdgeInsets.symmetric(vertical: 34),
          child: Center(
            child: Text(
              '아직 결제 내역이 없습니다.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        )
      : Column(
          children: paymentHistory.take(4).map((item) {
            final t = item.title.toLowerCase();
            final isPdf = t.contains('pdf');
            final isImg = t.contains('이미지') || t.contains('image') || t.contains('img');
            return AiServiceUsageItem(
              icon: isPdf
                  ? Icons.picture_as_pdf_rounded
                  : isImg
                      ? Icons.image_rounded
                      : Icons.auto_awesome_rounded,
              title: item.title.isNotEmpty ? item.title : 'AI 서비스',
              time: item.rawTime.isNotEmpty
                  ? formatDateTime(item.rawTime)
                  : '날짜 없음',
              amount: '-USDC ${formatUsdc(item.paidAmount)}',
              iconBackground: const Color(0xFFEAF0FF),
              iconColor: AppColors.primary, // 색상 통일
            );
          }).toList(),
        ),
),

const SizedBox(height: 22),

Row(
  children: [
    Expanded(
      child: StatCard(
        icon: '📊',
        label: '이번 달 거래',
        value: '${budget!.transactionCount}건',
      ),
    ),
    const SizedBox(width: 16),
    Expanded(
      child: StatCard(
        icon: '💰',
        label: '평균 거래액',
        value: 'USDC ${formatUsdc(budget!.averageTransactionAmount)}',
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