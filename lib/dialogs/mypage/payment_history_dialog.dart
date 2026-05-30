import 'package:flutter/material.dart';

import '../../models/payment_model.dart';
import '../../theme/app_colors.dart';

class PaymentHistoryDialog extends StatelessWidget {
  final List<PaymentModel> paymentHistory;

  const PaymentHistoryDialog({
    super.key,
    required this.paymentHistory,
  });

  void _showApiDetailSheet(BuildContext context, PaymentModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _PaymentApiDetailSheet(payment: item);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = paymentHistory.fold<double>(
      0,
      (sum, item) {
        final numberText = item.amount
            .replaceAll('USDC', '')
            .replaceAll('-', '')
            .trim();

        return sum + (double.tryParse(numberText) ?? 0);
      },
    );

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
                      '결제 내역을 누르면 사용된 API를 볼 수 있어요',
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

                  return GestureDetector(
                    onTap: () => _showApiDetailSheet(context, item),
                    behavior: HitTestBehavior.opaque,
                    child: _HistoryUsageItem(
                      title: item.title,
                      time: item.time,
                      amount: item.amount,
                      status: item.paymentStatus ?? 'COMPLETED',
                    ),
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

                Text(
                  '${totalAmount.toStringAsFixed(3)} USDC',
                  style: const TextStyle(
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
  final String status;

  const _HistoryUsageItem({
    required this.title,
    required this.time,
    required this.amount,
    required this.status,
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

  String get _statusText {
    if (status == 'COMPLETED') return '완료';
    if (status == 'PENDING') return '대기';
    if (status == 'FAILED') return '실패';
    return '완료';
  }

  Color get _statusColor {
    if (status == 'COMPLETED') return const Color(0xFF24B85A);
    if (status == 'PENDING') return const Color(0xFFF59E0B);
    if (status == 'FAILED') return const Color(0xFFEF4444);
    return const Color(0xFF24B85A);
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

        const SizedBox(width: 8),

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
            Row(
              children: [
                Text(
                  _statusText,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _PaymentApiDetailSheet extends StatelessWidget {
  final PaymentModel payment;

  const _PaymentApiDetailSheet({
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    const usedApis = [
      {
        'name': 'Instagram Reels API',
        'description': '릴스 트렌드 및 영상 구조 분석',
        'cost': '0.006 USDC',
      },
      {
        'name': 'Video Analysis API',
        'description': '영상 패턴, 길이, 후킹 포인트 분석',
        'cost': '0.009 USDC',
      },
      {
        'name': 'AI Voice Generator API',
        'description': '추천 음성 및 배경음 생성 비용',
        'cost': '0.005 USDC',
      },
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 26),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF7FF),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(34),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFD8D3E7),
              borderRadius: BorderRadius.circular(999),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '사용된 API 상세',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payment.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
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

          Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: usedApis.map((api) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF0FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.api_rounded,
                          color: AppColors.primary,
                          size: 23,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              api['name']!,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              api['description']!,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        api['cost']!,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F7FF),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFD7E7FF),
              ),
            ),
            child: Text(
              '총 결제 금액 · ${payment.amount}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}