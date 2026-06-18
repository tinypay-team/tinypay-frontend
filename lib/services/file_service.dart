import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FileService {
  static const String baseUrl = 'http://54.116.124.181:8080';

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.isEmpty) return {};
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getUploadUrl({
    required String fileName,
    required String fileType,
    required int fileSize,
    int? sessionId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final body = <String, dynamic>{
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
      if (sessionId != null) 'sessionId': sessionId,
    };

    print('GET UPLOAD URL START');
    print('GET UPLOAD URL BODY: $body');

    final response = await http.post(
      Uri.parse('$baseUrl/api/files/presigned-url/upload'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    print('GET UPLOAD URL STATUS: ${response.statusCode}');
    print('GET UPLOAD URL RESPONSE: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return responseBody['data'] as Map<String, dynamic>;
    }

    throw Exception(responseBody['message'] ?? '업로드 URL 발급 실패');
  }

  Future<void> uploadFileToS3({
    required String uploadUrl,
    required File file,
    required String fileType,
  }) async {
    print('S3 PUT START');
    print('S3 FILE PATH: ${file.path}');
    print('S3 FILE TYPE: $fileType');

    final response = await http.put(
      Uri.parse(uploadUrl),
      headers: {
        'Content-Type': fileType,
      },
      body: await file.readAsBytes(),
    );

    print('S3 PUT STATUS: ${response.statusCode}');
    print('S3 PUT BODY: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('S3 업로드 실패 (${response.statusCode})');
    }
  }

  Future<int> confirmUpload({
    required String fileName,
    required String fileType,
    required int fileSize,
    required int sessionId,
    required String storageKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final body = {
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
      'sessionId': sessionId,
      'storageKey': storageKey,
    };

    print('CONFIRM UPLOAD START');
    print('CONFIRM UPLOAD BODY: $body');

    final response = await http.post(
      Uri.parse('$baseUrl/api/files/confirm-upload'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    print('CONFIRM UPLOAD STATUS: ${response.statusCode}');
    print('CONFIRM UPLOAD RESPONSE: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return responseBody['data']['fileId'];
    }

    throw Exception(responseBody['message'] ?? '파일 정보 저장 실패');
  }

  Future<Map<String, dynamic>> getDownloadUrl({
    required int fileId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    print('GET DOWNLOAD URL START');
    print('FILE ID: $fileId');

    final response = await http.get(
      Uri.parse('$baseUrl/api/files/$fileId/presigned-url/download'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('GET DOWNLOAD URL STATUS: ${response.statusCode}');
    print('GET DOWNLOAD URL RESPONSE: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return responseBody['data'] as Map<String, dynamic>;
    }

    throw Exception(responseBody['message'] ?? '다운로드 URL 발급 실패');
  }
}