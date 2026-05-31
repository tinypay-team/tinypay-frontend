import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/api_cost_model.dart';
import '../models/request_status_model.dart';
import '../models/chat_message_model.dart';

class ChatService {
  static const String baseUrl = 'http://백엔드주소';

  Future<List<ApiCostModel>> getEstimatedApiCosts(String message) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return const [
      ApiCostModel(name: 'Instagram Reels API', price: '0.006 USDC'),
      ApiCostModel(name: 'Video Analysis API', price: '0.009 USDC'),
      ApiCostModel(name: 'AI Voice Generator API', price: '0.005 USDC'),
    ];
  }

  Future<String> getTotalCostUsdc(String message) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return '0.02 USDC';
  }

  Future<int> getTotalCostWon(String message) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return 450;
  }

  Future<List<Map<String, dynamic>>> getChatSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/chat/sessions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200) {
      final data = responseBody['data'];

      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }

      return [];
    }

    throw Exception(
      responseBody['message'] ?? '채팅 세션 목록 조회에 실패했습니다.',
    );
  }

  Future<int> createChatSession() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/chat/sessions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({}),
    );

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 201) {
      return responseBody['data']['sessionId'];
    }

    throw Exception(
      responseBody['message'] ?? '새 채팅 세션 생성에 실패했습니다.',
    );
  }

  Future<Map<String, dynamic>> sendMessage({
    required int sessionId,
    required String content,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/chat/sessions/$sessionId/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'content': content,
      }),
    );

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 201) {
      return responseBody['data'] as Map<String, dynamic>;
    }

    throw Exception(
      responseBody['message'] ?? '메시지 전송에 실패했습니다.',
    );
  }

  Future<Map<String, dynamic>> approveRequest({
    required int requestId,
    required double estimatedCost,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/requests/$requestId/approve'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'estimatedCost': estimatedCost,
      }),
    );

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 201) {
      return responseBody['data'] as Map<String, dynamic>;
    }

    throw Exception(
      responseBody['message'] ?? '요청 승인 및 결제에 실패했습니다.',
    );
  }

  Future<RequestStatusModel> getRequestStatus({
    required int requestId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/requests/$requestId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200) {
      return RequestStatusModel.fromJson(
        responseBody['data'],
      );
    }

    throw Exception(
      responseBody['message'] ?? 'AI 요청 상태 조회에 실패했습니다.',
    );
  }

  Future<List<ChatMessageModel>> getChatMessages({
    required int sessionId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/chat/sessions/$sessionId/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200) {
      final data = responseBody['data'];

      if (data is List) {
        return data
            .map((e) => ChatMessageModel.fromJson(e))
            .toList();
      }

      return [];
    }

    throw Exception(
      responseBody['message'] ?? '채팅 메시지 목록 조회에 실패했습니다.',
    );
  }

  Future<bool> cancelRequest({
    required int requestId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/api/requests/$requestId/cancel'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200) {
      return true;
    }

    throw Exception(
      responseBody['message'] ?? '결제 요청 취소에 실패했습니다.',
    );
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}