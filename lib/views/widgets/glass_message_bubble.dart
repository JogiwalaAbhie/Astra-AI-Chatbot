// lib/views/widgets/glass_message_bubble.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:provider/provider.dart';
import '../../models/chat_message.dart';
import '../../viewmodels/chat_viewmodel.dart';

class GlassBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;

  const GlassBubble({super.key, required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isUser
        ? Colors.cyanAccent.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.06);

    final borderRadius = BorderRadius.circular(18);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: borderRadius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.78,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: borderRadius,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.03),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- USER TEXT ---
                      if (isUser)
                        Text(
                          message.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),

                      // --- MODEL MARKDOWN + TTS ICON ---
                      if (!isUser)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Markdown content
                            Expanded(
                              child: _buildModelMarkdown(context, message.text),
                            ),

                            const SizedBox(width: 6),

                            // 🔊 TTS SPEAKER BUTTON
                            InkWell(
                              onTap: () {
                                Provider.of<ChatViewModel>(
                                  context,
                                  listen: false,
                                ).toggleSpeak(message.text);
                              },
                              child: Consumer<ChatViewModel>(
                                builder: (_, vm, __) {
                                  final isPlaying = vm.isSpeaking;

                                  return AnimatedSwitcher(
                                    duration: Duration(milliseconds: 250),
                                    transitionBuilder: (child, anim) =>
                                        ScaleTransition(
                                          scale: anim,
                                          child: child,
                                        ),
                                    child: Icon(
                                      isPlaying
                                          ? Icons.stop_rounded
                                          : Icons.volume_up_rounded,
                                      key: ValueKey(isPlaying),
                                      size: 22,
                                      color: Colors.cyanAccent.withValues(
                                        alpha: 0.85,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelMarkdown(BuildContext context, String md) {
    if (md.isEmpty) return const SizedBox.shrink();

    return MarkdownBody(
      data: md,
      selectable: true,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: const TextStyle(color: Colors.white70, fontSize: 15),
        code: const TextStyle(
          fontFamily: 'monospace',
          backgroundColor: Colors.black26,
          color: Colors.greenAccent,
        ),
        h1: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        h2: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        blockquote: const TextStyle(color: Colors.white60),
      ),
    );
  }
}
