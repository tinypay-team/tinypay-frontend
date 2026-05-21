import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';
import 'login_screen.dart';
import '../models/chat_item_model.dart';
import '../models/chat_session_model.dart';
import '../models/api_cost_model.dart';
import '../widgets/chat/message_bubble.dart';
import '../widgets/chat/cost_analysis_card.dart';
import '../widgets/chat/result_card.dart';
import '../widgets/chat/chat_input_area.dart';
import '../widgets/chat/chat_drawer.dart';
import '../widgets/chat/tiny_status_card.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<ChatSessionModel> _sessions = [
    ChatSessionModel(
      title: '새 채팅',
      subtitle: '무엇을 도와드릴까요?',
      date: '방금',
      messages: [
        const ChatItemModel(
          isUser: false,
          text: '안녕하세요! 무엇을 도와드릴까요?',
          time: '오후 03:37',
        ),
      ],
      showCostCard: false,
      showConfirmCard: false,
      showResultCard: false,
    ),
    ChatSessionModel(
      title: '이미지 생성',
      subtitle: '고양이 이미지를 만들어줘',
      date: '2026. 4. 7.',
      messages: [
        const ChatItemModel(
          isUser: false,
          text: '안녕하세요! 무엇을 도와드릴까요?',
          time: '오후 01:15',
        ),
        const ChatItemModel(
          isUser: true,
          text: '귀여운 고양이 이미지를 만들어줘',
          time: '오후 01:16',
        ),
      ],
      showCostCard: false,
      showConfirmCard: false,
      showResultCard: false,
    ),
    ChatSessionModel(
      title: '데이터 분석',
      subtitle: '엑셀 파일 분석 부탁해',
      date: '2026. 4. 6.',
      messages: [
        const ChatItemModel(
          isUser: false,
          text: '안녕하세요! 무엇을 도와드릴까요?',
          time: '오전 11:02',
        ),
        const ChatItemModel(
          isUser: true,
          text: '엑셀 파일 분석 부탁해',
          time: '오전 11:03',
        ),
      ],
      showCostCard: false,
      showConfirmCard: false,
      showResultCard: false,
    ),
  ];

  int _selectedSessionIndex = 0;
  String? _statusMessage;
  String? _statusImagePath;

  final List<ApiCostModel> _apiCosts = const [
    ApiCostModel(name: 'Instagram Reels API', price: '0.006 USDC'),
    ApiCostModel(name: 'Video Analysis API', price: '0.009 USDC'),
    ApiCostModel(name: 'AI Voice Generator API', price: '0.005 USDC'),
  ];

  int get _totalCostWon => 450;

  ChatSessionModel get _currentSession => _sessions[_selectedSessionIndex];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
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

  Future<void> _sendMessage() async {
  final text = _controller.text.trim();
  if (text.isEmpty) return;

  setState(() {
    _currentSession.messages.add(
      ChatItemModel(
        isUser: true,
        text: text,
        time: '오후 03:42',
      ),
    );

    _controller.clear();
    _currentSession.showCostCard = false;
    _currentSession.showResultCard = false;
    _currentSession.subtitle = text;
    _currentSession.title =
        text.length > 12 ? '${text.substring(0, 12)}...' : text;
    _currentSession.date = '방금';

    _statusMessage = 'Tiny가 요청 내용을 분석하고 있어요...';
    _statusImagePath = 'assets/images/tiny6.png';
  });
  _scrollToBottom();

  await Future.delayed(const Duration(seconds: 1));

  if (!mounted) return;
  setState(() {
    _statusMessage = '필요한 API와 예상 비용을 계산하고 있어요...';
    _statusImagePath = 'assets/images/tiny6.png';
  });
  _scrollToBottom();

  await Future.delayed(const Duration(seconds: 1));

  if (!mounted) return;
  setState(() {
    _statusMessage = null;
    _statusImagePath = null;
    _currentSession.showCostCard = true;
  });
  _scrollToBottom();

  await Future.delayed(const Duration(seconds: 1));

  if (!mounted) return;
  setState(() {
    _statusMessage = '자동결제 후 결과를 생성하고 있어요...';
    _statusImagePath = 'assets/images/tiny6.png';
  });
  _scrollToBottom();

  await Future.delayed(const Duration(seconds: 1));

  if (!mounted) return;
  setState(() {
    _statusMessage = null;
    _statusImagePath = null;
    _currentSession.showResultCard = true;
  });
  _scrollToBottom();
}

  void _startNewChat() {
    setState(() {
      _sessions.insert(
        0,
        ChatSessionModel(
          title: '새 채팅',
          subtitle: '무엇을 도와드릴까요?',
          date: '방금',
          messages: [
            const ChatItemModel(
              isUser: false,
              text: '안녕하세요! 무엇을 도와드릴까요?',
              time: '오후 03:50',
            ),
          ],
          showCostCard: false,
          showConfirmCard: false,
          showResultCard: false,
        ),
      );
      _selectedSessionIndex = 0;
      _statusMessage = null;
      _statusImagePath = null;
    });

    Navigator.pop(context);
  }

  void _selectSession(int index) {
    setState(() {
      _selectedSessionIndex = index;
      _statusMessage = null;
      _statusImagePath = null;
    });
    Navigator.pop(context);
    _scrollToBottom();
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
        _sessions[0] = ChatSessionModel(
          title: '새 채팅',
          subtitle: '무엇을 도와드릴까요?',
          date: '방금',
          messages: [
            const ChatItemModel(
              isUser: false,
              text: '안녕하세요! 무엇을 도와드릴까요?',
              time: '오후 03:50',
            ),
          ],
          showCostCard: false,
          showConfirmCard: false,
          showResultCard: false,
        );
        _selectedSessionIndex = 0;
        _statusMessage = null;
        _statusImagePath = null;
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

      _statusMessage = null;
      _statusImagePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: ChatDrawer(
        sessions: _sessions,
        selectedSessionIndex: _selectedSessionIndex,
        onStartNewChat: _startNewChat,
        onSelectSession: _selectSession,
        onDeleteSession: _confirmDeleteSession,
      ),
      appBar: AppBar(
  backgroundColor: AppColors.background,
  elevation: 0,
  scrolledUnderElevation: 0,
  toolbarHeight: 96,
  automaticallyImplyLeading: false,
  titleSpacing: 4,
  title: Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: AppColors.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0F000000),
          blurRadius: 18,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      children: [
        IconButton(
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu_rounded),
          color: AppColors.textPrimary,
        ),

        const SizedBox(width: 10),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tiny AI Agent',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '자동결제 활성화됨',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.circle,
                    color: AppColors.success,
                    size: 8,
                  ),
                ],
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
          color: AppColors.textPrimary,
        ),
      ],
    ),
  ),
),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  ..._currentSession.messages.map(
                    (item) => MessageBubble(item: item),
                  ),
                  if (_statusMessage != null) ...[
                    const SizedBox(height: 12),
                    TinyStatusCard(
                      message: _statusMessage!,
                      imagePath: _statusImagePath ?? 'assets/images/tiny6.png',
                    ),
                  ],
                  if (_currentSession.showCostCard) ...[
                    const SizedBox(height: 16),
                    CostAnalysisCard(
                      apiCosts: _apiCosts,
                      totalCostUsdc: '0.02 USDC',
                      totalCostWon: _totalCostWon,
                    ),
                  ],
                  if (_currentSession.showResultCard) ...[
                    const SizedBox(height: 12),
                    const ResultCard(),
                  ],
                ],
              ),
            ),
            ChatInputArea(
              controller: _controller,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}