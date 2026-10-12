import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

class CachedPostsPage extends ConsumerWidget {
  const CachedPostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(cachedPostsProvider);
    final forceOffline = ref.watch(forceOfflineProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bacaan Cache-first'),
        actions: [
          if (forceOffline)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Chip(label: Text('Offline')),
            ),
        ],
      ),
      body: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: FilledButton(
            onPressed: () => ref.read(cachedPostsProvider.notifier).retry(),
            child: const Text('Coba lagi'),
          ),
        ),
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('Cache belum tersedia.'));
          }
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return ListTile(
                leading: CircleAvatar(child: Text(post.id.toString())),
                title: Text(
                  post.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  post.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
