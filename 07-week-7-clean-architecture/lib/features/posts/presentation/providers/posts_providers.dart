import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app_providers.dart';
import '../../../../data/local/db.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/entities/cached_post.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/usecases/get_cached_posts.dart';

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepositoryImpl(openNotesDb),
);

final getCachedPostsProvider = Provider<GetCachedPosts>(
  (ref) => GetCachedPosts(ref.watch(postRepositoryProvider)),
);

class CachedPostsNotifier extends AsyncNotifier<List<CachedPost>> {
  @override
  Future<List<CachedPost>> build() async {
    var disposed = false;
    ref.onDispose(() => disposed = true);
    final result = await ref.watch(getCachedPostsProvider)(
      forceOffline: ref.watch(forceOfflineProvider),
      onRefreshed: (fresh) {
        if (!disposed) state = AsyncData(fresh);
      },
    );
    if (result.failure != null) throw result.failure!;
    return result.posts;
  }

  void retry() => ref.invalidateSelf();
}

final cachedPostsProvider =
    AsyncNotifierProvider<CachedPostsNotifier, List<CachedPost>>(
      CachedPostsNotifier.new,
      retry: (retryCount, error) => null,
    );
