import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../services/file_service.dart';
import '../../services/mypage_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/mypage/profile_avatar.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final MyPageService _service = MyPageService();
  final FileService _fileService = FileService();

  late String tempAvatar;
  late TextEditingController nameController;
  File? _pickedImageFile;
  bool _isSaving = false;

  final List<String> avatarList = [
    '🐼', '🦊', '🐱', '🐶', '🐰', '🐻',
    '🐯', '🦁', '🐸', '🐷', '🐨', '🐵',
  ];

  @override
  void initState() {
    super.initState();
    tempAvatar = widget.user.avatar;
    nameController = TextEditingController(text: widget.user.name);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;

    setState(() {
      _pickedImageFile = File(path);
      tempAvatar = '';
    });
  }

  Future<void> _saveProfile() async {
    final newName = nameController.text.trim();
    if (newName.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임을 2자 이상 입력해주세요.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? newProfileImageUrl;

      if (_pickedImageFile != null) {
        final file = _pickedImageFile!;
        final fileSize = await file.length();
        final fileName = file.path.split('/').last;
        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';

        print('▶ S3 업로드 시작: $fileName / $mimeType / $fileSize bytes');

        final uploadData = await _fileService.getUploadUrl(
          fileName: fileName,
          fileType: mimeType,
          fileSize: fileSize,
        );
        print('▶ Presigned URL 발급 완료: ${uploadData['storageKey']}');

        final uploadUrl = uploadData['uploadUrl'] as String;
        final storageKey = uploadData['storageKey'] as String;

        await _fileService.uploadFileToS3(
          uploadUrl: uploadUrl,
          file: file,
          fileType: mimeType,
        );
        print('▶ S3 업로드 완료');

        const s3Base = 'https://tinypay.s3.ap-northeast-2.amazonaws.com';
        newProfileImageUrl = '$s3Base/$storageKey';
        print('▶ 최종 이미지 URL: $newProfileImageUrl');
      } else {
        print('▶ 이미지 없음, 이모지/기존 아바타 사용');
      }

      // 이모지는 로컬 저장 / S3 URL만 백엔드에 전송
      final avatarForDisplay = newProfileImageUrl ??
          (tempAvatar.isNotEmpty ? tempAvatar : widget.user.avatar);

      final prefs = await SharedPreferences.getInstance();
      if (newProfileImageUrl != null) {
        // 새 이미지 업로드 → 로컬 이모지 초기화
        await prefs.remove('userAvatarEmoji');
      } else if (!avatarForDisplay.startsWith('http')) {
        // 이모지 선택 → 로컬 저장
        await prefs.setString('userAvatarEmoji', avatarForDisplay);
      }

      print('▶ updateUser 호출: nickname=$newName, profileImage=${newProfileImageUrl ?? "(변경없음)"}');
      await _service.updateUser(
        nickname: newName,
        profileImage: newProfileImageUrl, // 이모지일 땐 null → 백엔드 미전송
      );
      print('▶ updateUser 완료');

      final updatedUser = widget.user.copyWith(
        name: newName,
        avatar: avatarForDisplay,
      );
      print('▶ pop 호출: name=${updatedUser.name}, avatar=${updatedUser.avatar}');

      if (mounted) {
        Navigator.pop(context, updatedUser);
      }
    } catch (e) {
      print('▶ 저장 실패: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('저장 실패'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _buildAvatarPreview() {
    if (_pickedImageFile != null) {
      return Container(
        width: 96,
        height: 96,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFBBBBBB),
        ),
        child: ClipOval(
          child: Image.file(
            _pickedImageFile!,
            width: 96,
            height: 96,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return ProfileAvatar(selectedAvatar: tempAvatar.isEmpty ? '🐼' : tempAvatar, size: 96);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '프로필 수정',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            Center(
              child: GestureDetector(
                onTap: _isSaving ? null : _pickImage,
                child: Stack(
                  children: [
                    _buildAvatarPreview(),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child: Text(
                '탭하여 사진 변경',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              '프로필 이미지',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: avatarList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final avatar = avatarList[index];
                  final isSelected = _pickedImageFile == null && avatar == tempAvatar;
                  return GestureDetector(
                    onTap: () => setState(() {
                      tempAvatar = avatar;
                      _pickedImageFile = null;
                    }),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(avatar, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              '닉네임',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: nameController,
              maxLength: 20,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              '2-20자 이내로 입력해주세요',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      fixedSize: const Size.fromHeight(52),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size.fromHeight(52),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            '저장',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
