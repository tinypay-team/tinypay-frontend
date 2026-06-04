import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FileService {
  static const String baseUrl = 'http://54.116.124.181:8080';

  Future<Map<String, dynamic>> getUploadUrl({
    required String fileName,
    required String fileType,
    required int fileSize,
    int? sessionId,
  }) async {
    print('GET UPLOAD URL START');

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final body = {
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
      if (sessionId != null) 'sessionId': sessionId,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/files/presigned-url/upload'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    print('GET UPLOAD URL STATUS: ${response.statusCode}');
    print('GET UPLOAD URL BODY: ${response.body}');

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return responseBody['data'] as Map<String, dynamic>;
    }

    throw Exception(responseBody['message'] ?? '업로드 URL 발급 실패');
  }

  Future<Map<String, dynamic>> confirmUpload({
    required String fileName,
    required String fileType,
    required int fileSize,
    required int sessionId,
    required String storageKey,
  }) async {
    print('CONFIRM UPLOAD START');

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/files/confirm-upload'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'fileName': fileName,
        'fileType': fileType,
        'fileSize': fileSize,
        'sessionId': sessionId,
        'storageKey': storageKey,
      }),
    );

    print('CONFIRM UPLOAD STATUS: ${response.statusCode}');
    print('CONFIRM UPLOAD BODY: ${response.body}');

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return responseBody['data'] as Map<String, dynamic>;
    }

    throw Exception(responseBody['message'] ?? '업로드 완료 저장 실패');
  }

  Future<Map<String, dynamic>> getDownloadUrl({
    required int fileId,
  }) async {
    print('GET DOWNLOAD URL START');

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/files/$fileId/presigned-url/download'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('GET DOWNLOAD URL STATUS: ${response.statusCode}');
    print('GET DOWNLOAD URL BODY: ${response.body}');

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return responseBody['data'] as Map<String, dynamic>;
    }

    throw Exception(
      responseBody['message'] ?? '다운로드 URL 발급 실패',
    );
  }
}