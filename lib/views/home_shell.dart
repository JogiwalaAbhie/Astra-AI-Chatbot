import 'dart:ui';
import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'history_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  final screens = [
    ChatScreen(),
    const HistoryScreen(),
    const _SettingsScreenMock(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          screens[index],
          Align(alignment: Alignment.bottomCenter, child: _glassTabBar()),
        ],
      ),
    );
  }

  Widget _glassTabBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(25),
        topRight: Radius.circular(25),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: 70,
          color: Colors.white.withValues(alpha:0.08),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navIcon(Icons.chat, 0),
              _navIcon(Icons.history, 1),
              _navIcon(Icons.settings, 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, int i) {
    final active = index == i;
    return GestureDetector(
      onTap: () => setState(() => index = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active ? Colors.white.withValues(alpha:0.2) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: active ? Colors.black : Colors.white70,
          size: 28,
        ),
      ),
    );
  }
}

class _SettingsScreenMock extends StatelessWidget {
  const _SettingsScreenMock();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Settings Coming Soon",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
