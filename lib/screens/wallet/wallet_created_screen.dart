import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/wallet_state.dart';
import '../main_navigation_screen.dart';

class WalletCreatedScreen extends StatelessWidget {
  const WalletCreatedScreen({super.key});

  final String walletAddress = '0x12A4...9F3D';

  void copyWalletAddress(BuildContext context) {
    Clipboard.setData(
      const ClipboardData(text: '0x12A4B7C9D2E5F8A1B3C6D9E0F2A4B6C8D0E1F3D'),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('지갑 주소가 복사되었습니다.'),
      ),
    );
  }

  void goBackToMyPage(BuildContext context) {
  WalletState.connectWallet();

  Navigator.pop(context, true);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FF),
      appBar: AppBar(
        title: const Text('지갑 생성 완료'),
        backgroundColor: const Color(0xFFFAF7FF),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),

            Image.asset(
  'assets/images/tinypay2.png',
  width: 210,
  height: 210,
  fit: BoxFit.contain,
),

            const SizedBox(height: 28),

            const Text(
              '지갑이 생성되었습니다!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              '이제 Tiny에서 AI 자동결제와 충전 기능을 사용할 수 있습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 36),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE1E3F0),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    '지갑 주소',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    walletAddress,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 14),

                  OutlinedButton.icon(
                    onPressed: () => copyWalletAddress(context),
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('주소 복사'),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  WalletState.connectWallet();
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B5CF6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '마이페이지로 돌아가기',
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