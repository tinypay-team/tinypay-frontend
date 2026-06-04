import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/wallet_model.dart';

class WalletApiService {
  static const String baseUrl = 'http://54.116.124.181:8080';

  Future<WalletModel> getWallet() async {
    print('GET WALLET START');

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/wallets'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('GET WALLET STATUS: ${response.statusCode}');
    print('GET WALLET BODY: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200) {
      return WalletModel.fromJson(
        responseBody['data'],
      );
    }

    throw Exception(
      responseBody['message'] ?? '내 지갑 정보 조회에 실패했습니다.',
    );
  }

  Future<bool> createWallet({
    required String walletPassword,
  }) async {
    print('CREATE WALLET START');

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/wallet'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'walletPassword': walletPassword,
      }),
    );

    print('CREATE WALLET STATUS: ${response.statusCode}');
    print('CREATE WALLET BODY: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 201) {
      return true;
    }

    throw Exception(
      responseBody['message'] ?? '지갑 생성에 실패했습니다.',
    );
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}