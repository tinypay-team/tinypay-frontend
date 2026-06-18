import 'dart:io';
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
    // 로컬 파일 경로 (갤러리에서 고른 후 즉시 표시)
    if (selectedAvatar.startsWith('/') || selectedAvatar.startsWith('file://')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFBBBBBB),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: ClipOval(
          child: Image.file(
            File(selectedAvatar),
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white),
          ),
        ),
      );
    }

    // S3 등 네트워크 이미지
    if (selectedAvatar.startsWith('http')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFBBBBBB),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(
            selectedAvatar,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, error, ___) {
              print('Image.network 로드 실패: $error');
              return const Icon(Icons.person, color: Colors.white);
            },
          ),
        ),
      );
    }

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
        gradient: const LinearGradient(
          colors: [Color(0xFF91AAFF), Color(0xFFCFE9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33818CF8),
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