import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/chat_viewmodel.dart';

class GlassInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const GlassInput({super.key, required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ChatViewModel>(context);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.06),
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                /// ————— SPEECH BUTTON —————
                IconButton(
                  icon: Icon(
                    vm.isListening ? Icons.mic : Icons.mic_none,
                    color: vm.isListening ? Colors.redAccent : Colors.white70,
                  ),
                  onPressed: () {
                    if (vm.isListening) {
                      vm.stopListening();
                    } else {
                      vm.startListening(controller);
                    }
                  },
                ),

                /// ————— TEXT FIELD —————
                Expanded(
                  child: TextField(
                    textCapitalization: TextCapitalization.sentences,
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Ask Astra...",
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),

                /// ————— SEND BUTTON —————
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.cyanAccent),
                  onPressed: onSend,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
