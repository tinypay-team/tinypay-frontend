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
import '../services/wallet_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
        onSave: (newName, newAvatar) async {
          try {
            await _service.updateUser(
              nickname: newName,
            );

            final updatedUser = await _service.getUser();

            if (!mounted) return;

            setState(() {
              user = updatedUser.copyWith(
                avatar: newAvatar,
              );
            });

            Navigator.pop(context);
          } catch (e) {
            print('UPDATE PROFILE ERROR: $e');
          }
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
        onSave: (newBudget) async {
          try {
            final savedBudget = await _service.updateMonthlyBudget(newBudget);

            if (!mounted) return;

            setState(() {
              budget = budget!.copyWith(monthlyBudget: savedBudget);
            });
          } catch (e) {
            print('UPDATE MONTHLY BUDGET ERROR: $e');
          }
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
        onSave: (newLimit) async {
          try {
            final savedLimit = await _service.updatePerPaymentLimit(newLimit);

            if (!mounted) return;

            setState(() {
              budget = budget!.copyWith(singleLimit: savedLimit);
            });
          } catch (e) {
            print('UPDATE PER PAYMENT LIMIT ERROR: $e');
          }
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
    _loadMyPageData();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMyPageData();
}

  Future<void> _loadMyPageData() async {
  try {
    final userData = await _service.getUser();
    final myPageData = await _service.getMyPage();

    WalletModel? walletApiData;

    try {
      walletApiData = await WalletApiService().getWallet();
    } catch (e) {
      print('GET WALLET OPTIONAL ERROR: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    final savedAutoPaymentEnabled =
        prefs.getBool('autoPaymentEnabled') ??
            (walletApiData?.autoPaymentEnabled ?? false);

    final hasWallet =
        walletApiData != null || myPageData['balance'] != null;

    final walletData = WalletModel(
      balance: (myPageData['balance'] as num?)?.toDouble() ??
          walletApiData?.balance ??
          0,
      walletAddress: walletApiData?.walletAddress ?? '',
      isConnected: hasWallet,
      walletStatus: walletApiData?.walletStatus ??
          (hasWallet ? 'ACTIVE' : ''),
      autoPaymentEnabled: savedAutoPaymentEnabled,
    );

    final budgetData = BudgetModel.fromMyPageJson(myPageData);

    final recentPayments =
        (myPageData['recentPayments'] as List? ?? [])
            .map((e) => PaymentModel.fromJson(e))
            .toList();

    if (!mounted) return;

    setState(() {
      wallet = walletData;
      user = userData;
      budget = budgetData;
      paymentHistory = recentPayments;
      autoPaymentEnabled = walletData.autoPaymentEnabled;
    });
  } catch (e) {
    print('LOAD MYPAGE ERROR: $e');
  }
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
              onToggle: _toggleAutoPayment,
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
            return AiServiceUsageItem(
              icon: Icons.auto_awesome_rounded,
              title: item.title,
              time: item.time,
              amount: item.amount,
              iconBackground: const Color(0xFFEAF0FF),
              iconColor: AppColors.primary,
            );
          }).toList(),
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