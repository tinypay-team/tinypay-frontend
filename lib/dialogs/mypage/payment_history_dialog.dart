import 'package:flutter/material.dart';

import '../../models/payment_model.dart';
import '../../theme/app_colors.dart';

class PaymentHistoryDialog extends StatelessWidget {
  final List<PaymentModel> paymentHistory;

  const PaymentHistoryDialog({
    super.key,
    required this.paymentHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF7FF),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(34),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD8D3E7),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Image.asset(
                'assets/images/tinypay2.png',
                width: 58,
                height: 58,
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI 서비스 사용 내역',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tiny가 자동결제한 AI 서비스 기록이에요',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.border),
              ),
              child: ListView.separated(
                itemCount: paymentHistory.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = paymentHistory[index];

                  return _HistoryUsageItem(
                    title: item.title,
                    time: item.time,
                    amount: item.amount,
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Text(
                  '총 사용 내역',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const Spacer(),

                Text(
                  '${paymentHistory.length}건',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(width: 14),

                const Text(
                  '1.20 USDC',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryUsageItem extends StatelessWidget {
  final String title;
  final String time;
  final String amount;

  const _HistoryUsageItem({
    required this.title,
    required this.time,
    required this.amount,
  });

  IconData get _icon {
    if (title.contains('Image') || title.contains('이미지')) {
      return Icons.image_rounded;
    }
    if (title.contains('Data') || title.contains('데이터')) {
      return Icons.bar_chart_rounded;
    }
    if (title.contains('Voice') || title.contains('음성')) {
      return Icons.mic_rounded;
    }
    if (title.contains('Reels') || title.contains('릴스')) {
      return Icons.video_collection_rounded;
    }
    return Icons.auto_awesome_rounded;
  }

  Color get _iconBackground {
    if (title.contains('Image') || title.contains('이미지')) {
      return const Color(0xFFEAF0FF);
    }
    if (title.contains('Data') || title.contains('데이터')) {
      return const Color(0xFFEFF8FF);
    }
    if (title.contains('Voice') || title.contains('음성')) {
      return const Color(0xFFF3F0FF);
    }
    if (title.contains('Reels') || title.contains('릴스')) {
      return const Color(0xFFFFEAF3);
    }
    return const Color(0xFFF2F4FF);
  }

  Color get _iconColor {
    if (title.contains('Image') || title.contains('이미지')) {
      return AppColors.primary;
    }
    if (title.contains('Data') || title.contains('데이터')) {
      return const Color(0xFF3B82F6);
    }
    if (title.contains('Voice') || title.contains('음성')) {
      return const Color(0xFF7C3AED);
    }
    if (title.contains('Reels') || title.contains('릴스')) {
      return const Color(0xFFE84393);
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _iconBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            _icon,
            color: _iconColor,
            size: 24,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount.replaceAll('-', ''),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '완료',
              style: TextStyle(
                color: Color(0xFF24B85A),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}