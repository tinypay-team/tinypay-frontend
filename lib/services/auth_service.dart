import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://백엔드주소';

  Future<bool> loginWithGoogle(String idToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/google'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_token': idToken,
      }),
    );

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200) {
      final data = responseBody['data'];

      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('accessToken', accessToken);
      await prefs.setString('refreshToken', refreshToken);
      await prefs.setBool('isLoggedIn', true);

      return true;
    }

    throw Exception(responseBody['message'] ?? '로그인에 실패했습니다.');
  }

  Future<bool> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('refreshToken이 없습니다.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/refresh'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $refreshToken',
      },
    );

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200) {
      final data = responseBody['data'];

      final newAccessToken = data['accessToken'];
      final newRefreshToken = data['refreshToken'];

      await prefs.setString('accessToken', newAccessToken);
      await prefs.setString('refreshToken', newRefreshToken);
      await prefs.setBool('isLoggedIn', true);

      return true;
    }

    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.setBool('isLoggedIn', false);

    throw Exception(responseBody['message'] ?? '토큰 재발급에 실패했습니다.');
  }

  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/api/auth'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200) {
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      await prefs.setBool('isLoggedIn', false);

      return true;
    }

    throw Exception(responseBody['message'] ?? '로그아웃에 실패했습니다.');
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}