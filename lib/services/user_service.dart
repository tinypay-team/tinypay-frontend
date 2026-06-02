import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class UserService {
  static const String baseUrl = 'http://3.34.134.67:8080';

  Future<UserModel> getMe() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    print('GET ME START');

    final response = await http.get(
      Uri.parse('$baseUrl/api/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    final responseBody = _decodeResponse(response);

    print('GET ME STATUS: ${response.statusCode}');
    print('GET ME BODY: ${response.body}');

    if (response.statusCode == 200) {
      final user = responseBody['data']['user'];

      return UserModel(
        name: user['nickname'] ?? '',
        email: user['email'] ?? '',
        avatar: '김',
      );
    }

    throw Exception(
      responseBody['message'] ?? '내 정보 조회에 실패했습니다.',
    );
  }

  Future<bool> updateProfile({
    String? nickname,
    String? profileImage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/api/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        if (nickname != null) 'nickname': nickname,
        if (profileImage != null) 'profileImage': profileImage,
      }),
    );

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200) {
      return true;
    }

    throw Exception(
      responseBody['message'] ?? '내 정보 수정에 실패했습니다.',
    );
  }

  Future<bool> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();

    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/api/users/me'),
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

    throw Exception(
      responseBody['message'] ?? '회원 탈퇴에 실패했습니다.',
    );
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}