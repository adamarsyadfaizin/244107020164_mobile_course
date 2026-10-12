import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);
    final lastOpened = ref.watch(lastOpenedProvider);
    final forceOffline = ref.watch(forceOfflineProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Tema gelap'),
            value: darkMode.value ?? false,
            onChanged: darkMode.isLoading
                ? null
                : (_) => ref.read(darkModeProvider.notifier).toggle(),
          ),
          SwitchListTile(
            title: const Text('Force offline'),
            subtitle: const Text('Demo offline tanpa mengubah Wi-Fi'),
            value: forceOffline,
            onChanged: (value) {
              ref.read(forceOfflineProvider.notifier).setValue(value);
            },
          ),
          ListTile(
            title: const Text('Terakhir dibuka'),
            subtitle: Text(
              lastOpened.when(
                loading: () => 'Memuat...',
                error: (error, stack) => 'Tidak dapat membaca waktu',
                data: (value) => value ?? 'Belum pernah dibuka',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
