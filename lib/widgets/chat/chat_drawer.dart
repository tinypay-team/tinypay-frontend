import 'package:flutter/material.dart';

import '../../models/chat_session_model.dart';
import '../../theme/app_colors.dart';

class ChatDrawer extends StatelessWidget {
  final List<ChatSessionModel> sessions;
  final int selectedSessionIndex;
  final VoidCallback onStartNewChat;
  final Function(int index) onSelectSession;
  final Function(int index) onDeleteSession;
  final VoidCallback? onDeleteAllSessions;

  const ChatDrawer({
    super.key,
    required this.sessions,
    required this.selectedSessionIndex,
    required this.onStartNewChat,
    required this.onSelectSession,
    required this.onDeleteSession,
    this.onDeleteAllSessions,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF7F9FF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 헤더 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (b) =>
                          AppColors.primaryGradient.createShader(b),
                      child: const Text(
                        'Tiny AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  // 전체 삭제 버튼
                  if (sessions.isNotEmpty && onDeleteAllSessions != null)
                    GestureDetector(
                      onTap: onDeleteAllSessions,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_sweep_rounded,
                          color: AppColors.textSecondary,
                          size: 24,
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  // 닫기 버튼 — 테두리 없이 아이콘만
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.textSecondary,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── 새 채팅 버튼 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: GestureDetector(
                onTap: onStartNewChat,
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x306F8CFF),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 6),
                      Text(
                        '새 채팅',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── 세션 목록 ──
            Expanded(
              child: sessions.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                      itemCount: sessions.length,
                      itemBuilder: (_, i) {
                        final session = sessions[i];
                        return Dismissible(
                          key: Key('session_${session.sessionId}_$i'),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => onDeleteSession(i),
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF5A5A),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.delete_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          child: _SessionTile(
                            session: session,
                            isSelected: i == selectedSessionIndex,
                            onTap: () => onSelectSession(i),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_rounded,
            color: AppColors.primary.withAlpha(70),
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            '채팅이 없어요',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────
// 세션 타일
// ─────────────────────────────────────
class _SessionTile extends StatelessWidget {
  final ChatSessionModel session;
  final bool isSelected;
  final VoidCallback onTap;

  const _SessionTile({
    required this.session,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 22),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isSelected ? Border.all(color: AppColors.border) : null,
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // 채팅 아이콘
            Container(
              width: 58,
              height: 58,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withAlpha(22)
                    : const Color(0xFFEEF0FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.chat_rounded,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary.withAlpha(160),
                size: 28,
              ),
            ),

            // 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    session.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    session.date,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary.withAlpha(140),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
