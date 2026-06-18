import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../utils/format_utils.dart';

class PaymentCompletedCard extends StatelessWidget {
  final double amount;
  final double? balance;

  const PaymentCompletedCard({
    super.key,
    required this.amount,
    this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FFF8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFCBEFD7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFE4FBEA),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF24B85A),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '결제가 완료되었어요',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${formatUsdc(amount)} USDC 결제 완료',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (balance != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    '잔액 ${formatUsdc(balance!)} USDC',
                    style: const TextStyle(
                      color: Color(0xFF24B85A),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}