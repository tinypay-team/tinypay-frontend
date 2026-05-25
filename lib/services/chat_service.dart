import '../models/api_cost_model.dart';

class ChatService {
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
}