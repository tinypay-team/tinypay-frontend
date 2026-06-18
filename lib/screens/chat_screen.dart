import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';

import '../theme/app_colors.dart';
import '../utils/auto_payment_notifier.dart';
import '../utils/payment_notifier.dart';
import 'login_screen.dart';
import '../models/chat_item_model.dart';
import '../models/chat_session_model.dart';
import '../models/api_cost_model.dart';
import '../widgets/chat/message_bubble.dart';
import '../widgets/chat/cost_analysis_card.dart';
import '../widgets/chat/result_card.dart';
import '../widgets/chat/chat_input_area.dart';
import '../widgets/chat/chat_drawer.dart';
import '../services/chat_service.dart';
import '../services/file_service.dart';
import '../models/chat_message_model.dart';
import '../utils/format_utils.dart';
import 'chat/payment_approval_card.dart';
import 'chat/wallet_password_dialog.dart';
import 'chat/generated_file_card.dart';
// payment_completed_card removed;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ChatService _chatService = ChatService();
  List<ChatMessageModel> serverMessages = [];
  bool isLoadingMessages = false;
  bool isApprovingPayment = false;

  

  final List<ChatSessionModel> _sessions = [];

  int _selectedSessionIndex = 0;
  bool _isNewChatPending = false; // 새 채팅 대기 상태 (세션 미생성)
  String? _statusMessage;
  String? _statusImagePath; // 내부 상태용 (버블에서 직접 사용하지 않음)

  // 결제 승인 완료된 requestId 집합 — 서버 응답 전에 즉시 "완료됨" 표시용
  final Set<int> _approvedRequestIds = {};

  // 탭/스크롤 구분용 — 포인터 이동 거리가 작으면 탭으로 판단해 키보드 닫기
  bool _pointerMoved = false;

  // 로컬에서 숨긴 세션 ID (서버에 삭제 API 없으므로 프론트에서만 필터링)
  final Set<int> _hiddenSessionIds = {};
  static const String _hiddenSessionsKey = 'hiddenSessionIds';
  int? attachedFileId;
  String? attachedFileName;

  List<ApiCostModel> _apiCosts = [];
  String _totalCostUsdc = '0.00 USDC';
  int _totalCostWon = 0;

  ChatSessionModel? get _currentSession {
    if (_isNewChatPending || _sessions.isEmpty) return null;
    if (_selectedSessionIndex >= _sessions.length) return null;
    return _sessions[_selectedSessionIndex];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncAutoPaymentNotifier();
    _loadHiddenIds().then((_) => _loadSessions());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncAutoPaymentNotifier();
    }
  }

  // 키보드 올라올 때 맨 아래로 스크롤
  double _lastBottomInset = 0;
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = View.of(context).viewInsets.bottom;
    if (bottomInset > _lastBottomInset + 50) {
      // 키보드가 새로 올라온 경우
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
    _lastBottomInset = bottomInset;
  }

  // SharedPreferences → autoPaymentNotifier 동기화
  // (앱 시작 또는 포그라운드 복귀 시)
  Future<void> _syncAutoPaymentNotifier() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('autoPaymentEnabled') ?? false;
    autoPaymentNotifier.value = enabled;
  }

  Future<void> _refreshMessages({bool showLoading = false}) async {
    final sessionId = _currentSession?.sessionId;

    if (sessionId == null) return; // 세션 없으면 기존 메시지 유지 (지우지 않음)

    try {
      // 폴링 중에는 로딩 스피너 없이 조용히 갱신 (스크롤 위치 유지)
      if (showLoading) {
        setState(() { isLoadingMessages = true; });
      }

      final result = await _chatService.getMessages(
        sessionId: sessionId,
      );

      final messages = result
          .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // ── 디버그 로그: 서버에서 받은 메시지 목록 ──
      print('┌── [MESSAGES] 총 ${messages.length}개 ──────────────────');
      for (final m in messages) {
        print('│ [${m.messageId}] role=${m.senderRole} '
            'type=${m.messageType} '
            'reqId=${m.requestId} '
            'reqStatus=${m.requestStatus} '
            'files=${m.generatedFiles.length} '
            'content="${m.content.length > 40 ? m.content.substring(0, 40) + "…" : m.content}"');
      }
      print('└────────────────────────────────────────────────');

      if (!mounted) return;

      setState(() {
        serverMessages = messages;
        isLoadingMessages = false;
      });

      // 새 메시지 로드 후 스크롤
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      print('REFRESH MESSAGES ERROR: $e');
      if (!mounted) return;
      setState(() { isLoadingMessages = false; });
    }
  }

  // 결제카드를 아바타와 함께 감싸는 헬퍼
  Widget _wrapWithAvatar(Widget card) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MessageBubble.buildAvatar(),
          const SizedBox(width: 8),
          Expanded(child: card),
        ],
      ),
    );
  }

  Widget _buildServerMessage(ChatMessageModel message) {
    // ── 결제 카드: apiItems 있으면 상태(대기/취소/진행중/완료) 무관하게 항상 카드로 표시
    // EXECUTING 중에도 사라지지 않도록 isWaitingApproval/isCancelled 외에도 커버
    final isPaymentMessage = message.isAssistant &&
        (message.apiItems.isNotEmpty || message.totalEstimatedCost != null);

    if (message.isWaitingApproval || message.isCancelled || isPaymentMessage) {
      final isLocallyApproved = message.requestId != null &&
          _approvedRequestIds.contains(message.requestId);
      // 완료됨: 로컬 승인 완료 OR 서버 상태가 COMPLETED
      final isCompleted = isLocallyApproved || message.requestStatus == 'COMPLETED';
      // 버튼 비활성: 취소됨 or 이미 완료
      final isDisabledOrDone = message.isCancelled || isCompleted;
      return _wrapWithAvatar(
        PaymentApprovalCard(
          message: message,
          disabled: message.isCancelled,
          completed: isCompleted,
          onApprove: isDisabledOrDone ? () {} : () => _handleApprovePayment(message),
          onCancel: isDisabledOrDone ? () {} : () => _handleCancelPayment(message),
        ),
      );
    }

    // ── 3. 기본: 텍스트 버블 + 생성 파일 ──
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
            padding: const EdgeInsets.only(left: 50, bottom: 18),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: message.generatedFiles
                    .map((file) => GeneratedFileCard(
                          file: file,
                          onClosed: () {
                            // route 전환 애니메이션 완료 후 강제 스크롤
                            Future.delayed(const Duration(milliseconds: 400), () {
                              if (!_scrollController.hasClients) return;
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeOut,
                              );
                            });
                          },
                        ))
                    .toList(),
              ),
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

      if (needPassword) {
        // ── PIN 입력 (onSubmit 콜백으로 내부 에러 관리 — 다이얼로그 재생성 없음) ──
        if (!mounted) return;

        // onSubmit: 성공 → null 반환 (다이얼로그 닫힘), 실패 → 에러 문자열 반환 (다이얼로그 유지)
        Map<String, dynamic>? approveResult;
        String? snackBarError;

        final approvedPin = await showDialog<String>(
          context: context,
          builder: (_) => WalletPasswordDialog(
            onSubmit: (pin) async {
              try {
                final result = await _chatService.approveRequest(
                  requestId: requestId,
                  estimatedCost: estimatedCost,
                  walletPassword: pin,
                );
                // 성공 — 결과 저장 후 null 반환 (다이얼로그 닫힘)
                approveResult = result;
                return null;
              } catch (e) {
                final err = e.toString().toLowerCase();
                final isWrongPin = err.contains('password') ||
                    err.contains('pin') ||
                    err.contains('비밀번호') ||
                    err.contains('401') ||
                    err.contains('unauthorized') ||
                    err.contains('incorrect') ||
                    err.contains('invalid');
                if (isWrongPin) {
                  return '비밀번호가 올바르지 않아요. 다시 입력해주세요.';
                }
                // 다른 에러는 스낵바로 표시 후 다이얼로그 닫기
                snackBarError = e.toString();
                return null; // 다이얼로그를 닫고 아래에서 처리
              }
            },
          ),
        );

        if (snackBarError != null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(snackBarError!)),
          );
          return;
        }

        // 취소 (approvedPin == null) 또는 approveResult 없음
        if (approvedPin == null || approveResult == null) return;

        if (!mounted) return;
        // ── 결제 승인 완료 즉시 카드 "완료됨"으로 전환 ──
        setState(() {
          _approvedRequestIds.add(requestId);
          _statusMessage = '결제를 진행하고 있어요...';
          _statusImagePath = 'assets/images/tiny6.png';
        });
        _scrollToBottom();

        paymentCompletedNotifier.value++; // 즉시: 잔액 갱신
        await _pollRequestStatus(requestId: requestId);
        // 결제 후 이미지/파일 생성 완료까지 추가 대기 (requestId 로 범위 한정)
        await _pollForGeneratedFiles(requestId: requestId);
        paymentCompletedNotifier.value++; // Dify 완료 후: serviceName 갱신
        return;
      } else {
        // 자동결제 (PIN 불필요)
        setState(() {
          _statusMessage = '결제를 진행하고 있어요...';
          _statusImagePath = 'assets/images/tiny6.png';
        });

        await _chatService.approveRequest(
          requestId: requestId,
          estimatedCost: estimatedCost,
          walletPassword: null,
        );

        if (!mounted) return;
        // ── 자동결제 완료 즉시 카드 "완료됨"으로 전환 ──
        setState(() {
          _approvedRequestIds.add(requestId);
        });
        _scrollToBottom();

        paymentCompletedNotifier.value++; // 즉시: 잔액 갱신
        await _pollRequestStatus(requestId: requestId);
        // 결제 후 이미지/파일 생성 완료까지 추가 대기 (requestId 로 범위 한정)
        await _pollForGeneratedFiles(requestId: requestId);
        paymentCompletedNotifier.value++; // Dify 완료 후: serviceName 갱신
      }
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

  Future<void> _loadHiddenIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_hiddenSessionsKey) ?? [];
    _hiddenSessionIds.addAll(ids.map((e) => int.tryParse(e)).whereType<int>());
  }

  Future<void> _saveHiddenId(int sessionId) async {
    _hiddenSessionIds.add(sessionId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _hiddenSessionsKey, _hiddenSessionIds.map((e) => e.toString()).toList());
  }

  Future<void> _loadSessions() async {
    try {
      final apiSessions = await _chatService.getChatSessions();
      if (!mounted) return;

      setState(() {
        _sessions.clear();
        for (final session in apiSessions) {
          final sessionId = session['sessionId'] as int?;
          if (sessionId != null && _hiddenSessionIds.contains(sessionId)) continue;
          final title = session['title']?.toString() ?? '새 채팅';
          final createdAt = session['createdAt']?.toString() ?? '';
          final preview = session['preview']?.toString();

          _sessions.add(ChatSessionModel(
            sessionId: sessionId,
            title: title,
            subtitle: preview ?? '대화를 시작해보세요',
            date: createdAt.isEmpty ? '방금' : formatSessionDate(createdAt),
            messages: [],
            showCostCard: false,
            showConfirmCard: false,
            showResultCard: false,
          ));
        }
        _selectedSessionIndex = 0;
        serverMessages = [];
      });

      if (_sessions.isNotEmpty) await _refreshMessages(showLoading: true);
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

      final sessionId = _currentSession?.sessionId;

      if (sessionId == null) {
        throw Exception('먼저 채팅을 시작해주세요.');
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

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 180), () {
      if (!_scrollController.hasClients) return;
      final pos = _scrollController.position;
      final target = pos.maxScrollExtent;
      // 현재 위치보다 아래일 때만 스크롤 (절대 위로 올라가지 않음)
      if (target <= pos.pixels) return;
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('deletedSessionIds');
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('autoPaymentEnabled');
    await prefs.remove('userAvatarEmoji');
    autoPaymentNotifier.value = false;

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

    // 세션 없으면 자동 생성
    int? sessionId = _currentSession?.sessionId;
    if (sessionId == null) {
      try {
        final newId = await _chatService.createChatSession();
        if (!mounted) return;
        setState(() {
          _isNewChatPending = false;
          _sessions.insert(0, ChatSessionModel(
            sessionId: newId,
            title: '새 채팅',
            subtitle: '대화를 시작해보세요',
            date: '방금',
            messages: [],
            showCostCard: false,
            showConfirmCard: false,
            showResultCard: false,
          ));
          _selectedSessionIndex = 0;
        });
        sessionId = newId;
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('채팅 생성 실패: $e')),
        );
        return;
      }
    }

    if (sessionId == null) return;

    // 파일 ID 미리 캡처 (setState에서 null 처리 전)
    final capturedFileId = attachedFileId;

    // ─── 낙관적 업데이트: 전송 즉시 내 메시지 표시, 로딩은 그 아래 ───
    final optimisticMsg = ChatMessageModel(
      messageId: -1,
      senderRole: 'USER',
      messageType: 'TEXT',
      content: text,
      requestId: null,
      requestStatus: null,
      apiItems: [],
      totalEstimatedCost: null,
      generatedFiles: [],
      fileId: null,
      fileName: null,
      fileType: null,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
    _controller.clear();
    setState(() {
      serverMessages = [...serverMessages, optimisticMsg];
      attachedFileId = null;
      attachedFileName = null;
      _statusMessage = 'Tiny가 요청 내용을 분석하고 있어요...';
      _statusImagePath = 'assets/images/tiny6.png';
    });
    _scrollToBottom();

    try {
      final result = await _chatService.sendMessage(
        sessionId: sessionId,
        content: text,
        fileId: capturedFileId,
      );

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
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      final statusData = await _chatService.getRequestStatus(
        requestId: requestId,
      );

      final requestStatus = statusData['requestStatus'];

      print('┌── [POLL #$i] requestId=$requestId ──────────────');
      print('│ requestStatus = $requestStatus');
      print('│ fullResponse  = $statusData');
      print('└────────────────────────────────────────────────');

      if (requestStatus == 'PENDING' ||
          requestStatus == 'ANALYZING') {
        setState(() {
          _statusMessage = 'Tiny가 요청을 처리하고 있어요...';
          _statusImagePath = 'assets/images/tiny6.png';
        });
        _scrollToBottom();
        continue;
      }

      setState(() {
        _statusMessage = null;
        _statusImagePath = null;
      });

      await _refreshMessages();
      await _refreshSessionList(); // 제목/preview 업데이트
      _scrollToBottom();
      return;
    }

    setState(() {
      _statusMessage = null;
      _statusImagePath = null;
    });

    await _refreshMessages();
    await _refreshSessionList();
    _scrollToBottom();
  }

  /// 결제 완료 후 이미지/파일 생성을 기다리는 보조 폴링
  /// - 서버가 결제 COMPLETED 처리 후 백그라운드에서 파일을 생성하는 경우 대응
  /// - 파일이 나타나거나, 새 WAITING_APPROVAL이 생기거나, 60초 타임아웃되면 종료
  /// 결제카드가 아닌 COMPLETED 어시스턴트 결과 메시지가 이미 있는지 확인
  /// [forRequestId] 를 지정하면 해당 requestId 의 메시지만 검사 (이전 대화 ANSWER 와 혼동 방지)
  bool _hasResultMessage({int? forRequestId}) {
    return serverMessages.any((m) =>
        m.isAssistant &&
        m.requestStatus == 'COMPLETED' &&
        m.apiItems.isEmpty &&
        m.totalEstimatedCost == null &&
        (forRequestId == null || m.requestId == forRequestId));
  }

  Future<void> _pollForGeneratedFiles({int? requestId}) async {
    const maxWait = 60; // 최대 60초 대기
    const interval = 2; // 2초마다 확인

    // requestId 지정 시 해당 요청의 파일/결과만 확인 (이전 대화 ANSWER 와 혼동 방지)
    bool hasFiles() => requestId != null
        ? serverMessages.any((m) => m.requestId == requestId && m.generatedFiles.isNotEmpty)
        : serverMessages.any((m) => m.generatedFiles.isNotEmpty);

    // 이미 파일 또는 결과 텍스트 메시지가 있으면 폴링 불필요
    if (hasFiles() || _hasResultMessage(forRequestId: requestId)) {
      print('[pollForFiles] 이미 결과 존재 → 폴링 스킵');
      _scrollToBottom();
      return;
    }

    setState(() {
      _statusMessage = 'Tiny가 결과를 생성하고 있어요...';
      _statusImagePath = 'assets/images/tiny6.png';
    });
    _scrollToBottom();

    for (int i = 0; i < maxWait ~/ interval; i++) {
      await Future.delayed(const Duration(seconds: interval));
      if (!mounted) return;

      await _refreshMessages();

      // 생성된 파일이 있으면 완료
      if (hasFiles()) {
        print('[pollForFiles] 파일 발견! 종료 (iteration $i)');
        setState(() { _statusMessage = null; _statusImagePath = null; });
        _scrollToBottom();
        return;
      }

      // 결과 텍스트 메시지가 생기면 즉시 종료 (파일 없는 텍스트 응답)
      if (_hasResultMessage(forRequestId: requestId)) {
        print('[pollForFiles] 결과 메시지 감지! 종료 (iteration $i)');
        setState(() { _statusMessage = null; _statusImagePath = null; });
        _scrollToBottom();
        return;
      }

      print('[pollForFiles] iteration $i — 결과 없음, 계속 대기...');
    }

    // 타임아웃
    print('[pollForFiles] 타임아웃');
    if (!mounted) return;
    setState(() { _statusMessage = null; _statusImagePath = null; });
  }

  // 현재 선택된 세션 유지하면서 세션 목록만 새로고침
  Future<void> _refreshSessionList() async {
    final currentSessionId = _currentSession?.sessionId;
    try {
      final apiSessions = await _chatService.getChatSessions();
      if (!mounted) return;
      setState(() {
        _sessions.clear();
        for (final session in apiSessions) {
          final sessionId = session['sessionId'] as int?;
          if (sessionId != null && _hiddenSessionIds.contains(sessionId)) continue;
          final rawDate = session['createdAt']?.toString() ?? '';
          _sessions.add(ChatSessionModel(
            sessionId: sessionId,
            title: session['title']?.toString() ?? '새 채팅',
            subtitle: session['preview']?.toString() ?? '대화를 시작해보세요',
            date: rawDate.isEmpty ? '방금' : formatSessionDate(rawDate),
            messages: [],
            showCostCard: false,
            showConfirmCard: false,
            showResultCard: false,
          ));
        }
        // 선택된 세션 복원
        if (currentSessionId != null) {
          final idx = _sessions.indexWhere((s) => s.sessionId == currentSessionId);
          _selectedSessionIndex = idx >= 0 ? idx : 0;
        }
      });
    } catch (e) {
      print('REFRESH SESSION LIST ERROR: $e');
    }
  }

  Future<void> _startNewChat() async {
    Navigator.pop(context); // 드로어 먼저 닫기

    // 즉시 세션 생성 → 목록에 바로 표시
    try {
      final newId = await _chatService.createChatSession();
      if (!mounted) return;
      setState(() {
        _isNewChatPending = false;
        _sessions.insert(0, ChatSessionModel(
          sessionId: newId,
          title: '새 채팅',
          subtitle: '대화를 시작해보세요',
          date: '방금',
          messages: [],
          showCostCard: false,
          showConfirmCard: false,
          showResultCard: false,
        ));
        _selectedSessionIndex = 0;
        serverMessages = [];
        _statusMessage = null;
        _approvedRequestIds.clear();
      });
    } catch (e) {
      // 생성 실패 시 pending 상태로 fallback
      if (!mounted) return;
      setState(() {
        _isNewChatPending = true;
        serverMessages = [];
        _statusMessage = null;
      });
    }
  }

  Future<void> _selectSession(int index) async {
    setState(() {
      _selectedSessionIndex = index;
      _isNewChatPending = false;
      _statusMessage = null;
      _approvedRequestIds.clear(); // 세션 전환 시 낙관적 상태 초기화
      serverMessages = []; // 이전 세션 메시지 즉시 비우기 (잔상 방지)
    });

    Navigator.pop(context);

    await _refreshMessages(showLoading: true);
  }

  Future<void> _confirmDeleteSession(int index) async {
    final sessionId = _sessions[index].sessionId;
    if (sessionId != null) {
      await _saveHiddenId(sessionId);
    }

    if (!mounted) return;

    if (_sessions.length == 1) {
      setState(() {
        _sessions.clear();
        serverMessages = [];
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

    await _refreshMessages();
  }

  Future<void> _deleteAllSessions() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전체 채팅 삭제'),
        content: const Text('모든 채팅 내역을 삭제할까요?\n이 작업은 되돌릴 수 없어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    for (final session in _sessions) {
      if (session.sessionId != null) {
        try {
          await _chatService.deleteSession(sessionId: session.sessionId!);
        } catch (e) {
          print('DELETE ALL ERROR: $e');
        }
      }
    }

    if (!mounted) return;

    Navigator.pop(context); // 드로어 닫기

    setState(() {
      _sessions.clear();
      serverMessages = [];
      _selectedSessionIndex = 0;
      _statusMessage = null;
      _statusImagePath = null;
    });
  }

  // 분석/처리 중 상태 버블 (AI 말풍선과 동일 스타일)
  Widget _buildStatusBubble() {
    final maxWidth = MediaQuery.of(context).size.width * 0.72;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          MessageBubble.buildAvatar(),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      _statusMessage!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 인사말 버블 (AI 말풍선과 동일 스타일)
  Widget _buildGreetingMessage() {
    final maxWidth = MediaQuery.of(context).size.width * 0.72;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          MessageBubble.buildAvatar(),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: const Text(
                '안녕하세요! 👋\n무엇을 도와드릴까요?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.55,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
        onDeleteAllSessions: _deleteAllSessions,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tiny AI Agent',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ValueListenableBuilder<bool>(
                      valueListenable: autoPaymentNotifier,
                      builder: (context, enabled, _) {
                        return Row(
                          children: [
                            Icon(
                              Icons.circle,
                              color: enabled
                                  ? AppColors.success
                                  : const Color(0xFFBBBBBB),
                              size: 8,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              enabled ? '자동결제 활성화됨' : '자동결제 비활성화됨',
                              style: TextStyle(
                                color: enabled
                                    ? AppColors.textSecondary
                                    : const Color(0xFFBBBBBB),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        );
                      },
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
                child: Stack(
                  children: [
                    Listener(
                      behavior: HitTestBehavior.translucent,
                      onPointerDown: (_) { _pointerMoved = false; },
                      onPointerMove: (e) {
                        if (e.delta.distance > 3) _pointerMoved = true;
                      },
                      onPointerUp: (_) {
                        if (!_pointerMoved) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        }
                      },
                      child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      children: [
                        _buildGreetingMessage(),
                        ...serverMessages.map(_buildServerMessage),
                        if (_statusMessage != null)
                          _buildStatusBubble(),
                        if (_currentSession?.showCostCard == true) ...[
                          const SizedBox(height: 16),
                          CostAnalysisCard(
                            apiCosts: _apiCosts,
                            totalCostUsdc: _totalCostUsdc,
                            totalCostWon: _totalCostWon,
                          ),
                        ],
                        if (_currentSession?.showResultCard == true) ...[
                          const SizedBox(height: 12),
                          const ResultCard(),
                        ],
                      ],
                    ),   // ListView
                    ), // Listener
                    // 최초 세션 진입 시 상단에 얇은 로딩 바 (ListView는 유지)
                    if (isLoadingMessages)
                      const Positioned(
                        top: 0, left: 0, right: 0,
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
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