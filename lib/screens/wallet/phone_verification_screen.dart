import 'dart:async';

import 'package:flutter/material.dart';
import 'pin_setup_screen.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState
    extends State<PhoneVerificationScreen> {
  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController codeController =
      TextEditingController();

  bool codeSent = false;

  int remainingTime = 300;

  Timer? timer;

  void startTimer() {
    timer?.cancel();

    setState(() {
      remainingTime = 300;
    });

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (remainingTime > 0) {
          setState(() {
            remainingTime--;
          });
        } else {
          timer.cancel();
        }
      },
    );
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainSeconds = seconds % 60;

    return '$minutes:${remainSeconds.toString().padLeft(2, '0')}';
  }

  void sendCode() {
    setState(() {
      codeSent = true;
    });

    startTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('테스트 인증번호: 123456'),
      ),
    );
  }

  void verifyCode() async {
    if (codeController.text == '123456') {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('인증 성공'),
    ),
  );

  final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const PinSetupScreen(),
  ),
);

if (result == true) {
  Navigator.pop(context, true);
}
} else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('인증번호가 올바르지 않습니다'),
        ),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();

    phoneController.dispose();
    codeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('본인인증'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '휴대폰 번호',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '01012345678',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: sendCode,
                child: const Text('인증번호 받기'),
              ),
            ),

            if (codeSent) ...[
              const SizedBox(height: 32),

              const Text(
                '인증번호 입력',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: '123456',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '남은 시간 ${formatTime(remainingTime)}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  TextButton(
                    onPressed: sendCode,
                    child: const Text('재발송'),
                  ),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: verifyCode,
                  child: const Text('인증 완료'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}