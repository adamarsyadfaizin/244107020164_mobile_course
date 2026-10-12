import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local/cached_post.dart';
import 'local/note.dart';
import 'prefs.dart';
import 'repositories/note_repository.dart';
import 'sync.dart';

final prefsRepositoryProvider = Provider<PrefsRepository>(
  (ref) => PrefsRepository(),
);

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepository(),
);

final syncServiceProvider = Provider<SyncService>((ref) => SyncService());

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() {
    return ref.watch(prefsRepositoryProvider).getDarkMode();
  }

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

final darkModeProvider = AsyncNotifierProvider<DarkModeNotifier, bool>(
  DarkModeNotifier.new,
);

final lastOpenedProvider = FutureProvider<String?>((ref) async {
  final prefs = ref.watch(prefsRepositoryProvider);
  final previous = await prefs.getLastOpened();
  await prefs.markOpenedNow();
  return previous;
});

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() {
    return ref.watch(noteRepositoryProvider).fetchNotes();
  }

  Future<void> add({required String title, String body = ''}) async {
    await ref.read(noteRepositoryProvider).addNote(title: title, body: body);
    await refresh();
  }

  Future<void> updateNote(Note note) async {
    await ref.read(noteRepositoryProvider).updateNote(note);
    await refresh();
  }

  Future<void> delete(int id) async {
    await ref.read(noteRepositoryProvider).deleteNote(id);
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(noteRepositoryProvider).fetchNotes(),
    );
  }
}

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
  retry: (retryCount, error) => null,
);

final noteDetailProvider = FutureProvider.family<Note?, int>(
  (ref, id) => ref.watch(noteRepositoryProvider).fetchNote(id),
  retry: (retryCount, error) => null,
);

class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setValue(bool value) => state = value;
}

final forceOfflineProvider = NotifierProvider<ForceOfflineNotifier, bool>(
  ForceOfflineNotifier.new,
);

class CachedPostsNotifier extends AsyncNotifier<List<CachedPost>> {
  @override
  Future<List<CachedPost>> build() async {
    var disposed = false;
    ref.onDispose(() => disposed = true);
    final service = ref.watch(syncServiceProvider);
    final forceOffline = ref.watch(forceOfflineProvider);
    return service.loadPostsCacheFirst(
      forceOffline: forceOffline,
      onRefreshed: (fresh) {
        if (!disposed) state = AsyncData(fresh);
      },
    );
  }

  void retry() => ref.invalidateSelf();
}

final cachedPostsProvider =
    AsyncNotifierProvider<CachedPostsNotifier, List<CachedPost>>(
      CachedPostsNotifier.new,
      retry: (retryCount, error) => null,
    );

class NotesSyncNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() {
    return ref.watch(noteRepositoryProvider).countDirty();
  }

  Future<int> synchronize() async {
    if (ref.read(forceOfflineProvider)) {
      final error = StateError('Mode offline aktif. Sinkronisasi ditunda.');
      state = AsyncError(error, StackTrace.current);
      throw error;
    }
    state = const AsyncLoading();
    final repository = ref.read(noteRepositoryProvider);
    try {
      final count = await syncNotes(repository);
      state = AsyncData(await repository.countDirty());
      ref.invalidate(notesProvider);
      return count;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final notesSyncProvider = AsyncNotifierProvider<NotesSyncNotifier, int>(
  NotesSyncNotifier.new,
  retry: (retryCount, error) => null,
);
