import '../../../../core/failures.dart';
import '../entities/cached_post.dart';
import '../repositories/post_repository.dart';

class GetCachedPosts {
  const GetCachedPosts(this._repository);
  final PostRepository _repository;

  Future<({List<CachedPost> posts, Failure? failure})> call({
    required bool forceOffline,
    void Function(List<CachedPost>)? onRefreshed,
  }) => _repository.loadCacheFirst(
    forceOffline: forceOffline,
    onRefreshed: onRefreshed,
  );
}
