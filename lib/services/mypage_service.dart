import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/dummy_data.dart';
import '../models/budget_model.dart';
import '../models/payment_model.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';
import 'wallet_state.dart';
import '../models/payment_detail_model.dart';

class MyPageService {
  static const String baseUrl = 'http://54.116.124.181:8080';

  Future<Map<String, dynamic>> getMyPage() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/mypage'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('GET MYPAGE STATUS: ${response.statusCode}');
    print('GET MYPAGE BODY: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200) {
      return responseBody['data'] as Map<String, dynamic>;
    }

    throw Exception(
      responseBody['message'] ?? '마이페이지 조회에 실패했습니다.',
    );
  }

  Future<WalletModel> getWallet() async {
    final prefs = await SharedPreferences.getInstance();
    final walletId = prefs.getInt('walletId');

    if (walletId != null) {
      return WalletState.wallet.copyWith(
        walletId: walletId,
        isConnected: true,
        walletStatus: 'ACTIVE',
      );
    }

    return WalletState.wallet;
  }

  Future<UserModel> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    print('GET USER START');

    final response = await http.get(
      Uri.parse('$baseUrl/api/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('GET USER STATUS: ${response.statusCode}');
    print('GET USER BODY: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200) {
      return UserModel.fromJson(
        responseBody['data']['user'],
      );
    }

    throw Exception(
      responseBody['message'] ?? '내 정보 조회 실패',
    );
  }
  
  Future<BudgetModel> getBudget() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return dummyBudget;
  }

  Future<List<PaymentModel>> getPaymentHistory() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return dummyPaymentHistory;
  }

  Future<PaymentDetailModel> getPaymentDetail(
    int paymentId,
  ) async {

    print('GET PAYMENT DETAIL START');
    print('PAYMENT ID: $paymentId');

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/payments/$paymentId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    final responseBody = _decodeResponse(response);

    print('GET PAYMENT DETAIL STATUS: ${response.statusCode}');
    print('GET PAYMENT DETAIL BODY: ${response.body}');

    if (response.statusCode == 200) {
      return PaymentDetailModel.fromJson(
        responseBody['data'],
      );
    }

    throw Exception(
      responseBody['message'] ?? '결제 상세 조회에 실패했습니다.',
    );
  }

  Future<double> updatePerPaymentLimit(double perPaymentLimit) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/api/budget-policy/per-payment-limit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'perPaymentLimit': perPaymentLimit,
      }),
    );

    print('UPDATE LIMIT STATUS: ${response.statusCode}');
    print('UPDATE LIMIT BODY: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200) {
      return (responseBody['data']['perPaymentLimit'] as num).toDouble();
    }

    throw Exception(
      responseBody['message'] ?? '1회 결제 한도 설정에 실패했습니다.',
    );
  }

  Future<double> updateMonthlyBudget(double monthlyBudget) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/api/budget-policy/monthly-budget'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'monthlyBudget': monthlyBudget,
      }),
    );

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200) {
      return (responseBody['data']['monthlyBudget'] as num).toDouble();
    }

    throw Exception(
      responseBody['message'] ?? '이번 달 예산 설정에 실패했습니다.',
    );
  }

  Future<List<PaymentModel>> getPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/payments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('GET PAYMENTS STATUS: ${response.statusCode}');
    print('GET PAYMENTS BODY: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200) {
      final payments = responseBody['data']['payments'] as List;

      return payments
          .map((e) => PaymentModel.fromJson(e))
          .toList();
    }

    throw Exception(
      responseBody['message'] ?? '결제 내역 조회에 실패했습니다.',
    );
  }

  Future<void> updateUser({
    required String nickname,
  }) async {
    print('UPDATE USER START');

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final response = await http.patch(
      Uri.parse('$baseUrl/api/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'nickname': nickname,
      }),
    );

    print('UPDATE USER STATUS: ${response.statusCode}');
    print('UPDATE USER BODY: ${response.body}');
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}