import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app_providers.dart';
import '../../../../core/failures.dart';
import '../../../../data/local/db.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/sync_notes.dart';

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepositoryImpl(openNotesDb),
);

final getNotesProvider = Provider<GetNotes>(
  (ref) => GetNotes(ref.watch(noteRepositoryProvider)),
);

final addNoteProvider = Provider<AddNote>(
  (ref) => AddNote(ref.watch(noteRepositoryProvider)),
);

final syncNotesProvider = Provider<SyncNotes>(
  (ref) => SyncNotes(ref.watch(noteRepositoryProvider)),
);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final result = await ref.watch(getNotesProvider).call();
    if (result.failure != null) throw result.failure!;
    return result.notes;
  }

  Future<void> add({required String title, String body = ''}) async {
    final result = await ref.read(addNoteProvider)(title: title, body: body);
    if (result.failure != null) {
      state = AsyncError(result.failure!, StackTrace.current);
      return;
    }
    await refresh();
  }

  Future<Failure?> updateNote(Note note) async {
    final failure = await ref.read(noteRepositoryProvider).updateNote(note);
    if (failure != null) {
      state = AsyncError(failure, StackTrace.current);
      return failure;
    }
    await refresh();
    return null;
  }

  Future<void> delete(int id) async {
    final failure = await ref.read(noteRepositoryProvider).deleteNote(id);
    if (failure != null) {
      state = AsyncError(failure, StackTrace.current);
      return;
    }
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final result = await ref.read(getNotesProvider)();
    state = result.failure == null
        ? AsyncData(result.notes)
        : AsyncError(result.failure!, StackTrace.current);
  }
}

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
  retry: (retryCount, error) => null,
);

final noteDetailProvider = FutureProvider.family<Note?, int>((ref, id) async {
  final result = await ref.watch(noteRepositoryProvider).fetchNote(id);
  if (result.failure != null) throw result.failure!;
  return result.note;
}, retry: (retryCount, error) => null);

class NotesSyncNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    final result = await ref.watch(noteRepositoryProvider).countDirty();
    if (result.failure != null) throw result.failure!;
    return result.count;
  }

  Future<int> synchronize() async {
    state = const AsyncLoading();
    final result = await ref.read(syncNotesProvider)(
      forceOffline: ref.read(forceOfflineProvider),
    );
    if (result.failure != null) {
      state = AsyncError(result.failure!, StackTrace.current);
      throw result.failure!;
    }
    final pending = await ref.read(noteRepositoryProvider).countDirty();
    if (pending.failure != null) {
      state = AsyncError(pending.failure!, StackTrace.current);
      throw pending.failure!;
    }
    state = AsyncData(pending.count);
    ref.invalidate(notesProvider);
    return result.count;
  }
}

final notesSyncProvider = AsyncNotifierProvider<NotesSyncNotifier, int>(
  NotesSyncNotifier.new,
  retry: (retryCount, error) => null,
);
