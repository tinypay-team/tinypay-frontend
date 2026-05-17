import 'package:flutter/material.dart';

class LimitCard extends StatelessWidget {
  final double singleLimit;
  final VoidCallback onTap;

  const LimitCard({
    super.key,
    required this.singleLimit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE4E1EA)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardTitleRow(),
            const SizedBox(height: 42),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'USDC ${singleLimit.toStringAsFixed(1)}',
                  style: const TextStyle(
                    color: Color(0xFF4EA45C),
                    fontSize: 31,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Text(
                  '건당 최대 금액',
                  style: TextStyle(
                    color: Color(0xFF555A6E),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardTitleRow() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Color(0xFFE2F8E8),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.attach_money,
            color: Color(0xFF4EA45C),
            size: 25,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          '1회 한도',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        const Icon(
          Icons.chevron_right,
          color: Color(0xFF9AA0AA),
          size: 30,
        ),
      ],
    );
  }
}