import 'package:flutter/material.dart';
import '../widgets/mypage/stat_card.dart';
import '../widgets/mypage/payment_item.dart';
import '../widgets/mypage/balance_card.dart';
import '../widgets/mypage/budget_card.dart';
import '../widgets/mypage/limit_card.dart';
import '../widgets/mypage/profile_avatar.dart';
import '../widgets/mypage/profile_menu_button.dart';
import '../widgets/mypage/history_item.dart';
import '../widgets/mypage/payment_section_header.dart';
import '../dialogs/mypage/budget_dialog.dart';
import '../dialogs/mypage/limit_dialog.dart';
import '../dialogs/mypage/payment_history_dialog.dart';
import '../dialogs/mypage/profile_dialog.dart';
import '../dialogs/mypage/edit_profile_dialog.dart';
import '../dialogs/mypage/withdraw_dialog.dart';
import '../models/payment_model.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  bool isWalletConnected = true;
  String walletAddress = '0x12A4...9F3D';

  String userName = '김준영';
  String userEmail = '2021112090@email.com';
  String selectedAvatar = '김';

  double monthlyBudget = 20.0;
  final double monthlySpent = 11.5;
  double singleLimit = 1.0;

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

  final List<PaymentModel> paymentHistory = const [
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
  PaymentModel(
    title: 'DALL-E Image Generation',
    time: '5월 7일 오후 12:19',
    amount: 'USDC 0.1',
  ),
  PaymentModel(
    title: 'Claude Code Assistant',
    time: '5월 7일 오전 09:19',
    amount: 'USDC 0.2',
  ),
  PaymentModel(
    title: 'Speech to Text API',
    time: '5월 7일 오전 05:19',
    amount: 'USDC 0.1',
  ),
  PaymentModel(
    title: 'Translation API',
    time: '5월 6일 오후 11:40',
    amount: 'USDC 0.2',
  ),
  PaymentModel(
    title: 'Data Search API',
    time: '5월 6일 오후 08:10',
    amount: 'USDC 0.2',
  ),
  PaymentModel(
    title: 'AI Summary API',
    time: '5월 6일 오후 06:22',
    amount: 'USDC 0.2',
  ),
];

  void _showProfileDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return ProfileDialog(
        userName: userName,
        userEmail: userEmail,
        selectedAvatar: selectedAvatar,
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
        userName: userName,
        selectedAvatar: selectedAvatar,
        avatarList: avatarList,
        onSave: (newName, newAvatar) {
          setState(() {
            userName = newName;
            selectedAvatar = newAvatar;
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
        monthlyBudget: monthlyBudget,
        monthlySpent: monthlySpent,
        onSave: (newBudget) {
          setState(() {
            monthlyBudget = newBudget;
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
        singleLimit: singleLimit,
        onSave: (newLimit) {
          setState(() {
            singleLimit = newLimit;
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

  Widget _settingDialog({
    required String title,
    required String label,
    required TextEditingController controller,
    required String infoText,
    required Color infoColor,
    required Color textColor,
    required VoidCallback onSave,
  }) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF0F0F3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: infoColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                infoText,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF7B4DFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  '저장',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                selectedAvatar: selectedAvatar,
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
              isWalletConnected: isWalletConnected,
              walletAddress: walletAddress,
              onChargeTap: () {},
            ),
            const SizedBox(height: 22),
            BudgetCard(
              monthlySpent: monthlySpent,
              monthlyBudget: monthlyBudget,
              onTap: _showBudgetDialog,
            ),
            const SizedBox(height: 18),
            LimitCard(
              singleLimit: singleLimit,
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
              iconBackground: const Color(0xFFE9ECFF),
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

  Widget _infoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E1EA)),
      ),
      child: child,
    );
  }

  Widget _cardTitleRow({
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 25),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        const Icon(Icons.chevron_right, color: Color(0xFF9AA0AA), size: 30),
      ],
    );
  }
}