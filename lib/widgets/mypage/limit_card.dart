import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

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
            /// 왼쪽 아이콘 박스
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Text(
                  '\$',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 18),

            /// 텍스트 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1회 한도',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'USDC ${singleLimit.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    '건당 자동 승인 최대 금액',
                    style: TextStyle(
                      color: AppColors.subText,
                      fontSize: 13,
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