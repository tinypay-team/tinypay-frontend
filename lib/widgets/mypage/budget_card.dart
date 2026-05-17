import 'package:flutter/material.dart';

class BudgetCard extends StatelessWidget {
  final double monthlySpent;
  final double monthlyBudget;
  final VoidCallback onTap;

  const BudgetCard({
    super.key,
    required this.monthlySpent,
    required this.monthlyBudget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (monthlySpent / monthlyBudget).clamp(0.0, 1.0);
    final double percent =
        (monthlySpent / monthlyBudget * 100).clamp(0.0, 100.0);

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
              children: [
                Text(
                  'USDC ${monthlySpent.toStringAsFixed(1)}',
                  style: const TextStyle(
                    color: Color(0xFF5B5CF6),
                    fontSize: 31,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '/ USDC ${monthlyBudget.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFF555A6E),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: const Color(0xFFD4D1D6),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${percent.toStringAsFixed(1)}% 사용 중',
              style: const TextStyle(
                color: Color(0xFF666B7A),
                fontSize: 15,
              ),
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
            color: Color(0xFFE7EDFF),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.trending_up,
            color: Color(0xFF5B6CFF),
            size: 25,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          '이번 달 예산',
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