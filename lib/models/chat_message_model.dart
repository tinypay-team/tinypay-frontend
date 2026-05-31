class ChatMessageModel {
  final int messageId;
  final String senderRole;
  final String messageType;
  final String content;
  final int? requestId;
  final String? requestStatus;
  final List<Map<String, dynamic>>? apiItems;
  final double? totalEstimatedCost;
  final String createdAt;

  const ChatMessageModel({
    required this.messageId,
    required this.senderRole,
    required this.messageType,
    required this.content,
    this.requestId,
    this.requestStatus,
    this.apiItems,
    this.totalEstimatedCost,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      messageId: json['messageId'],
      senderRole: json['senderRole'],
      messageType: json['messageType'],
      content: json['content'] ?? '',
      requestId: json['requestId'],
      requestStatus: json['requestStatus'],
      apiItems: json['apiItems'] == null
          ? null
          : List<Map<String, dynamic>>.from(json['apiItems']),
      totalEstimatedCost: json['totalEstimatedCost'] == null
          ? null
          : (json['totalEstimatedCost'] as num).toDouble(),
      createdAt: json['createdAt'],
    );
  }
}