class ApiClient {
  static const String baseUrl = 'http://3.34.134.67:8080';

  Future<Map<String, dynamic>> get(String path) async {
    throw UnimplementedError('GET API 연결 예정: $path');
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    throw UnimplementedError('POST API 연결 예정: $path');
  }
}