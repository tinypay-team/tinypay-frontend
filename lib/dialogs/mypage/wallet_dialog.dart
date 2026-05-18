import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/wallet_model.dart';

class WalletDialog extends StatelessWidget {
  final WalletModel wallet;
  final bool autoPaymentEnabled;
  final VoidCallback onToggleAutoPayment;

  const WalletDialog({
    super.key,
    required this.wallet,
    required this.autoPaymentEnabled,
    required this.onToggleAutoPayment,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Color(0xFF4EA45C),
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '내 지갑',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 30),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Text(
                '지갑 주소',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE4E1EA),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        wallet.walletAddress,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: wallet.walletAddress,
                          ),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('지갑 주소가 복사되었습니다.'),
                          ),
                        );
                      },
                      child: const Text(
                        '복사',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                '스테이블코인 잔액',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFC9D8FF),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4F5CF7),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'USDC',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'USD Coin',
                            style: TextStyle(
                              color: Color(0xFF666B7A),
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            'USDC ${wallet.balance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF29358F),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      '${wallet.balance.toStringAsFixed(2)} USDC',
                      style: const TextStyle(
                        color: Color(0xFF29358F),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Divider(),

              const SizedBox(height: 16),

              Row(
                children: [
                  const Text(
                    '총 잔액',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    'USD ${wallet.balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF5B5CF6),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                '자동결제 승인',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 12,
                      color: autoPaymentEnabled
                          ? const Color(0xFF58C45C)
                          : Colors.grey,
                    ),

                    const SizedBox(width: 10),

                    Text(
                      autoPaymentEnabled ? '활성화됨' : '비활성화됨',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Spacer(),

                    OutlinedButton(
                      onPressed: onToggleAutoPayment,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: autoPaymentEnabled
                              ? Colors.red.shade200
                              : Colors.green.shade300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        autoPaymentEnabled ? '비활성화' : '활성화',
                        style: TextStyle(
                          color: autoPaymentEnabled
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  autoPaymentEnabled
                      ? '💡 자동결제가 활성화되어 있습니다. 한도 내 거래는 자동으로 승인됩니다.'
                      : '💡 자동결제가 비활성화되어 있습니다.',
                  style: const TextStyle(
                    color: Color(0xFF3046C7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}