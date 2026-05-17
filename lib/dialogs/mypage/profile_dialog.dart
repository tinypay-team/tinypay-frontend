import 'package:flutter/material.dart';
import '../../widgets/mypage/profile_avatar.dart';
import '../../widgets/mypage/profile_menu_button.dart';

class ProfileDialog extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String selectedAvatar;
  final VoidCallback onEditProfileTap;
  final VoidCallback onWithdrawTap;
  final VoidCallback onLogoutTap;

  const ProfileDialog({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.selectedAvatar,
    required this.onEditProfileTap,
    required this.onWithdrawTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  '내 정보',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 28),
            ProfileAvatar(
              selectedAvatar: selectedAvatar,
              size: 96,
            ),
            const SizedBox(height: 20),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              userEmail,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666B7A),
              ),
            ),
            const SizedBox(height: 28),
            ProfileMenuButton(
              title: '프로필 수정',
              icon: Icons.chevron_right,
              onTap: onEditProfileTap,
            ),
            const SizedBox(height: 10),
            ProfileMenuButton(
              title: '회원 탈퇴',
              icon: Icons.chevron_right,
              textColor: Colors.red,
              borderColor: const Color(0xFFFFCACA),
              onTap: onWithdrawTap,
            ),
            const SizedBox(height: 10),
            ProfileMenuButton(
              title: '로그아웃',
              icon: Icons.logout,
              center: true,
              onTap: onLogoutTap,
            ),
          ],
        ),
      ),
    );
  }
}