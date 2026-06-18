import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/mypage/profile_avatar.dart';
import '../login_screen.dart';
import 'edit_profile_page.dart';
import '../../dialogs/mypage/withdraw_dialog.dart';
import '../../utils/auto_payment_notifier.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;
  final Function(UserModel) onUserUpdated;

  const ProfilePage({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserModel _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
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
          '내 정보',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          children: [
            const SizedBox(height: 24),

            ProfileAvatar(selectedAvatar: _user.avatar, size: 100),

            const SizedBox(height: 20),

            Text(
              _user.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              _user.email,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 40),

            _MenuButton(
              title: '프로필 수정',
              icon: Icons.edit_outlined,
              onTap: () async {
                final updated = await Navigator.push<UserModel>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfilePage(user: _user),
                  ),
                );
                print('▶ EditProfilePage 결과: $updated');
                if (updated != null) {
                  print('▶ ProfilePage 업데이트: name=${updated.name}, avatar=${updated.avatar}');
                  setState(() => _user = updated);
                  widget.onUserUpdated(updated);
                } else {
                  print('▶ 결과 null → 업데이트 없음');
                }
              },
            ),

            const SizedBox(height: 12),

            _MenuButton(
              title: '회원 탈퇴',
              icon: Icons.person_remove_outlined,
              textColor: AppColors.danger,
              borderColor: const Color(0xFFFFCACA),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => WithdrawDialog(
                    onConfirm: () => Navigator.pop(context),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _MenuButton(
              title: '로그아웃',
              icon: Icons.logout_rounded,
              onTap: () async {
                try {
                  await AuthService().logout();
                } catch (_) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('accessToken');
                  await prefs.remove('refreshToken');
                  await prefs.setBool('isLoggedIn', false);
                  await prefs.remove('autoPaymentEnabled');
                  await prefs.remove('userAvatarEmoji');
                  autoPaymentNotifier.value = false;
                }
                try {
                  await GoogleSignIn().signOut();
                } catch (_) {}

                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color textColor;
  final Color borderColor;

  const _MenuButton({
    required this.title,
    required this.icon,
    required this.onTap,
    this.textColor = AppColors.textPrimary,
    this.borderColor = AppColors.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: AppColors.subText, size: 20),
          ],
        ),
      ),
    );
  }
}
