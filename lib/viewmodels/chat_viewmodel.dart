// lib/viewmodels/chat_viewmodel.dart
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../core/gemini_api.dart';
import '../models/chat_message.dart';
import '../models/chat_history.dart';

class ChatViewModel extends ChangeNotifier {
  final GeminiApi api = GeminiApi();

  List<ChatMessage> messages = [];
  List<ChatHistory> _history = [];
  List<ChatHistory> get historyList => _history;

  bool isLoading = false;
  bool isRevealing = false;
  bool showModelLog = false;
  bool isSpeaking = false;

  bool isListening = false;
  String speechText = "";

  final FlutterTts tts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();

  ChatViewModel() {
    _initTTS();
  }

  void _initTTS() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.45); // slower, human-like
    await tts.setPitch(1.1);
    await tts.setVolume(1.0);
  }

  Future<void> toggleSpeak(String text) async {
    if (isSpeaking) {
      await tts.stop();
      isSpeaking = false;
      notifyListeners();
      return;
    }

    // Start speaking
    isSpeaking = true;
    notifyListeners();

    await tts.speak(text);

    // When TTS finishes naturally, reset state
    tts.setCompletionHandler(() {
      isSpeaking = false;
      notifyListeners();
    });
  }

  Future<void> startListening(TextEditingController controller) async {
    try {
      var status = await Permission.microphone.request();
      if (!status.isGranted) {
        if (kDebugMode) {
          print("Microphone Permission Denied");
        }
        return;
      }
      bool available = await speech.initialize(
        onStatus: (status) {
          if (status == "notListening") {
            isListening = false;
            notifyListeners();
          }
        },
        onError: (val) {
          if (kDebugMode) {
            print("Speech error: $val");
          } // <<< DEBUG
          isListening = false;
          notifyListeners();
        },
      );

      if (!available) {
        return;
      }

      isListening = true;
      notifyListeners();

      speech.listen(
        listenFor: Duration(seconds: 8),
        pauseFor: Duration(seconds: 3),
        onResult: (result) {
          controller.text = result.recognizedWords;
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
          notifyListeners();
        },
        localeId: "en_US",
        // ignore: deprecated_member_use
        cancelOnError: true,
        // ignore: deprecated_member_use
        partialResults: true,
      );
    } catch (e) {
      if (kDebugMode) {
        print("Speech Init Error: $e");
      }
      isListening = false;
      notifyListeners();
    }
  }

  Future<void> stopListening() async {
    await speech.stop();
    isListening = false;
    notifyListeners();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('history') ?? [];
    _history = data.map((s) => ChatHistory.fromJson(jsonDecode(s))).toList();
    notifyListeners();
  }

  Future<void> _persistHistoryList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'history',
      _history.map((h) => jsonEncode(h.toJson())).toList(),
    );
  }

  Future<void> saveOrUpdateCurrentChat({String? title}) async {
    if (messages.isEmpty) return;

    final chat = ChatHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title ?? _autoTitle(),
      time: DateTime.now(),
      messages: List.from(messages),
    );

    _history.removeWhere(
      (h) => h.id == chat.id,
    ); // ensure uniqueness (defensive)
    _history.insert(0, chat);
    await _persistHistoryList();
    notifyListeners();
  }

  String _autoTitle() {
    final firstUser = messages.firstWhere(
      (m) => m.role == 'user',
      orElse: () => messages.first,
    );
    final s = firstUser.text.trim();
    if (s.length > 40) return '${s.substring(0, 40)}...';
    return s.isEmpty ? 'New Chat' : s;
  }

  Future<void> deleteHistory(String id) async {
    _history.removeWhere((h) => h.id == id);
    await _persistHistoryList();
    notifyListeners();
  }

  ChatHistory? getHistoryById(String id) {
    try {
      return _history.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  /// NEW: openHistoryChat loads the history into current messages and navigates to chat screen.
  /// It mirrors the earlier method name your HistoryScreen expects.
  void openHistoryChat(BuildContext context, String id) {
    final chat = getHistoryById(id);
    if (chat == null) return;
    messages = chat.messages.map((m) => m.copyWith()).toList();
    notifyListeners();

    // navigate to chat screen route - adjust route name if you use different routing
    Navigator.pushNamed(context, '/chat');
  }

  Future<void> sendMessage(String userText) async {
    messages.add(ChatMessage(role: 'user', text: userText));
    notifyListeners();

    isLoading = true;
    showModelLog = true;
    notifyListeners();

    String modelReply;
    try {
      modelReply = await api.sendMessage(messages); // expected to return string
    } catch (e) {
      modelReply = "Error: ${e.toString()}";
    }

    isLoading = false;
    notifyListeners();

    // add assistant placeholder message with empty text so we can reveal into it
    final assistant = ChatMessage(role: 'model', text: '');
    messages.add(assistant);
    notifyListeners();

    isRevealing = true;
    showModelLog = true;
    notifyListeners();

    for (int i = 0; i < modelReply.length; i++) {
      final current = messages.last;
      current.text =
          current.text + modelReply[i]; // now allowed because text is mutable
      notifyListeners();
      await Future.delayed(Duration(microseconds: 100));
    }

    isRevealing = false;
    showModelLog = false;

    await saveOrUpdateCurrentChat();
    notifyListeners();
  }

  Future<void> startNewChat() async {
    if (messages.isNotEmpty) {
      await saveOrUpdateCurrentChat();
    }
    messages = [];
    isLoading = false;
    isRevealing = false;
    showModelLog = false;
    notifyListeners();
  }

  void openHistoryToCurrent(ChatHistory history) {
    messages = List.from(history.messages);
    notifyListeners();
  }
}
