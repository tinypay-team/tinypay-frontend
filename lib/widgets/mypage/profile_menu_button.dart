import 'package:flutter/material.dart';

class ProfileMenuButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color textColor;
  final Color borderColor;
  final bool center;

  const ProfileMenuButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.textColor = Colors.black,
    this.borderColor = const Color(0xFFE4E1EA),
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment:
              center ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
          children: [
            if (center) Icon(icon, size: 20, color: textColor),
            if (center) const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!center) Icon(icon, color: textColor, size: 22),
          ],
        ),
      ),
    );
  }
}