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
  static const String baseUrl = 'http://3.34.134.67:8080';

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

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200) {
      return responseBody['data'] as Map<String, dynamic>;
    }

    throw Exception(
      responseBody['message'] ?? '마이페이지 조회에 실패했습니다.',
    );
  }

  Future<WalletModel> getWallet() async {
    await Future.delayed(const Duration(milliseconds: 300));
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
        responseBody['data'],
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

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}