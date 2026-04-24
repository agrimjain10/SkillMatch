import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/chat_provider.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(chatListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SECURE COMMS', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GridBackground(
        child: chatsAsync.when(
          data: (matches) {
            if (matches.isEmpty) return const _EmptyChats();
            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: matches.length,
              itemBuilder: (context, index) => _ChatListItem(match: matches[index], index: index),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.ink)),
          error: (error, _) => _ErrorState(
            title: 'COMMS UNAVAILABLE',
            message: error.toString(),
          ),
        ),
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final Map<String, dynamic>? match;
  final int index;
  const _ChatListItem({this.match, required this.index});

  @override
  Widget build(BuildContext context) {
    final otherUser = match?['other_user'] as Map<String, dynamic>?;
    final name = (otherUser?['full_name'] ?? 'UNKNOWN USER').toString();
    final matchId = (match?['id'] ?? '').toString();
    final isMatched = match?['status'] == 'matched';
    return GestureDetector(
      onTap: () {
        if (isMatched) {
          context.push('/chat/$matchId?name=${Uri.encodeComponent(name)}');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CHAT UNLOCKS WHEN BOTH USERS MATCH.')),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.brutalistDecoration(
          color: isMatched ? AppTheme.primaryContainer : AppTheme.surfaceContainerLowest,
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppTheme.ink,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  Text(
                    isMatched ? 'OPEN SECURE CHANNEL' : 'WAITING FOR MUTUAL MATCH',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(isMatched ? Icons.lock_open : Icons.lock, size: 18),
                const SizedBox(height: 4),
                CircleAvatar(radius: 4, backgroundColor: isMatched ? AppTheme.ink : Colors.grey),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 160.ms).slideX(begin: 0.05, duration: 220.ms);
  }
}

class _ErrorState extends StatelessWidget {
  final String title;
  final String message;
  const _ErrorState({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.brutalistDecoration(color: AppTheme.primaryContainer),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, maxLines: 4, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyChats extends StatelessWidget {
  const _EmptyChats();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: AppTheme.brutalistDecoration(color: AppTheme.secondaryContainer),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.forum_outlined, size: 56),
              const SizedBox(height: 16),
              const Text('NO SECURE COMMS YET', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 8),
              const Text('DISCOVER A COLLABORATOR TO OPEN A CHANNEL.', textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () => context.go('/discover'), child: const Text('DISCOVER TALENT')),
            ],
          ),
        ),
      ),
    );
  }
}
