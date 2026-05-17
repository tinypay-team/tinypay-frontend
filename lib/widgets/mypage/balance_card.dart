import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final bool isWalletConnected;
  final String walletAddress;
  final VoidCallback onChargeTap;
  final double balance;
  final VoidCallback onWalletTap;

  const BalanceCard({
    super.key,
    required this.isWalletConnected,
    required this.walletAddress,
    required this.onChargeTap,
    required this.balance,
    required this.onWalletTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF5B6CFF), Color(0xFF8B2CFF), Color(0xFFE0449A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '총 잔액',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
              GestureDetector(
                onTap: onWalletTap,
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'USDC ${balance.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isWalletConnected ? walletAddress : '지갑이 연결되지 않았습니다.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onChargeTap,
              icon: const Icon(Icons.add, size: 22),
              label: const Text(
                '충전하기',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF8B2CFF),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}