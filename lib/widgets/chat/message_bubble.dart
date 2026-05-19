import 'package:flutter/material.dart';

import '../../models/chat_item_model.dart';
import '../../theme/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final ChatItemModel item;

  const MessageBubble({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        mainAxisAlignment:
            item.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!item.isUser) ...[
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Image.asset(
                'assets/images/tinypay1.png',
                width: 48,
                height: 48,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color:
                      item.isUser ? const Color(0xFFFFF7DD) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(26),
                    topRight: const Radius.circular(26),
                    bottomLeft: Radius.circular(item.isUser ? 26 : 10),
                    bottomRight: Radius.circular(item.isUser ? 10 : 26),
                  ),
                  border: Border.all(
                    color: item.isUser
                        ? const Color(0xFFFFF0C7)
                        : AppColors.border,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.text,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        height: 1.55,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.time,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
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