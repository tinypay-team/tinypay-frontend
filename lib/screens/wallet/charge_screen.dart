import 'package:flutter/material.dart';
import '../../services/wallet_api_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/format_utils.dart';

class ChargeScreen extends StatefulWidget {
  const ChargeScreen({super.key});

  @override
  State<ChargeScreen> createState() => _ChargeScreenState();
}

class _ChargeScreenState extends State<ChargeScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  bool isCharging = false;
  bool isPinHidden = true;
  String? errorMessage;
  final ScrollController _scrollController = ScrollController();
  int? _pressedIndex;

  static const _quickAmounts = [0.05, 0.1, 0.5, 1.0];

  String _formatAmount(double amount) {
    if (amount == amount.truncate()) return amount.toInt().toString();
    return amount.toString();
  }

  void _setQuickAmount(double amount, int index) {
    final current = double.tryParse(amountController.text.trim()) ?? 0;
    final sum = double.parse(((current + amount) * 10000).round().toString()) / 10000;
    amountController.text = _formatAmount(sum);
    setState(() => _pressedIndex = index);
    Future.delayed(const Duration(milliseconds: 230), () {
      if (mounted) setState(() => _pressedIndex = null);
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7FF),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 30),
              ),
              const SizedBox(height: 14),
              const Text('충전 실패',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(
                message.replaceAll('Exception: ', ''),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('확인', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(double newBalance) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7FF),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/tinypay1.png', width: 80, height: 80),
              const SizedBox(height: 14),
              const Text('충전 완료!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(
                '현재 잔액\n${formatUsdc(newBalance)} USDC',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context, newBalance);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('확인', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> charge() async {
    final amountText = amountController.text.trim();
    final pin = pinController.text.trim();

    if (amountText.isEmpty) {
      setState(() => errorMessage = '충전 금액을 입력해주세요.');
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() => errorMessage = '올바른 금액을 입력해주세요.');
      return;
    }
    if (pin.length != 6) {
      setState(() => errorMessage = '6자리 PIN을 입력해주세요.');
      return;
    }

    setState(() {
      isCharging = true;
      errorMessage = null;
    });

    try {
      final newBalance = await WalletApiService().topUp(amount: amount, walletPassword: pin);
      if (!mounted) return;
      setState(() => isCharging = false);
      _showSuccessDialog(newBalance);
    } catch (e) {
      if (!mounted) return;
      pinController.clear();
      setState(() {
        isCharging = false;
        errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    pinController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'USDC 충전',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900),
        ),
      ),
      body: Builder(
        builder: (context) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 안내 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [Color(0xFF91AAFF), Color(0xFFCFE9FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0x1A6F8CFF), blurRadius: 16, offset: Offset(0, 8)),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('스테이블 코인 충전',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                      SizedBox(height: 6),
                      Text('USDC',
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
                      SizedBox(height: 4),
                      Text('충전 금액과 결제 PIN을 입력하세요.',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Positioned(
                    right: -4,
                    top: -14,
                    child: Image.asset('assets/images/tinypay1.png', width: 80,
                        opacity: const AlwaysStoppedAnimation(0.85)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 충전 금액
            const Text('충전 금액',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                      decoration: const InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const Text('USDC',
                      style: TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.w800)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 빠른 금액 선택
            Row(
              children: _quickAmounts.asMap().entries.map((entry) {
                final index = entry.key;
                final amount = entry.value;
                final isLast = index == _quickAmounts.length - 1;
                final label = _formatAmount(amount);
                final selected = _pressedIndex == index;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: isLast ? 0 : 8),
                    child: GestureDetector(
                      onTap: () => _setQuickAmount(amount, index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: Text(
                          '+$label',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selected ? Colors.white : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // 결제 PIN
            const Text('결제 PIN',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: isPinHidden,
                maxLength: 6,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 6),
                decoration: InputDecoration(
                  hintText: '••••••',
                  hintStyle: const TextStyle(color: AppColors.textSecondary, letterSpacing: 4, fontSize: 16),
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPinHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.subText,
                    ),
                    onPressed: () => setState(() => isPinHidden = !isPinHidden),
                  ),
                ),
              ),
            ),

            if (errorMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isCharging ? null : charge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.border,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: isCharging
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('충전하기',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
          );
        },
      ),
    );
  }
}
