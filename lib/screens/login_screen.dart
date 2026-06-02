import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'main_navigation_screen.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _goToChatScreen(
    BuildContext context,
    String provider,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider 로그인 성공'),
        duration: const Duration(milliseconds: 700),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 800));

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainNavigationScreen(),
      ),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: '887536055216-cdd6ra0vvmpn41sadd5uni1v6q42sa2c.apps.googleusercontent.com'
      );

      final GoogleSignInAccount? user =
          await googleSignIn.signIn();

      if (user == null) {
        return;
      }

      final GoogleSignInAuthentication auth =
          await user.authentication;
      
      final token = auth.idToken ?? '';
      await Clipboard.setData(ClipboardData(text: token));
      print('TOKEN LENGTH: ${token.length} (clipboard에 복사됨)');
      print('TOKEN LENGTH: ${token.length}');
      print(token);

      print('이름: ${user.displayName}');
      print('이메일: ${user.email}');
      debugPrint('현재시간: ${DateTime.now()}');
      print('프로필 이미지: ${user.photoUrl}');
      print('TOKEN LENGTH: ${auth.idToken?.length}');
      print('TOKEN_START');
      print(auth.idToken);
      print('TOKEN_END');
      print('accessToken: ${auth.accessToken}');

      // TODO:
      // auth.idToken을 백엔드로 전송하면 됨

      if (auth.idToken == null || auth.idToken!.isEmpty) {
        throw Exception('Google idToken을 가져오지 못했습니다.');
      }

      print('AUTH SERVICE 호출 직전');
      print('idToken null? ${auth.idToken == null}');
      print('idToken length: ${auth.idToken?.length}');

      final authService = AuthService();
      await authService.loginWithGoogle(auth.idToken!);

      await _goToChatScreen(context, 'Google');
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google 로그인 실패: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF4FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),

                  const Text(
                    'Tiny Pay',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'AI와 쉽고 빠르게 대화하고,\n스마트한 결제 서비스 경험을 시작해보세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF6B7280),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFF),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '로그인',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Google 계정으로 간편하게 시작할 수 있어요.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),

                        const SizedBox(height: 24),

                        SocialLoginButton(
                          label: 'Google로 계속하기',
                          backgroundColor: Colors.white,
                          textColor:
                              const Color(0xFF111827),
                          borderColor:
                              const Color(0xFFE5E7EB),
                          imagePath:
                              'assets/images/google_logo.png',
                          onTap: () =>
                              _signInWithGoogle(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    '계속 진행하면 서비스 이용약관 및 개인정보처리방침에 동의하는 것으로 간주됩니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SocialLoginButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final String imagePath;
  final VoidCallback onTap;

  const SocialLoginButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),

                  const SizedBox(width: 36),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}