import 'package:flutter/material.dart';

class PaymentSectionHeader extends StatelessWidget {
  final VoidCallback onViewAllTap;

  const PaymentSectionHeader({
    super.key,
    required this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.access_time, color: Color(0xFF555A6E), size: 27),
        const SizedBox(width: 8),
        const Text(
          '최근 결제된 서비스',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onViewAllTap,
          child: const Text(
            '전체',
            style: TextStyle(
              color: Color(0xFF8B2CFF),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}