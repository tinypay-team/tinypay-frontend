import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Widget buildHistoryItem({
    required String title,
    required String date,
    required String amount,
    required String status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(date, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(status, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('결제 기록')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            buildHistoryItem(
              title: 'AI 응답 요청',
              date: '2026-04-06 14:30',
              amount: '0.03 USDC',
              status: '성공',
            ),
            buildHistoryItem(
              title: '외부 API 호출',
              date: '2026-04-06 13:10',
              amount: '0.07 USDC',
              status: '성공',
            ),
          ],
        ),
      ),
    );
  }
}