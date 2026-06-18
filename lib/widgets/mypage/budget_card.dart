import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../utils/format_utils.dart';

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
    final double progress = monthlyBudget == 0
        ? 0.0
        : (monthlySpent / monthlyBudget).clamp(0.0, 1.0);
    final double percent = monthlyBudget == 0
        ? 0.0
        : (monthlySpent / monthlyBudget * 100).clamp(0.0, 100.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
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
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Icon(
                  Icons.trending_up_rounded,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '이번 달 예산',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.subText,
                        size: 22,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'USDC ${formatUsdc(monthlySpent)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          '/ USDC ${formatUsdc(monthlyBudget)}',
                          style: const TextStyle(
                            color: AppColors.subText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE9EEF8),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${percent.toStringAsFixed(0)}% 사용 중',
                    style: const TextStyle(
                      color: AppColors.subText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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
