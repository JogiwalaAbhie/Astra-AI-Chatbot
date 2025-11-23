// lib/models/chat_message.dart
class ChatMessage {
  final String role; // 'user' or 'model'
  String text;       // made mutable so UI can append characters during reveal
  final DateTime createdAt;

  ChatMessage({
    required this.role,
    required this.text,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'role': role,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        role: json['role'] as String,
        text: json['text'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  ChatMessage copyWith({String? role, String? text, DateTime? createdAt}) {
    return ChatMessage(
      role: role ?? this.role,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
