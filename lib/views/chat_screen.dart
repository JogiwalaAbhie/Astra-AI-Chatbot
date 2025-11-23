// lib/views/chat_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../viewmodels/chat_viewmodel.dart';
import 'widgets/glass_input_field.dart';
import 'widgets/glass_message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();
  late AnimationController _animController;
  late ScrollController _scrollController;
  double _appBarAlpha = 0.0;

  @override
  void initState() {
    super.initState();

    // Animated background controller
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    // scroll controller to adjust appBar color
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // compute alpha 0..1 depending on vertical offset (tweak divisor for sensitivity)
    final offset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    final alpha = (offset / 120).clamp(0.0, 1.0);
    if (alpha != _appBarAlpha) {
      setState(() => _appBarAlpha = alpha);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ChatViewModel>(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: GlassmorphicContainer(
          height: 88,
          width: double.infinity,
          borderRadius: 0,
          blur: 20, // ⭐ Strong blur
          alignment: Alignment.center,
          border: 0,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha:0.15 * _appBarAlpha + 0.05),
              Colors.blue.withValues(alpha:0.10 * _appBarAlpha + 0.03),
            ],
          ),
          borderGradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha:0.20),
              Colors.blueAccent.withValues(alpha:0.20),
            ],
          ),
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  // Gradient title
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Colors.cyanAccent,
                          Colors.blueAccent,
                          Colors.tealAccent,
                        ],
                      ).createShader(bounds),
                      child: Row(
                        children: [
                          Lottie.asset('assets/lottie/loader.json', height: 24),
                          SizedBox(width: 8,),
                          const Text(
                            "Astra AI",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // New chat button
                  _glassIconButton(
                    icon: Icons.add,
                    tooltip: 'New Chat',
                    onTap: () async {
                      await vm.startNewChat();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // animated left->right moving gradient background
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              final t = _animController.value;
              // move gradient stops left->right using animated begin/end alignment
              final begin = Alignment(-1.5 + 3.0 * t, -0.3);
              final end = Alignment(-0.5 + 3.0 * t, 0.8);
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: begin,
                    end: end,
                    colors: [
                      Colors.deepPurple.withValues(alpha:0.10),
                      Colors.deepPurple.withValues(alpha:0.08),
                      Colors.blue.withValues(alpha:0.16),
                      Colors.indigo.withValues(alpha:0.06),
                      Colors.indigo.withValues(alpha:0.02),
                    ],
                    stops: const [0.0, 0.3, 0.4, 0.75, 1.0],
                  ),
                ),
              );
            },
          ),

          // content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 8, top: 12),
                    reverse: true,
                    itemCount: vm.messages.length,
                    itemBuilder: (_, i) {
                      final index =
                          vm.messages.length - 1 - i; // manually reverse
                      final msg = vm.messages[index];
                      return GlassBubble(
                        message: msg,
                        isUser: msg.role == 'user',
                      );
                    },
                  ),
                ),

                // Typing indicator (model composing) area
                if (vm.isLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 12),
                        Shimmer.fromColors(
                          baseColor: Colors.white54,
                          highlightColor: Colors.blueAccent,
                          child: const Text(
                            "Astra is thinking...",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Input field
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: GlassInput(
                    controller: controller,
                    onSend: () {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;
                      vm.sendMessage(text);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                      });

                      controller.clear();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassIconButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: Colors.white.withValues(alpha:0.08),
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(icon, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }
}
