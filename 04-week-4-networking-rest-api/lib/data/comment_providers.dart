import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/comment.dart';
import 'providers.dart';
import 'repositories/comment_repository.dart';

final commentRepositoryProvider = Provider<CommentRepository>(
  // Dio terpusat dipakai ulang; base URL tidak diduplikasi di repository.
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

class CommentsNotifier extends AsyncNotifier<List<Comment>> {
  CommentsNotifier(this.postId);
  final int postId;

  @override
  Future<List<Comment>> build() {
    // Exception repository otomatis diubah Riverpod menjadi AsyncError.
    return ref.watch(commentRepositoryProvider).fetchComments(postId);
  }

  Future<void> retry() async {
    // Retry menampilkan loading lalu menjaga error di dalam AsyncValue.
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(commentRepositoryProvider).fetchComments(postId),
    );
  }
}

final commentsProvider =
    AsyncNotifierProvider.family<CommentsNotifier, List<Comment>, int>(
      CommentsNotifier.new,
      retry: (retryCount, error) => null,
    );
