import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/env.dart';
import '../models/chat_message.dart';

class GeminiApi {
  final String model =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

  Future<String> sendMessage(List<ChatMessage> messages) async {
    final body = {
      "contents": messages
          .map((m) => {
                "role": m.role,
                "parts": [
                  {"text": m.text}
                ]
              })
          .toList(),
    };

    final response = await http.post(
      Uri.parse("$model?key=${Env.geminiKey}"),
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": Env.geminiKey
      },
      body: jsonEncode(body),
    );

    final json = jsonDecode(response.body);

    return json["candidates"][0]["content"]["parts"][0]["text"];
  }
}
