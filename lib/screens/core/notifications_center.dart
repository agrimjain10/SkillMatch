import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/supabase_provider.dart';

class NotificationsCenter extends ConsumerWidget {
  const NotificationsCenter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(chatListProvider).value ?? const <Map<String, dynamic>>[];
    final projects = ref.watch(allProjectsProvider).value ?? const <Map<String, dynamic>>[];
    final currentUserId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
    final alerts = <_Alert>[
      ...matches.map((match) {
        final other = match['other_user'] as Map<String, dynamic>?;
        final isMatched = match['status'] == 'matched';
        final isIncoming = match['status'] == 'pending' && match['user2_id'] == currentUserId;
        return _Alert(
          title: isMatched
              ? 'MATCH CONNECTED'
              : isIncoming
                  ? 'MATCH REQUEST'
                  : 'WAITING FOR MATCH',
          message: isMatched
              ? 'CHAT UNLOCKED WITH ${(other?['full_name'] ?? 'UNKNOWN USER').toString().toUpperCase()}.'
              : isIncoming
                  ? '${(other?['full_name'] ?? 'UNKNOWN USER').toString().toUpperCase()} MATCHED YOU. MATCH BACK TO OPEN CHAT.'
                  : 'WAITING FOR ${(other?['full_name'] ?? 'UNKNOWN USER').toString().toUpperCase()} TO MATCH BACK.',
          createdAt: match['created_at'],
          highlighted: isMatched || isIncoming,
        );
      }),
      ...projects.take(5).map((project) => _Alert(
            title: 'PROJECT ACTIVE',
            message: (project['title'] ?? 'UNTITLED PROJECT').toString().toUpperCase(),
            createdAt: project['created_at'],
          )),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('SYSTEM ALERTS', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GridBackground(
        child: alerts.isEmpty
            ? const Center(child: Text('NO SYSTEM ALERTS YET.'))
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: alerts.length,
                itemBuilder: (context, index) => _NotificationTile(alert: alerts[index]),
              ),
      ),
    );
  }
}

class _Alert {
  final String title;
  final String message;
  final dynamic createdAt;
  final bool highlighted;
  const _Alert({
    required this.title,
    required this.message,
    this.createdAt,
    this.highlighted = false,
  });
}

class _NotificationTile extends StatelessWidget {
  final _Alert alert;
  const _NotificationTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.brutalistDecoration(
        color: alert.highlighted ? AppTheme.tertiaryContainer : AppTheme.surfaceContainerLowest,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            alert.highlighted ? Icons.bolt : Icons.notifications_none,
            color: AppTheme.ink,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                const SizedBox(height: 4),
                Text(alert.message, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Text(_dateLabel(alert.createdAt), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _dateLabel(dynamic createdAt) {
    final date = DateTime.tryParse(createdAt?.toString() ?? '');
    if (date == null) return '';
    final diff = DateTime.now().difference(date.toLocal());
    if (diff.inMinutes < 1) return 'NOW';
    if (diff.inHours < 1) return '${diff.inMinutes}M AGO';
    if (diff.inDays < 1) return '${diff.inHours}H AGO';
    return '${diff.inDays}D AGO';
  }
}
