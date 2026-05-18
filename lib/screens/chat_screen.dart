import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';
import '../widgets/primary_gradient_button.dart';
import 'login_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<_ChatSessionData> _sessions = [
    _ChatSessionData(
      title: '릴스 제작 요청',
      subtitle: '최근 유행하는 릴스를 분석해서...',
      date: '2026. 4. 7.',
      messages: [
        const _ChatItem(
          isUser: false,
          text: '안녕하세요! 무엇을 도와드릴까요?',
          time: '오후 03:37',
        ),
        const _ChatItem(
          isUser: true,
          text: '최근 유행하는 릴스를 분석해서 비슷한 거 만들어줘',
          time: '오후 03:42',
        ),
      ],
      showCostCard: true,
      showConfirmCard: false,
      showResultCard: false,
    ),
    _ChatSessionData(
      title: '이미지 생성',
      subtitle: '고양이 이미지를 만들어줘',
      date: '2026. 4. 7.',
      messages: [
        const _ChatItem(
          isUser: false,
          text: '안녕하세요! AI Agent Pay입니다. 무엇을 도와드릴까요?',
          time: '오후 01:15',
        ),
        const _ChatItem(
          isUser: true,
          text: '귀여운 고양이 이미지를 만들어줘',
          time: '오후 01:16',
        ),
        const _ChatItem(
          isUser: false,
          text: '이미지 생성을 위해 필요한 API와 예상 비용을 안내드릴게요.',
          time: '오후 01:17',
        ),
      ],
      showCostCard: false,
      showConfirmCard: false,
      showResultCard: false,
    ),
    _ChatSessionData(
      title: '데이터 분석',
      subtitle: '엑셀 파일 분석 부탁해',
      date: '2026. 4. 6.',
      messages: [
        const _ChatItem(
          isUser: false,
          text: '안녕하세요! AI Agent Pay입니다. 무엇을 도와드릴까요?',
          time: '오전 11:02',
        ),
        const _ChatItem(
          isUser: true,
          text: '엑셀 파일 분석 부탁해',
          time: '오전 11:03',
        ),
        const _ChatItem(
          isUser: false,
          text: '파일을 첨부해주시면 분석 가능한 항목을 먼저 안내할게요.',
          time: '오전 11:04',
        ),
      ],
      showCostCard: false,
      showConfirmCard: false,
      showResultCard: false,
    ),
  ];

  int _selectedSessionIndex = 0;

  final List<_ApiCost> _apiCosts = const [
    _ApiCost(name: 'Instagram Reels API', price: '₩150'),
    _ApiCost(name: 'Video Analysis API', price: '₩200'),
    _ApiCost(name: 'AI Voice Generator API', price: '₩100'),
  ];

  int get _totalCostWon => 450;

  _ChatSessionData get _currentSession => _sessions[_selectedSessionIndex];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  void _sendMessage() {
  final text = _controller.text.trim();
  if (text.isEmpty) return;

  setState(() {
    _currentSession.messages.add(
      _ChatItem(
        isUser: true,
        text: text,
        time: '오후 03:42',
      ),
    );

    _controller.clear();

    // 1회 한도 이하라고 가정하고 자동결제 처리
    _currentSession.showCostCard = true;
    _currentSession.showConfirmCard = false;
    _currentSession.showResultCard = true;

    _currentSession.messages.add(
      const _ChatItem(
        isUser: false,
        text: '예상 비용이 1회 한도 이하라서 자동결제가 완료되었어요. 요청하신 내용을 정리해드릴게요.',
        time: '오후 03:45',
      ),
    );

    _currentSession.subtitle = text;
    _currentSession.date = '방금';
  });
}

  void _showConfirm() {
    setState(() {
      _currentSession.showConfirmCard = true;
    });
  }

  void _approvePayment() {
    setState(() {
      _currentSession.showConfirmCard = false;
      _currentSession.showResultCard = true;
      _currentSession.messages.add(
        const _ChatItem(
          isUser: false,
          text: '요청이 승인되었어요. 분석을 완료했고, 비슷한 릴스 제작 방향을 아래처럼 정리했어요.',
          time: '오후 03:45',
        ),
      );
    });
  }

  void _cancelPayment() {
    setState(() {
      _currentSession.showConfirmCard = false;
    });
  }

  void _startNewChat() {
    setState(() {
      _sessions.insert(
        0,
        _ChatSessionData(
          title: '새 채팅',
          subtitle: '무엇을 도와드릴까요?',
          date: '방금',
          messages: [
            const _ChatItem(
              isUser: false,
              text: '새 채팅이 시작되었어요. 무엇을 도와드릴까요?',
              time: '오후 03:50',
            ),
          ],
          showCostCard: false,
          showConfirmCard: false,
          showResultCard: false,
        ),
      );
      _selectedSessionIndex = 0;
    });

    Navigator.pop(context);
  }

  void _selectSession(int index) {
    setState(() {
      _selectedSessionIndex = index;
    });
    Navigator.pop(context);
  }

  Future<void> _confirmDeleteSession(int index) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('채팅 삭제'),
          content: Text(
            '"${_sessions[index].title}" 채팅을 정말 삭제할까요?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                '삭제',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    if (_sessions.length == 1) {
      setState(() {
        _sessions[0] = _ChatSessionData(
          title: '새 채팅',
          subtitle: '무엇을 도와드릴까요?',
          date: '방금',
          messages: [
            const _ChatItem(
              isUser: false,
              text: '새 채팅이 시작되었어요. 무엇을 도와드릴까요?',
              time: '오후 03:50',
            ),
          ],
          showCostCard: false,
          showConfirmCard: false,
          showResultCard: false,
        );
        _selectedSessionIndex = 0;
      });
      return;
    }

    setState(() {
      _sessions.removeAt(index);

      if (_selectedSessionIndex >= _sessions.length) {
        _selectedSessionIndex = _sessions.length - 1;
      } else if (index < _selectedSessionIndex) {
        _selectedSessionIndex -= 1;
      } else if (index == _selectedSessionIndex) {
        _selectedSessionIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu_rounded),
          color: AppColors.textPrimary,
        ),
        title: const Row(
          children: [
            Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'TINY',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
            color: AppColors.textPrimary,
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            color: AppColors.textPrimary,
            tooltip: '로그아웃',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  ..._currentSession.messages.map(_buildMessageBubble),
                  if (_currentSession.showCostCard) ...[
                    const SizedBox(height: 16),
                    _buildCostAnalysisCard(),
                  ],
                  if (_currentSession.showConfirmCard) ...[
                    const SizedBox(height: 12),
                    _buildConfirmCard(),
                  ],
                  if (_currentSession.showResultCard) ...[
                    const SizedBox(height: 12),
                    _buildResultCard(),
                  ],
                ],
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '채팅 세션',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryGradientButton(
                text: '새 채팅',
                icon: Icons.add,
                onPressed: _startNewChat,
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _sessions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final session = _sessions[index];
                  final bool isSelected = index == _selectedSessionIndex;

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _selectSession(index),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFF3F0FF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: const Color(0xFFD9CFFF))
                            : null,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.title,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
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
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _confirmDeleteSession(index),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildMessageBubble(_ChatItem item) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Row(
      mainAxisAlignment:
          item.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Tiny 캐릭터 (AI 메시지일 때만)
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

        /// 메시지 버블
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: item.isUser
                    ? const Color(0xFFFFF7DD)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(26),
                  topRight: const Radius.circular(26),
                  bottomLeft:
                      Radius.circular(item.isUser ? 26 : 10),
                  bottomRight:
                      Radius.circular(item.isUser ? 10 : 26),
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

  Widget _buildCostAnalysisCard() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: AppColors.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0F000000),
          blurRadius: 18,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '사용할 API 및 예상 비용',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'Tiny가 필요한 API를 계산했어요',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        ..._apiCosts.map(
          (api) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: AppColors.success,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    api.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                Text(
                  api.price,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),

        const Divider(
          height: 24,
          color: AppColors.border,
        ),

        const SizedBox(height: 4),

        Row(
          children: [
            const Text(
              '총 예상 비용',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),

            const Spacer(),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '0.02 USDC',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),

                Text(
                  '≈ ₩$_totalCostWon',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 18),

        /// 자동결제 완료 상태 카드
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF5FAF7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFD8F0DF),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 24,
              ),

              SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '자동결제가 완료되었어요',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      '1회 한도 이하 금액이라 자동 승인되었어요.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildConfirmCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '결제를 진행할까요?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '총 예상 비용은 ₩$_totalCostWon 입니다.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelPayment,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryGradientButton(
                  text: '확인',
                  onPressed: _approvePayment,
                  height: 50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.success),
              SizedBox(width: 8),
              Text(
                '요청 처리 완료',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '1. 최근 유행 릴스는 짧고 강한 첫 3초가 중요합니다.\n'
            '2. 자막은 큰 글씨와 빠른 템포가 유리합니다.\n'
            '3. 배경음은 트렌디한 비트형이 적합합니다.',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
  return Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
    decoration: const BoxDecoration(
      color: AppColors.background,
    ),
    child: SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {},
                icon: const Icon(
                  Icons.add_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  hintText: 'Tiny에게 물어보세요',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x336F8CFF),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: _sendMessage,
                icon: const Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildAttachButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatItem {
  final bool isUser;
  final String text;
  final String time;

  const _ChatItem({
    required this.isUser,
    required this.text,
    required this.time,
  });
}

class _ChatSessionData {
  String title;
  String subtitle;
  String date;
  List<_ChatItem> messages;
  bool showCostCard;
  bool showConfirmCard;
  bool showResultCard;

  _ChatSessionData({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.messages,
    required this.showCostCard,
    required this.showConfirmCard,
    required this.showResultCard,
  });
}

class _ApiCost {
  final String name;
  final String price;

  const _ApiCost({
    required this.name,
    required this.price,
  });
}