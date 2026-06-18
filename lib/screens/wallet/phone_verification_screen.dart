import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/verification_service.dart';
import 'pin_setup_screen.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  final VerificationService _verificationService = VerificationService();

  bool codeSent = false;
  bool isSendingCode = false;
  bool isVerifying = false;

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

  Future<void> sendCode() async {
    final phoneNumber = phoneController.text.trim();

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('휴대폰 번호를 입력해주세요.')),
      );
      return;
    }

    try {
      setState(() {
        isSendingCode = true;
      });

      await _verificationService.sendVerificationCode(
        phoneNumber: phoneNumber,
      );

      if (!mounted) return;

      setState(() {
        codeSent = true;
      });

      startTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증번호가 발송되었습니다.')),
      );
    } catch (e) {
      print('SEND CODE ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isSendingCode = false;
      });
    }
  }

  Future<void> verifyCode() async {
    final phoneNumber = phoneController.text.trim();
    final verificationCode = codeController.text.trim();

    if (verificationCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('6자리 인증번호를 입력해주세요.')),
      );
      return;
    }

    try {
      setState(() {
        isVerifying = true;
      });

      await _verificationService.verifyCode(
        phoneNumber: phoneNumber,
        verificationCode: verificationCode,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증 성공')),
      );

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PinSetupScreen(),
        ),
      );

      if (result == true && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('VERIFY CODE ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isVerifying = false;
      });
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
      backgroundColor: const Color(0xFFFAF7FF),
      appBar: AppBar(
        title: const Text('본인인증'),
        backgroundColor: const Color(0xFFFAF7FF),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24, 24, 24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
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
                onPressed: isSendingCode ? null : sendCode,
                child: isSendingCode
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('인증번호 받기'),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '남은 시간 ${formatTime(remainingTime)}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  TextButton(
                    onPressed: isSendingCode ? null : sendCode,
                    child: const Text('재발송'),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isVerifying ? null : verifyCode,
                  child: isVerifying
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('인증 완료'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}