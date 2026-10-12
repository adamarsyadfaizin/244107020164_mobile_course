import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/post.dart';
import '../data/network_errors.dart';
import '../data/providers.dart';

final postDetailProvider = FutureProvider.family<Post, int>(
  (ref, id) => ref.watch(postRepositoryProvider).fetchPost(id),
  retry: (retryCount, error) => null,
);

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.id, this.initialPost});

  final int id;
  final Post? initialPost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cachedPost = initialPost;
    return Scaffold(
      appBar: AppBar(title: Text('Post $id')),
      body: cachedPost != null
          ? _PostContent(post: cachedPost)
          : ref
                .watch(postDetailProvider(id))
                .when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            friendlyErrorMessage(error),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () =>
                                ref.invalidate(postDetailProvider(id)),
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (post) => _PostContent(post: post),
                ),
    );
  }
}

class _PostContent extends StatelessWidget {
  const _PostContent({required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(post.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text(post.body),
      ],
    ),
  );
}
