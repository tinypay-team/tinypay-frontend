import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AutoPaymentCard extends StatelessWidget {
  final bool enabled;
  final VoidCallback onToggle;

  const AutoPaymentCard({
    super.key,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/tinypay1.png',
            width: 90,
            height: 90,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tiny AutoPay',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  enabled
                      ? '자동결제가 활성화되어 있어요'
                      : '자동결제가 비활성화되어 있어요',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: enabled
                        ? const Color(0xFFE8FFF1)
                        : const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    enabled ? '활성화됨' : '비활성화됨',
                    style: TextStyle(
                      color: enabled
                          ? const Color(0xFF1E9E52)
                          : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: enabled,
            onChanged: (_) => onToggle(),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}