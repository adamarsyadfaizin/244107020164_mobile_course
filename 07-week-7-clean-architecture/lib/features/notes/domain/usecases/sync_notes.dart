import '../../../../core/failures.dart';
import '../repositories/note_repository.dart';

class SyncNotes {
  const SyncNotes(this._repository);
  final NoteRepository _repository;

  Future<({int count, Failure? failure})> call({
    required bool forceOffline,
  }) async {
    if (forceOffline) {
      return (
        count: 0,
        failure: const LocalFailure(
          'Mode offline aktif. Sinkronisasi ditunda.',
        ),
      );
    }
    final pending = await _repository.countDirty();
    if (pending.failure != null || pending.count == 0) return pending;

    // Week 5 has no write backend: simulate a successful upload.
    await Future<void>.delayed(const Duration(seconds: 1));
    final failure = await _repository.markAllSynced();
    return (count: failure == null ? pending.count : 0, failure: failure);
  }
}
