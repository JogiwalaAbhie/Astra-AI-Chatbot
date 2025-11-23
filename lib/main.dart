import 'package:astra_abhie_ai/views/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/chat_viewmodel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatViewModel()..loadHistory()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: ChatScreen());
  }
}
