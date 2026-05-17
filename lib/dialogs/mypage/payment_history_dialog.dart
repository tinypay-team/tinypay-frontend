import 'package:flutter/material.dart';
import '../../widgets/mypage/history_item.dart';
import '../../models/payment_model.dart';

class PaymentHistoryDialog extends StatelessWidget {
  final List<PaymentModel> paymentHistory;

  const PaymentHistoryDialog({
    super.key,
    required this.paymentHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '전체 결제 내역',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: paymentHistory.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = paymentHistory[index];

                    return HistoryItem(
                      title: item.title,
                      time: item.time,
                      amount: item.amount,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '총 ${paymentHistory.length}건',
                    style: const TextStyle(
                      color: Color(0xFF555A6E),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'USDC 1.2',
                    style: TextStyle(
                      color: Color(0xFF5B5CF6),
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}