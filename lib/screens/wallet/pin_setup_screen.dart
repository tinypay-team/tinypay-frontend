import 'package:flutter/material.dart';
import 'wallet_created_screen.dart';
import '../../services/wallet_api_service.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final TextEditingController pinController = TextEditingController();
  final TextEditingController confirmPinController = TextEditingController();

  bool isPinHidden = true;
  bool isConfirmPinHidden = true;

  Future<void> completePinSetup() async {
    final pin = pinController.text.trim();
    final confirmPin = confirmPinController.text.trim();

    if (pin.length != 6 || confirmPin.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('6자리 PIN을 입력해주세요.')),
      );
      return;
    }

    if (pin != confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN이 일치하지 않습니다.')),
      );
      return;
    }

    try {
      await WalletApiService().createWallet(
        walletPassword: pin,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('지갑이 생성되었습니다.')),
      );

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const WalletCreatedScreen(),
        ),
      );

      if (result == true && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('지갑 생성 실패: $e')),
      );
    }
  }

  @override
  void dispose() {
    pinController.dispose();
    confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FF),
      appBar: AppBar(
        title: const Text('결제 PIN 생성'),
        backgroundColor: const Color(0xFFFAF7FF),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '결제 비밀번호를 만들어주세요',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '충전이나 중요한 결제 설정을 변경할 때 사용할 4자리 PIN입니다.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 36),

            const Text(
              'PIN 입력',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: isPinHidden,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: '6자리 숫자',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPinHidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      isPinHidden = !isPinHidden;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'PIN 확인',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPinController,
              keyboardType: TextInputType.number,
              obscureText: isConfirmPinHidden,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: '다시 입력',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isConfirmPinHidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      isConfirmPinHidden = !isConfirmPinHidden;
                    });
                  },
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: completePinSetup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B5CF6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'PIN 생성 완료',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}