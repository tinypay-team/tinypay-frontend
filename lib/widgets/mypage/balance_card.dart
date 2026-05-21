import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

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
      height: 170,
      padding: const EdgeInsets.fromLTRB(24, 22, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF91AAFF),
            Color(0xFFCFE9FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A6F8CFF),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          /// 왼쪽 잔액 영역
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: 190,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '내 지갑 잔액',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'USDC ${balance.toStringAsFixed(2)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    isWalletConnected
                        ? walletAddress
                        : '지갑이 연결되지 않았습니다.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xEEFFFFFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// 오른쪽 Tiny 캐릭터
          Positioned(
            right: -6,
            top: -24,
            child: GestureDetector(
              onTap: onWalletTap,
              child: Image.asset(
                'assets/images/tinypay3.png',
                width: 138,
              ),
            ),
          ),

          /// 오른쪽 아래 버튼
          Positioned(
            right: 8,
            bottom: 6,
            child: SizedBox(
              width: 118,
              height: 44,
              child: ElevatedButton(
                onPressed:
                    isWalletConnected
                        ? onChargeTap
                        : onWalletTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      isWalletConnected
                          ? Icons.add_rounded
                          : Icons.account_balance_wallet_rounded,
                      size: 22,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      isWalletConnected
                          ? '충전'
                          : '지갑 생성',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}