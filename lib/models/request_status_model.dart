class RequestStatusModel {
  final int requestId;
  final int sessionId;
  final String requestStatus;

  const RequestStatusModel({
    required this.requestId,
    required this.sessionId,
    required this.requestStatus,
  });

  factory RequestStatusModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RequestStatusModel(
      requestId: json['requestId'],
      sessionId: json['sessionId'],
      requestStatus: json['requestStatus'],
    );
  }
}