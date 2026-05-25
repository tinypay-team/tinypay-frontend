class ApiClient {
  static const String baseUrl = 'http://localhost:8080';

  Future<Map<String, dynamic>> get(String path) async {
    // TODO: 백엔드 GET 요청 연결 예정
    throw UnimplementedError('GET API 연결 예정: $path');
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    // TODO: 백엔드 POST 요청 연결 예정
    throw UnimplementedError('POST API 연결 예정: $path');
  }
}