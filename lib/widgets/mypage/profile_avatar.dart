import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String selectedAvatar;
  final double size;

  const ProfileAvatar({
    super.key,
    required this.selectedAvatar,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return selectedAvatar.length <= 1
        ? Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF5B6CFF), Color(0xFF8B2CFF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                selectedAvatar,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        : AvatarCircle(
            avatar: selectedAvatar,
            size: size,
          );
  }
}

class AvatarCircle extends StatelessWidget {
  final String avatar;
  final double size;

  const AvatarCircle({
    super.key,
    required this.avatar,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF5F0FF),
        border: Border.all(color: const Color(0xFFE1CFFF), width: 4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          avatar,
          style: TextStyle(fontSize: size * 0.42),
        ),
      ),
    );
  }
}