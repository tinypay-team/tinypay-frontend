import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '이번 달 예산',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${percent.toStringAsFixed(0)}% 사용 중',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  _CircleProgress(progress: progress),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '이번 달 사용량',
                          style: TextStyle(
                            color: AppColors.subText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'USDC ${monthlySpent.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '/ ${monthlyBudget.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: AppColors.subText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFE9EEF8),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF7B8CFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleProgress extends StatelessWidget {
  final double progress;

  const _CircleProgress({
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8EA2FF).withOpacity(0.28),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SizedBox(
        width: 68,
        height: 68,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 68,
              height: 68,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 7.5,
                backgroundColor: const Color(0xFFE9EEF8),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF7B8CFF),
                ),
              ),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.trending_up_rounded,
                color: Color(0xFF7B8CFF),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}