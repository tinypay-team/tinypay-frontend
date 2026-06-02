import '../models/wallet_model.dart';
import 'api_client.dart';

class WalletApiService {
  final ApiClient _apiClient = ApiClient();

  Future<WalletModel> getWallet() async {
    // TODO: 백엔드 배포 후 실제 연결
    // final response = await _apiClient.get('/api/wallets');
    // return WalletModel.fromJson(response['data']);

    return const WalletModel(
      balance: 0,
      walletAddress: '',
      isConnected: false,
      walletStatus: '',
      autoPaymentEnabled: false,
    );
  }

  Future<WalletModel> createWallet() async {
    // TODO: 백엔드 지갑 생성 API 연결 예정
    // final response = await _apiClient.post('/api/wallets', {});
    // return WalletModel.fromJson(response['data']);

    return const WalletModel(
      balance: 0,
      walletAddress: '0x12A4...9F3D',
      isConnected: true,
      walletStatus: 'ACTIVE',
      autoPaymentEnabled: false,
    );
  }
}