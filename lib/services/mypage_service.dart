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
      final user = UserModel.fromJson(responseBody['data']['user']);
      // 서버에 프로필 이미지 URL이 있으면 우선 사용 (구글 프로필 등)
      if (user.avatar.startsWith('http')) {
        return user;
      }
      // 없으면 로컬 저장된 이모지 사용
      final localEmoji = prefs.getString('userAvatarEmoji');
      if (localEmoji != null && localEmoji.isNotEmpty) {
        return user.copyWith(avatar: localEmoji);
      }
      return user;
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

    print('UPDATE BUDGET STATUS: ${response.statusCode}');
    print('UPDATE BUDGET BODY: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200) {
      return (responseBody['data']['monthlyBudget'] as num).toDouble();
    }

    throw Exception(
      responseBody['message'] ?? '이번 달 예산 설정에 실패했습니다.',
    );
  }

  /// 결제 내역 커서 기반 페이지네이션 조회
  /// 반환: (payments, nextCursor) - nextCursor가 null이면 마지막 페이지
  Future<({List<PaymentModel> payments, int? nextCursor})> getPayments({
    int? cursor,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('accessToken이 없습니다.');
    }

    final uri = cursor != null
        ? Uri.parse('$baseUrl/api/payments?cursor=$cursor')
        : Uri.parse('$baseUrl/api/payments');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('GET PAYMENTS STATUS: ${response.statusCode}');
    print('GET PAYMENTS BODY: ${response.body}');

    final responseBody = _decodeResponse(response);

    if (response.statusCode == 200) {
      final data = responseBody['data'] as Map<String, dynamic>;
      final payments = (data['payments'] as List? ?? [])
          .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final nextCursor = data['nextCursor'] as int?;
      return (payments: payments, nextCursor: nextCursor);
    }

    throw Exception(
      responseBody['message'] ?? '결제 내역 조회에 실패했습니다.',
    );
  }

  Future<void> updateUser({
    String? nickname,
    String? profileImage,
  }) async {
    print('UPDATE USER START');

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final body = <String, dynamic>{
      if (nickname != null) 'nickname': nickname,
      if (profileImage != null) 'profileImage': profileImage,
    };

    final response = await http.patch(
      Uri.parse('$baseUrl/api/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    print('UPDATE USER STATUS: ${response.statusCode}');
    print('UPDATE USER BODY: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
      final body = _decodeResponse(response);
      throw Exception(body['message'] ?? '프로필 저장 실패 (${response.statusCode})');
    }
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}