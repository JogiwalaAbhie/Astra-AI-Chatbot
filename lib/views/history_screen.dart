import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../models/chat_history.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ChatViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("History"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: vm.historyList.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: vm.historyList.length,
              itemBuilder: (context, index) {
                final h = vm.historyList[index];
                return _buildHistoryTile(context, vm, h, index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, color: Colors.white24, size: 80),
          const SizedBox(height: 16),
          const Text(
            "No history found",
            style: TextStyle(color: Colors.white54, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(
    BuildContext context,
    ChatViewModel vm,
    ChatHistory h,
    int index,
  ) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Dismissible(
          key: ValueKey(h.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => vm.deleteHistory(h.id),
          background: _deleteBackground(),

          child: GestureDetector(
            onTap: () => vm.openHistoryChat(context, h.id),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: _glassDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    h.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "${h.messages.length} messages • ${_timeAgo(h.time)}",
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _glassDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white24, width: 1),
      gradient: LinearGradient(
        colors: [
          Colors.white.withValues(alpha:0.05),
          Colors.white.withValues(alpha:0.02),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.4),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _deleteBackground() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.red, size: 30),
      ),
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hours ago";
    if (diff.inDays < 7) return "${diff.inDays} days ago";
    return "${(diff.inDays / 7).floor()} week ago";
  }
}
