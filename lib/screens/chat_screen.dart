import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';

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
import '../services/chat_service.dart';
import '../services/file_service.dart';
import '../models/chat_message_model.dart';
import 'chat/payment_approval_card.dart';
import 'chat/wallet_password_dialog.dart';
import 'chat/generated_file_card.dart';
import 'chat/payment_completed_card.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ChatService _chatService = ChatService();
  final Map<int, Map<String, dynamic>> _paymentResults = {};
  List<ChatMessageModel> serverMessages = [];
  bool isLoadingMessages = false;
  bool isApprovingPayment = false;

  

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
  ];

  int _selectedSessionIndex = 0;
  String? _statusMessage;
  String? _statusImagePath;
  int? attachedFileId;
  String? attachedFileName;

  List<ApiCostModel> _apiCosts = [];
  String _totalCostUsdc = '0.00 USDC';
  int _totalCostWon = 0;

  ChatSessionModel get _currentSession => _sessions[_selectedSessionIndex];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _refreshMessages() async {
    final sessionId = _currentSession.sessionId;

    if (sessionId == null) {
      setState(() {
        serverMessages = [];
      });
      return;
    }

    try {
      setState(() {
        isLoadingMessages = true;
      });

      final result = await _chatService.getMessages(
        sessionId: sessionId,
      );

      final messages = result
          .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (!mounted) return;

      setState(() {
        serverMessages = messages;
        isLoadingMessages = false;
      });

      _scrollToBottom();
    } catch (e) {
      print('REFRESH MESSAGES ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoadingMessages = false;
      });
    }
  }

  Widget _buildServerMessage(ChatMessageModel message) {
    if (message.isWaitingApproval || message.isCancelled) {
      return PaymentApprovalCard(
        message: message,
        disabled: message.isCancelled,
        completed: false,
        onApprove: () => _handleApprovePayment(message),
        onCancel: () => _handleCancelPayment(message),
      );
    }

    if (message.isAssistant &&
        message.requestStatus == 'COMPLETED' &&
        message.apiItems.isNotEmpty) {
      final result = _paymentResults[message.requestId];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PaymentApprovalCard(
            message: message,
            disabled: false,
            completed: true,
            onApprove: () {},
            onCancel: () {},
          ),
          if (result != null)
            PaymentCompletedCard(
              amount: result['amount'],
              balance: result['balance'],
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment:
          message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        MessageBubble(
          item: ChatItemModel(
            isUser: message.isUser,
            text: message.content.isEmpty ? '내용 없음' : message.content,
            time: '',
          ),
        ),

        if (message.generatedFiles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 58, bottom: 18),
            child: Column(
              children: message.generatedFiles
                  .map((file) => GeneratedFileCard(file: file))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Future<void> _handleApprovePayment(ChatMessageModel message) async {
    if (isApprovingPayment) return;

    final requestId = message.requestId;
    final estimatedCost = message.totalEstimatedCost ?? 0;

    if (requestId == null) return;

    try {
      setState(() {
        isApprovingPayment = true;
      });

      final checkResult = await _chatService.checkPayment(
        estimatedCost: estimatedCost,
      );

      final autoPaymentEnabled =
          checkResult['autoPaymentEnabled'] == true;
      final exceedsPerPaymentLimit =
          checkResult['exceedsPerPaymentLimit'] == true;

      final needPassword =
          !autoPaymentEnabled || exceedsPerPaymentLimit;

      String? walletPassword;

      if (needPassword) {
        walletPassword = await showDialog<String>(
          context: context,
          builder: (_) => const WalletPasswordDialog(),
        );

        if (walletPassword == null || walletPassword.isEmpty) {
          return;
        }
      }

      setState(() {
        _statusMessage = '결제를 진행하고 있어요...';
        _statusImagePath = 'assets/images/tiny6.png';
      });

      final result = await _chatService.approveRequest(
        requestId: requestId,
        estimatedCost: estimatedCost,
        walletPassword: walletPassword,
      );

      _paymentResults[message.requestId!] = {
        'amount': (result['payment']['amount'] as num).toDouble(),
        'balance': (result['wallet']['balance'] as num).toDouble(),
      };

      await _pollRequestStatus(requestId: requestId);
    } catch (e) {
      print('APPROVE PAYMENT ERROR: $e');

      if (!mounted) return;

      setState(() {
        _statusMessage = null;
        _statusImagePath = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isApprovingPayment = false;
      });
    }
  }

  Future<void> _handleCancelPayment(ChatMessageModel message) async {
    final requestId = message.requestId;

    if (requestId == null) return;

    try {
      setState(() {
        _statusMessage = '결제 요청을 취소하고 있어요...';
        _statusImagePath = 'assets/images/tiny6.png';
      });

      await _chatService.cancelRequest(
        requestId: requestId,
      );

      setState(() {
        _statusMessage = null;
        _statusImagePath = null;
      });

      await _refreshMessages();
    } catch (e) {
      print('CANCEL PAYMENT ERROR: $e');

      if (!mounted) return;

      setState(() {
        _statusMessage = null;
        _statusImagePath = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _loadSessions() async {
    print('CHAT SCREEN INIT');

    try {
      final apiSessions = await _chatService.getChatSessions();

      print('SESSION COUNT: ${apiSessions.length}');

      if (!mounted) return;

      if (apiSessions.isEmpty) {
        return;
      }

      setState(() {
        _sessions.clear();

        for (final session in apiSessions) {
          final title = session['title']?.toString() ?? '새 채팅';
          final createdAt = session['createdAt']?.toString() ?? '';
          final sessionId = session['sessionId'] as int?;

          _sessions.add(
            ChatSessionModel(
              sessionId: sessionId,
              title: title,
              subtitle: '무엇을 도와드릴까요?',
              date: createdAt.isEmpty ? '방금' : createdAt,
              messages: [
                const ChatItemModel(
                  isUser: false,
                  text: '안녕하세요! 무엇을 도와드릴까요?',
                  time: '',
                ),
              ],
              showCostCard: false,
              showConfirmCard: false,
              showResultCard: false,
            ),
          );
        }

        _selectedSessionIndex = 0;
      });
      await _refreshMessages();
    } catch (e) {
      print('GET CHAT SESSIONS ERROR: $e');
    }
  }

  Future<void> _attachFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();

      if (result == null || result.files.single.path == null) {
        return;
      }

      final pickedFile = result.files.single;
      final file = File(pickedFile.path!);

      final fileName = pickedFile.name;
      final fileSize = pickedFile.size;
      final fileType =
          lookupMimeType(file.path) ?? 'application/octet-stream';

      final sessionId = _currentSession.sessionId;

      if (sessionId == null) {
        throw Exception('채팅 세션이 없습니다.');
      }

      print('PICKED FILE NAME: $fileName');
      print('PICKED FILE SIZE: $fileSize');
      print('PICKED FILE TYPE: $fileType');

      final uploadData = await FileService().getUploadUrl(
        fileName: fileName,
        fileType: fileType,
        fileSize: fileSize,
        sessionId: sessionId,
      );

      final uploadUrl = uploadData['uploadUrl'];
      final storageKey = uploadData['storageKey'];

      await FileService().uploadFileToS3(
        uploadUrl: uploadUrl,
        file: file,
        fileType: fileType,
      );

      final fileId = await FileService().confirmUpload(
        fileName: fileName,
        fileType: fileType,
        fileSize: fileSize,
        sessionId: sessionId,
        storageKey: storageKey,
      );

      if (!mounted) return;

      setState(() {
        attachedFileId = fileId;
        attachedFileName = fileName;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('파일 첨부 완료: $fileName')),
      );

      print('ATTACHED FILE ID: $fileId');
      final downloadData = await FileService().getDownloadUrl(
        fileId: fileId,
      );

      print('DOWNLOAD URL DATA: $downloadData');
      print('DOWNLOAD URL: ${downloadData['downloadUrl']}');
    } catch (e) {
      print('ATTACH FILE ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

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

    if (text.isEmpty && attachedFileId == null) return;

    final sessionId = _currentSession.sessionId;

    if (sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 새 채팅을 생성해주세요.')),
      );
      return;
    }

    try {
      setState(() {
        _statusMessage = 'Tiny가 요청 내용을 분석하고 있어요...';
        _statusImagePath = 'assets/images/tiny6.png';
      });

      final result = await _chatService.sendMessage(
        sessionId: sessionId,
        content: text,
        fileId: attachedFileId,
      );

      _controller.clear();

      setState(() {
        attachedFileId = null;
        attachedFileName = null;
      });

      final requestId = result['requestId'];

      if (requestId == null) {
        await _refreshMessages();
        return;
      }

      await _pollRequestStatus(requestId: requestId);
    } catch (e) {
      print('SEND MESSAGE ERROR: $e');

      if (!mounted) return;

      setState(() {
        _statusMessage = null;
        _statusImagePath = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _pollRequestStatus({
    required int requestId,
  }) async {
    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      final statusData = await _chatService.getRequestStatus(
        requestId: requestId,
      );

      final requestStatus = statusData['requestStatus'];

      print('POLLING STATUS: $requestStatus');

      if (requestStatus == 'PENDING' ||
          requestStatus == 'ANALYZING') {
        setState(() {
          _statusMessage = 'Tiny가 요청을 처리하고 있어요...';
          _statusImagePath = 'assets/images/tiny6.png';
        });
        continue;
      }

      setState(() {
        _statusMessage = null;
        _statusImagePath = null;
      });

      await _refreshMessages();
      return;
    }

    setState(() {
      _statusMessage = null;
      _statusImagePath = null;
    });

    await _refreshMessages();
  }

  Future<void> _startNewChat() async {
    int? newSessionId;

    try {
      newSessionId = await _chatService.createChatSession();
      print('CREATE CHAT SESSION ID: $newSessionId');
    } catch (e) {
      print('CREATE CHAT SESSION ERROR: $e');
    }

    if (!mounted) return;

    setState(() {
      _sessions.insert(
        0,
        ChatSessionModel(
          sessionId: newSessionId,
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

  Future<void> _selectSession(int index) async {
    setState(() {
      _selectedSessionIndex = index;
      _statusMessage = null;
      _statusImagePath = null;
    });

    Navigator.pop(context);

    await _refreshMessages();
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
                  if (isLoadingMessages)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (serverMessages.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(
                        child: Text(
                          '아직 대화가 없습니다.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  else
                    ...serverMessages.map(_buildServerMessage),
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
                      totalCostUsdc: _totalCostUsdc,
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
              onAttachFile: _attachFile,
            ),
          ],
        ),
      ),
    );
  }
}