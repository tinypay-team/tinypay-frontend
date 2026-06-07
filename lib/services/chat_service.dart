import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  static const String baseUrl = 'http://54.116.124.181:8080';

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.isEmpty) return {};
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> sendMessage({
    required int sessionId,
    String? content,
    int? fileId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final body = {
      if (content != null && content.trim().isNotEmpty)
        'content': content.trim(),
      if (fileId != null) 'fileId': fileId,
    };

    print('SEND MESSAGE START');
    print('SEND MESSAGE SESSION ID: $sessionId');
    print('SEND MESSAGE BODY: $body');

    final response = await http.post(
      Uri.parse('$baseUrl/api/chat/sessions/$sessionId/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    print('SEND MESSAGE STATUS: ${response.statusCode}');
    print('SEND MESSAGE RESPONSE: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return responseBody['data'] as Map<String, dynamic>;
    }

    throw Exception(responseBody['message'] ?? '메시지 전송에 실패했습니다.');
  }

  Future<Map<String, dynamic>> getRequestStatus({
    required int requestId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    print('GET REQUEST STATUS START');
    print('REQUEST ID: $requestId');

    final response = await http.get(
      Uri.parse('$baseUrl/api/requests/$requestId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('GET REQUEST STATUS: ${response.statusCode}');
    print('GET REQUEST RESPONSE: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200) {
      return responseBody['data'] as Map<String, dynamic>;
    }

    throw Exception(responseBody['message'] ?? '요청 상태 조회에 실패했습니다.');
  }

  Future<List<dynamic>> getMessages({
    required int sessionId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    print('GET CHAT MESSAGES START');
    print('SESSION ID: $sessionId');

    final response = await http.get(
      Uri.parse('$baseUrl/api/chat/sessions/$sessionId/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('GET CHAT MESSAGES STATUS: ${response.statusCode}');
    print('GET CHAT MESSAGES RESPONSE: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200) {
      return responseBody['data'] as List<dynamic>;
    }

    throw Exception(responseBody['message'] ?? '채팅 메시지 조회에 실패했습니다.');
  }

  Future<Map<String, dynamic>> checkPayment({
    required double estimatedCost,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    print('CHECK PAYMENT START');
    print('ESTIMATED COST: $estimatedCost');

    final response = await http.get(
      Uri.parse('$baseUrl/api/payments/check?estimatedCost=$estimatedCost'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('CHECK PAYMENT STATUS: ${response.statusCode}');
    print('CHECK PAYMENT RESPONSE: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200) {
      return responseBody['data'] as Map<String, dynamic>;
    }

    throw Exception(responseBody['message'] ?? '자동결제 여부 조회에 실패했습니다.');
  }

  Future<Map<String, dynamic>> approveRequest({
    required int requestId,
    required double estimatedCost,
    String? walletPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final body = {
      'estimatedCost': estimatedCost,
      if (walletPassword != null && walletPassword.isNotEmpty)
        'walletPassword': walletPassword,
    };

    print('APPROVE REQUEST START');
    print('REQUEST ID: $requestId');
    print('APPROVE BODY: $body');

    final response = await http.post(
      Uri.parse('$baseUrl/api/requests/$requestId/approval'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    print('APPROVE STATUS: ${response.statusCode}');
    print('APPROVE RESPONSE: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return responseBody['data'] as Map<String, dynamic>;
    }

    throw Exception(responseBody['message'] ?? '결제 승인에 실패했습니다.');
  }

  Future<void> cancelRequest({
    required int requestId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    print('CANCEL REQUEST START');
    print('REQUEST ID: $requestId');

    final response = await http.patch(
      Uri.parse('$baseUrl/api/requests/$requestId/cancel'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('CANCEL STATUS: ${response.statusCode}');
    print('CANCEL RESPONSE: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(responseBody['message'] ?? '결제 요청 취소에 실패했습니다.');
  }

  Future<List<dynamic>> getChatSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    print('GET CHAT SESSIONS START');

    final response = await http.get(
      Uri.parse('$baseUrl/api/chat/sessions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('GET CHAT SESSIONS STATUS: ${response.statusCode}');
    print('GET CHAT SESSIONS RESPONSE: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200) {
      return responseBody['data'] as List<dynamic>;
    }

    throw Exception(responseBody['message'] ?? '채팅 세션 조회에 실패했습니다.');
  }

  Future<int?> createChatSession() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    print('CREATE CHAT SESSION START');

    final response = await http.post(
      Uri.parse('$baseUrl/api/chat/sessions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('CREATE CHAT SESSION STATUS: ${response.statusCode}');
    print('CREATE CHAT SESSION RESPONSE: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return responseBody['data']['sessionId'] as int?;
    }

    throw Exception(responseBody['message'] ?? '채팅 세션 생성에 실패했습니다.');
  }
}