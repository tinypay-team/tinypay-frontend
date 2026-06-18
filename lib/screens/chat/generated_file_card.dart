import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/chat_message_model.dart';
import '../../services/file_service.dart';
import '../../theme/app_colors.dart';

class GeneratedFileCard extends StatefulWidget {
  final GeneratedFileModel file;
  final VoidCallback? onClosed; // PDF 뷰어 닫힌 후 콜백 (스크롤 복원용)

  const GeneratedFileCard({super.key, required this.file, this.onClosed});

  @override
  State<GeneratedFileCard> createState() => _GeneratedFileCardState();
}

class _GeneratedFileCardState extends State<GeneratedFileCard> {
  String? _presignedUrl;
  bool _isLoadingUrl = true;

  bool get _isImage => widget.file.mimeType.startsWith('image/');
  bool get _isPdf => widget.file.mimeType == 'application/pdf';

  // 확장자 제거한 표시용 파일명
  String get _displayName {
    final name = widget.file.fileName;
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }

  @override
  void initState() {
    super.initState();
    _fetchPresignedUrl();
  }

  Future<void> _fetchPresignedUrl() async {
    final fileId = widget.file.fileId;
    if (fileId == null) {
      setState(() {
        _presignedUrl = widget.file.fileUrl.isNotEmpty ? widget.file.fileUrl : null;
        _isLoadingUrl = false;
      });
      return;
    }
    try {
      final data = await FileService().getDownloadUrl(fileId: fileId);
      if (!mounted) return;
      setState(() {
        _presignedUrl = (data['downloadUrl'] ?? data['presignedUrl'] ?? data['url']) as String?;
        _isLoadingUrl = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoadingUrl = false; });
    }
  }

  Future<void> _refetchAndAction(Future<void> Function(String url) action) async {
    final fileId = widget.file.fileId;
    if (fileId != null) {
      try {
        final data = await FileService().getDownloadUrl(fileId: fileId);
        final url = (data['downloadUrl'] ?? data['presignedUrl'] ?? data['url']) as String?;
        if (url != null && url.isNotEmpty) {
          setState(() => _presignedUrl = url);
          await action(url);
          return;
        }
      } catch (_) {}
    }
    final url = _presignedUrl ?? widget.file.fileUrl;
    if (url.isNotEmpty) await action(url);
  }

  Future<void> _open() async {
    await _refetchAndAction((url) async {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    });
  }

  Future<void> _preview() async {
    await _refetchAndAction((url) async {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _PdfViewerScreen(
            url: url,
            fileName: widget.file.fileName,
          ),
        ),
      );
      // PDF 뷰어 닫힌 후 채팅 스크롤 맨 아래로
      widget.onClosed?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isImage) return _buildImageCard();
    if (_isPdf) return _buildPdfCard();
    return _buildGenericCard();
  }

  // ── 공통 카드 래퍼 ──
  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // ── 이미지 카드: 아이콘 + 파일명(확장자 제거) + 타입 + 열기 버튼 ──
  Widget _buildImageCard() {
    return _buildCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.image_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.file.mimeType,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _ActionButton(
            label: '열기',
            icon: Icons.open_in_new_rounded,
            onPressed: _isLoadingUrl ? null : _open,
          ),
        ],
      ),
    );
  }

  // ── PDF 카드: 아이콘 + 파일명 + 미리보기/열기 ──
  Widget _buildPdfCard() {
    return _buildCard(
      child: Column(
        children: [
          // 파일 정보 행
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Color(0xFFE53935),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.file.fileName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'PDF 문서',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 버튼 행
          Row(
            children: [
              Expanded(
                child: _OutlineButton(
                  label: '미리보기',
                  icon: Icons.picture_as_pdf_rounded,
                  onPressed: _isLoadingUrl ? null : _preview,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  label: '열기',
                  icon: Icons.open_in_new_rounded,
                  onPressed: _isLoadingUrl ? null : _open,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 일반 파일 카드 ──
  Widget _buildGenericCard() {
    return _buildCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.insert_drive_file_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.file.fileName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.file.mimeType,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _ActionButton(
            label: '열기',
            icon: Icons.open_in_new_rounded,
            onPressed: _isLoadingUrl ? null : _open,
          ),
        ],
      ),
    );
  }
}

// ── 채워진 버튼 ──
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const _ActionButton({required this.label, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 15),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primary.withAlpha(80),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── 테두리 버튼 ──
class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const _OutlineButton({required this.label, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 15),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary.withAlpha(120)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── 인앱 PDF 뷰어 전체화면 ──
class _PdfViewerScreen extends StatefulWidget {
  final String url;
  final String fileName;

  const _PdfViewerScreen({required this.url, required this.fileName});

  @override
  State<_PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<_PdfViewerScreen> {
  bool _hasError = false;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.fileName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Stack(
        children: [
          if (!_hasError)
            SfPdfViewer.network(
              widget.url,
              onDocumentLoaded: (_) {
                if (mounted) setState(() => _isLoading = false);
              },
              onDocumentLoadFailed: (_) {
                if (mounted) setState(() { _hasError = true; _isLoading = false; });
              },
            ),
          if (_hasError)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.picture_as_pdf_rounded,
                      color: AppColors.primary.withAlpha(80), size: 56),
                  const SizedBox(height: 16),
                  const Text(
                    'PDF를 불러올 수 없어요',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() { _hasError = false; _isLoading = true; });
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          if (_isLoading && !_hasError)
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }
}
