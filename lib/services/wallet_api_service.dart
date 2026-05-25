import '../models/wallet_model.dart';
import 'api_client.dart';

class WalletApiService {
  final ApiClient _apiClient = ApiClient();

  Future<WalletModel> getWallet() async {
    // TODO: 백엔드 지갑 조회 API 연결 예정
    // final response = await _apiClient.get('/wallet');

    return const WalletModel(
      balance: 0,
      walletAddress: '',
      isConnected: false,
    );
  }

  Future<WalletModel> createWallet() async {
    // TODO: 백엔드 지갑 생성 API 연결 예정
    // final response = await _apiClient.post('/wallet/create', {});

    return const WalletModel(
      balance: 0,
      walletAddress: '0x12A4...9F3D',
      isConnected: true,
    );
  }
}