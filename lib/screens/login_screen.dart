import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const FlutterLogo(size: 80),
            const SizedBox(height: 30),
            const CustomInput(
              hintText: '이메일을 입력하세요',
            ),
            const SizedBox(height: 16),
            const CustomInput(
              hintText: '비밀번호를 입력하세요',
              obscureText: true,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: '로그인',
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