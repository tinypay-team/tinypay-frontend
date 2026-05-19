import 'chat_item_model.dart';

class ChatSessionModel {
  String title;
  String subtitle;
  String date;

  List<ChatItemModel> messages;

  bool showCostCard;
  bool showConfirmCard;
  bool showResultCard;

  ChatSessionModel({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.messages,
    required this.showCostCard,
    required this.showConfirmCard,
    required this.showResultCard,
  });
}