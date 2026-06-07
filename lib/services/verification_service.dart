import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VerificationService {
  static const String baseUrl = 'http://54.116.124.181:8080';

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.isEmpty) return {};
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> sendVerificationCode({
    required String phoneNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final body = {
      'phoneNumber': phoneNumber,
    };

    print('SEND VERIFICATION CODE START');
    print('SEND VERIFICATION CODE BODY: $body');

    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/verification-code'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    print('SEND VERIFICATION CODE STATUS: ${response.statusCode}');
    print('SEND VERIFICATION CODE RESPONSE: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    throw Exception(
      responseBody['message'] ?? '인증번호 발급에 실패했습니다.',
    );
  }

  Future<void> verifyCode({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final body = {
      'phoneNumber': phoneNumber,
      'verificationCode': verificationCode,
    };

    print('VERIFY CODE START');
    print('VERIFY CODE BODY: $body');

    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/verification-code/verify'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    print('VERIFY CODE STATUS: ${response.statusCode}');
    print('VERIFY CODE RESPONSE: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    throw Exception(
      responseBody['message'] ?? '인증번호 확인에 실패했습니다.',
    );
  }
}