class ApiItemModel {
  final String apiName;
  final String description;
  final double estimatedCost;

  const ApiItemModel({
    required this.apiName,
    required this.description,
    required this.estimatedCost,
  });

  factory ApiItemModel.fromJson(Map<String, dynamic> json) {
    return ApiItemModel(
      apiName: json['apiName'] ?? '',
      description: json['description'] ?? '',
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0,
    );
  }
}

class GeneratedFileModel {
  final int? fileId;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final String mimeType;

  const GeneratedFileModel({
    this.fileId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.mimeType,
  });

  factory GeneratedFileModel.fromJson(Map<String, dynamic> json) {
    return GeneratedFileModel(
      fileId: json['fileId'] as int?,
      fileName: json['fileName'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      fileType: json['fileType'] ?? '',
      mimeType: json['mimeType'] ?? '',
    );
  }
}

class ChatMessageModel {
  final int messageId;
  final String senderRole;
  final String messageType;
  final String content;
  final int? requestId;
  final String? requestStatus;
  final List<ApiItemModel> apiItems;
  final double? totalEstimatedCost;
  final List<GeneratedFileModel> generatedFiles;
  final int? fileId;
  final String? fileName;
  final String? fileType;
  final String createdAt;

  const ChatMessageModel({
    required this.messageId,
    required this.senderRole,
    required this.messageType,
    required this.content,
    required this.requestId,
    required this.requestStatus,
    required this.apiItems,
    required this.totalEstimatedCost,
    required this.generatedFiles,
    required this.fileId,
    required this.fileName,
    required this.fileType,
    required this.createdAt,
  });

  bool get isUser => senderRole == 'USER';
  bool get isAssistant => senderRole == 'ASSISTANT';

  bool get isWaitingApproval =>
      isAssistant && requestStatus == 'WAITING_APPROVAL';

  bool get isCompleted =>
      isAssistant && requestStatus == 'COMPLETED';

  bool get isFailed =>
      isAssistant && requestStatus == 'FAILED';

  bool get isCancelled =>
      isAssistant && requestStatus == 'CANCELLED';

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      messageId: json['messageId'] ?? 0,
      senderRole: json['senderRole'] ?? '',
      messageType: json['messageType'] ?? '',
      content: json['content'] ?? '',
      requestId: json['requestId'],
      requestStatus: json['requestStatus'],
      apiItems: (json['apiItems'] as List<dynamic>? ?? [])
          .map((e) => ApiItemModel.fromJson(e))
          .toList(),
      totalEstimatedCost:
          (json['totalEstimatedCost'] as num?)?.toDouble(),
      generatedFiles: (json['generatedFiles'] as List<dynamic>? ?? [])
          .map((e) => GeneratedFileModel.fromJson(e))
          .toList(),
      fileId: json['fileId'],
      fileName: json['fileName'],
      fileType: json['fileType'],
      createdAt: json['createdAt'] ?? '',
    );
  }
}