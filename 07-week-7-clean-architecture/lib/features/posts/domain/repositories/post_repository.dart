import '../../../../core/failures.dart';
import '../entities/cached_post.dart';

abstract class PostRepository {
  Future<({List<CachedPost> posts, Failure? failure})> loadCacheFirst({
    required bool forceOffline,
    void Function(List<CachedPost>)? onRefreshed,
  });
}
