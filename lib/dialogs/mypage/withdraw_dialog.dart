import 'package:flutter/material.dart';

class WithdrawDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const WithdrawDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('회원 탈퇴'),
      content: const Text('정말 회원 탈퇴를 진행하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: onConfirm,
          child: const Text(
            '탈퇴',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}