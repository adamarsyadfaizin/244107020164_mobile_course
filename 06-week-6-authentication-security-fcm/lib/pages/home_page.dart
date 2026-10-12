import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: const Text('Campus Notify'),
      actions: [
        IconButton(
          tooltip: 'Keluar',
          onPressed: () => ref.read(authStateProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.campaign_outlined),
            title: const Text('Pengumuman perkuliahan'),
            subtitle: const Text('Ketuk untuk melihat detail'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.announcement('1')),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: const Text('Debug FCM'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.debug),
          ),
        ),
      ],
    ),
  );
}
