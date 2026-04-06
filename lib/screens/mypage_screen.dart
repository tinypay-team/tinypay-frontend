import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Page'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '마이페이지',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text('총 잔액: 120.50 USDC'),
            const SizedBox(height: 10),
            const Text('자동결제: ON'),
            const SizedBox(height: 10),
            const Text('최근 사용 서비스: 번역 AI'),
            const SizedBox(height: 30),
            CustomButton(
              text: '채팅 화면으로 이동',
              onPressed: () {
                Navigator.pushNamed(context, '/chat');
              },
            ),
          ],
        ),
      ),
    );
  }
}