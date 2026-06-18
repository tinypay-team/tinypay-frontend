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
      final wallet = WalletModel.fromJson(responseBody['data']);
      // walletId prefs에 저장 (updateAutoPayment 등에서 필요)
      if (wallet.walletId != null) {
        await prefs.setInt('walletId', wallet.walletId!);
      }
      return wallet;
    }

    throw Exception(
      responseBody['message'] ?? '내 지갑 정보 조회에 실패했습니다.',
    );
  }

  Future<int> createWallet({
    required String walletPassword,
  }) async {
    print('CREATE WALLET START');

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/wallets'),
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

    if (response.statusCode == 201 || response.statusCode == 200) {
      final walletId = responseBody['data']['walletId'];

      await prefs.setInt('walletId', walletId);

      print('SAVED WALLET ID: $walletId');

      return walletId;
    }

    throw Exception(
      responseBody['message'] ?? '지갑 생성에 실패했습니다.',
    );
  }

  Future<double> topUp({
    required double amount,
    required String walletPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final accessToken = prefs.getString('accessToken');
    final walletId = prefs.getInt('walletId');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    if (walletId == null) {
      throw Exception('walletId가 없습니다.');
    }

    final body = {
      'amount': amount,
      'walletPassword': walletPassword,
    };

    print('TOP UP START');
    print('WALLET ID: $walletId');
    print('TOP UP URL: $baseUrl/api/wallets/$walletId/top-up');
    print('TOP UP REQUEST BODY: $body');

    final response = await http.post(
      Uri.parse('$baseUrl/api/wallets/$walletId/top-up'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    print('TOP UP STATUS: ${response.statusCode}');
    print('TOP UP BODY: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return (responseBody['data']['balance'] as num).toDouble();
    }

    throw Exception(
      responseBody['message'] ?? '충전에 실패했습니다.',
    );
  }

  Future<bool> updateAutoPayment({
    required bool enabled,
    String? walletPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final accessToken = prefs.getString('accessToken');
    final walletId = prefs.getInt('walletId');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    if (walletId == null) {
      throw Exception('walletId가 없습니다.');
    }

    final body = {
      'enabled': enabled,
      if (walletPassword != null) 'walletPassword': walletPassword,
    };

    print('UPDATE AUTO PAYMENT START');
    print('AUTO PAYMENT BODY: $body');

    final response = await http.patch(
      Uri.parse('$baseUrl/api/wallets/$walletId/auto-payment'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    print('UPDATE AUTO PAYMENT STATUS: ${response.statusCode}');
    print('UPDATE AUTO PAYMENT BODY: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return responseBody['data']['autoPaymentEnabled'] ?? enabled;
    }

    throw Exception(
      responseBody['message'] ?? '자동결제 설정 변경 실패',
    );
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}