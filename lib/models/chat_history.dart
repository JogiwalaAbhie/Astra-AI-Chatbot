import 'package:astra_abhie_ai/models/chat_message.dart';

class ChatHistory {
  String id;
  String title;
  DateTime time;
  List<ChatMessage> messages;

  ChatHistory({
    required this.id,
    required this.title,
    required this.time,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "time": time.toIso8601String(),
    "messages": messages.map((m) => m.toJson()).toList(),
  };

  factory ChatHistory.fromJson(Map<String, dynamic> json) {
    return ChatHistory(
      id: json["id"],
      title: json["title"],
      time: DateTime.parse(json["time"]),
      messages: (json["messages"] as List)
          .map((m) => ChatMessage.fromJson(m))
          .toList(),
    );
  }
}
