import 'package:flutter/material.dart';

import '../../models/payment_model.dart';
import '../../models/payment_detail_model.dart';
import '../../services/mypage_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/format_utils.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  final MyPageService _service = MyPageService();

  final List<PaymentModel> _payments = [];
  int? _nextCursor;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _payments.clear();
        _nextCursor = null;
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final result = await _service.getPayments();
      if (!mounted) return;
      setState(() {
        _payments.addAll(result.payments);
        _nextCursor = result.nextCursor;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _nextCursor == null) return;
    setState(() => _isLoadingMore = true);

    try {
      final result = await _service.getPayments(cursor: _nextCursor);
      if (!mounted) return;
      setState(() {
        _payments.addAll(result.payments);
        _nextCursor = result.nextCursor;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _showDetail(PaymentModel item) {
    if (item.paymentId == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentDetailSheet(payment: item, service: _service),
    );
  }

  double get _totalAmount => _payments.fold(0, (s, p) => s + p.paidAmount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8FC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
        ),
        title: const Text(
          '전체 결제 내역',
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: () => _loadPayments(refresh: true),
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.textSecondary, size: 22),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildError()
                    : _payments.isEmpty
                        ? _buildEmpty()
                        : _buildContent(),
          ),
          // ─── 총계 하단 고정 ───
          if (!_isLoading && _error == null && _payments.isNotEmpty)
            _buildTotalBar(),
        ],
      ),
    );
  }

  Widget _buildTotalBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
              color: Color(0x12000000),
              blurRadius: 16,
              offset: Offset(0, -4)),
        ],
        border: Border(
          top: BorderSide(color: const Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_rounded,
              color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 10),
          Text(
            '총 ${_payments.length}건',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            'USDC ${formatUsdc(_totalAmount)}',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.danger, size: 48),
          const SizedBox(height: 12),
          const Text('불러오기 실패',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          TextButton(
              onPressed: () => _loadPayments(refresh: true),
              child: const Text('다시 시도')),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0FF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: AppColors.primary, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('아직 결제 내역이 없어요',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('AI 서비스를 이용하면 결제 내역이 여기에 나타나요',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: () => _loadPayments(refresh: true),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // 결제 목록 (각 아이템 개별 카드)
          for (final payment in _payments)
            _PaymentCard(
              payment: payment,
              onTap: () => _showDetail(payment),
            ),

          // 더 보기 버튼
          if (_nextCursor != null) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _isLoadingMore ? null : _loadMore,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoadingMore
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('더 보기',
                        style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// 결제 목록 카드 (스크린샷 스타일)
// ──────────────────────────────────────────────

class _PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  final VoidCallback onTap;

  const _PaymentCard({required this.payment, required this.onTap});

  IconData get _icon {
    final t = payment.title.toLowerCase();
    if (t.contains('pdf')) return Icons.picture_as_pdf_rounded;
    if (t.contains('이미지') || t.contains('image') || t.contains('img')) return Icons.image_rounded;
    return Icons.auto_awesome_rounded;
  }

  Color get _iconColor => AppColors.primary; // 색상 통일

  Color get _iconBg => const Color(0xFFEEF0FF); // 배경 통일

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_icon, color: _iconColor, size: 22),
            ),
            const SizedBox(width: 14),

            // 서비스명 + 날짜
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.title.isNotEmpty ? payment.title : 'AI 서비스',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    payment.rawTime.isNotEmpty
                        ? formatDateTime(payment.rawTime)
                        : '날짜 없음',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // 금액
            Text(
              'USDC ${formatUsdc(payment.paidAmount)}',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// 결제 상세 바텀시트
// ──────────────────────────────────────────────

class _PaymentDetailSheet extends StatefulWidget {
  final PaymentModel payment;
  final MyPageService service;

  const _PaymentDetailSheet({required this.payment, required this.service});

  @override
  State<_PaymentDetailSheet> createState() => _PaymentDetailSheetState();
}

class _PaymentDetailSheetState extends State<_PaymentDetailSheet> {
  PaymentDetailModel? _detail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final detail =
          await widget.service.getPaymentDetail(widget.payment.paymentId!);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final payment = widget.payment;

    return Container(
      padding: EdgeInsets.fromLTRB(
          22, 12, 22, 24 + MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F8FC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 핸들
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD8D3E7),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 헤더
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payment.rawTime.isNotEmpty
                          ? formatDateTime(payment.rawTime)
                          : '날짜 없음',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // API 상세 목록
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('상세 조회 실패: $_error',
                  style:
                      const TextStyle(color: AppColors.danger, fontSize: 13)),
            )
          else if (_detail != null && _detail!.apiUsages.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 10,
                      offset: Offset(0, 3)),
                ],
              ),
              child: Column(
                children: [
                  for (int i = 0; i < _detail!.apiUsages.length; i++) ...[
                    _ApiUsageRow(usage: _detail!.apiUsages[i]),
                    if (i < _detail!.apiUsages.length - 1)
                      const Divider(height: 20, indent: 50),
                  ],
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 총 결제 금액
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 10,
                    offset: Offset(0, 3)),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded,
                    color: AppColors.textSecondary, size: 18),
                const SizedBox(width: 8),
                const Text(
                  '총 결제 금액',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '-USDC ${formatUsdc(payment.paidAmount)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiUsageRow extends StatelessWidget {
  final ApiUsageModel usage;
  const _ApiUsageRow({required this.usage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0FF),
              borderRadius: BorderRadius.circular(11),
            ),
            child:
                const Icon(Icons.api_rounded, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              usage.apiName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            'USDC ${formatUsdc(usage.cost)}',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
