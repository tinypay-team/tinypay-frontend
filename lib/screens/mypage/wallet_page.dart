import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/wallet_model.dart';
import '../../services/wallet_api_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/format_utils.dart';
import '../../utils/auto_payment_notifier.dart';

class WalletPage extends StatefulWidget {
  final WalletModel wallet;
  final bool autoPaymentEnabled;
  final Function(bool) onAutoPaymentChanged;

  const WalletPage({
    super.key,
    required this.wallet,
    required this.autoPaymentEnabled,
    required this.onAutoPaymentChanged,
  });

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late WalletModel _wallet;
  late bool _autoPaymentEnabled;
  bool _isLoading = true;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _wallet = widget.wallet;
    _autoPaymentEnabled = widget.autoPaymentEnabled;
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    try {
      final wallet = await WalletApiService().getWallet();
      if (!mounted) return;
      // notifier와 항상 동기화 (chat_screen listener가 올바르게 동작하도록)
      autoPaymentNotifier.value = wallet.autoPaymentEnabled;
      setState(() {
        _wallet = wallet;
        _autoPaymentEnabled = wallet.autoPaymentEnabled;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleAutoPayment() async {
    if (_isToggling) return;
    final nextValue = !_autoPaymentEnabled;

    if (nextValue == true) {
      await _showPinDialogAndToggle(nextValue);
    } else {
      setState(() => _isToggling = true);
      try {
        final saved = await WalletApiService().updateAutoPayment(enabled: false);
        if (!mounted) return;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('autoPaymentEnabled', saved);
        autoPaymentNotifier.value = saved;
        setState(() {
          _autoPaymentEnabled = saved;
          _isToggling = false;
        });
        widget.onAutoPaymentChanged(saved);
      } catch (e) {
        if (!mounted) return;
        setState(() => _isToggling = false);
        _showErrorDialog(e.toString());
      }
    }
  }

  Future<void> _showPinDialogAndToggle(bool nextValue) async {
    final pinController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        String? errorMsg;
        bool isLoading = false;

        return StatefulBuilder(
          builder: (ctx, setDialogState) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/tinypay1.png', width: 80, height: 80),
                  const SizedBox(height: 12),
                  const Text('지갑 PIN 입력',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  const Text(
                    '자동결제를 켜려면\n6자리 PIN을 입력해주세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: errorMsg != null ? AppColors.danger : AppColors.border,
                      ),
                    ),
                    child: TextField(
                      controller: pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      onChanged: (_) {
                        if (errorMsg != null) setDialogState(() => errorMsg = null);
                      },
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 8),
                      decoration: const InputDecoration(
                        hintText: '••••••',
                        counterText: '',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (errorMsg != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEEEE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 15),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              errorMsg!,
                              style: const TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading ? null : () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            fixedSize: const Size.fromHeight(50),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('취소', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final pin = pinController.text.trim();
                                  if (pin.length != 6) {
                                    setDialogState(() => errorMsg = '6자리 PIN을 입력해주세요.');
                                    return;
                                  }
                                  setDialogState(() => isLoading = true);
                                  try {
                                    final saved = await WalletApiService().updateAutoPayment(
                                      enabled: nextValue,
                                      walletPassword: pin,
                                    );
                                    if (!ctx.mounted) return;
                                    Navigator.pop(ctx);
                                    if (!mounted) return;
                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.setBool('autoPaymentEnabled', saved);
                                    autoPaymentNotifier.value = saved;
                                    setState(() => _autoPaymentEnabled = saved);
                                    widget.onAutoPaymentChanged(saved);
                                  } catch (e) {
                                    pinController.clear();
                                    setDialogState(() {
                                      isLoading = false;
                                      errorMsg = e.toString().replaceAll('Exception: ', '');
                                    });
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size.fromHeight(50),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('확인', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
              const Text(
                '오류',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
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
          '내 지갑',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 잔액 카드
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF91AAFF), Color(0xFFCFE9FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A6F8CFF),
                          blurRadius: 22,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 14),
                                      SizedBox(width: 5),
                                      Text('스테이블 코인 잔액', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              formatUsdc(_wallet.balance),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.5,
                              ),
                            ),
                            const Text(
                              'USDC',
                              style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 20),
                            Container(height: 1, color: Colors.white.withOpacity(0.25)),
                            const SizedBox(height: 16),
                            const Text(
                              '지갑 주소',
                              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      _wallet.walletAddress,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: _wallet.walletAddress));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('지갑 주소가 복사되었습니다.')),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.copy_rounded, color: Color(0xFF5B5CF6), size: 13),
                                        SizedBox(width: 4),
                                        Text('복사', style: TextStyle(color: Color(0xFF5B5CF6), fontSize: 12, fontWeight: FontWeight.w800)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          right: -8,
                          top: -20,
                          child: Image.asset(
                            'assets/images/tinypay1.png',
                            width: 100,
                            opacity: const AlwaysStoppedAnimation(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 자동결제 섹션
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: _autoPaymentEnabled
                                    ? const Color(0xFFE8F8EC)
                                    : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                _autoPaymentEnabled
                                    ? Icons.bolt_rounded
                                    : Icons.bolt_outlined,
                                color: _autoPaymentEnabled
                                    ? AppColors.success
                                    : AppColors.subText,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '자동결제',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _autoPaymentEnabled
                                        ? '한도 내 거래 자동 승인'
                                        : '거래마다 비밀번호 필요',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _isToggling
                                ? const SizedBox(
                                    width: 26,
                                    height: 26,
                                    child: CircularProgressIndicator(strokeWidth: 2.5),
                                  )
                                : GestureDetector(
                                    onTap: _toggleAutoPayment,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      width: 54,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(999),
                                        color: _autoPaymentEnabled
                                            ? AppColors.primary
                                            : const Color(0xFFDDDDDD),
                                      ),
                                      child: AnimatedAlign(
                                        duration: const Duration(milliseconds: 250),
                                        alignment: _autoPaymentEnabled
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Container(
                                          margin: const EdgeInsets.all(3),
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(color: Color(0x22000000), blurRadius: 4),
                                            ],
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

                  const SizedBox(height: 24),

                  // 지갑 안내 섹션
                  const Text(
                    '안내',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),

                  _infoTile(
                    icon: Icons.shield_rounded,
                    iconColor: const Color(0xFF6F8CFF),
                    iconBg: const Color(0xFFEAF0FF),
                    title: '안전한 블록체인 결제',
                    desc: '모든 거래는 블록체인에 기록되어 변조가 불가능합니다.',
                  ),
                  const SizedBox(height: 10),
                  _infoTile(
                    icon: Icons.swap_horiz_rounded,
                    iconColor: const Color(0xFF58C45C),
                    iconBg: const Color(0xFFE8F8EC),
                    title: 'USDC 스테이블 코인',
                    desc: '달러에 연동된 안정적인 코인으로 결제 금액이 유지됩니다.',
                  ),
                  const SizedBox(height: 10),
                  _infoTile(
                    icon: Icons.lock_rounded,
                    iconColor: const Color(0xFFFFC94A),
                    iconBg: const Color(0xFFFFF7D8),
                    title: 'PIN 보안',
                    desc: '6자리 결제 PIN으로 내 지갑을 안전하게 보호하세요.',
                  ),
                ],
              ),
            ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
