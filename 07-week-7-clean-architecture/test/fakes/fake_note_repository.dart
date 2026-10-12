import 'package:week5_offline_notes/core/failures.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';
import 'package:week5_offline_notes/features/notes/domain/repositories/note_repository.dart';

class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({List<Note> items = const [], this.fail = false})
    : items = [...items];

  final List<Note> items;
  final bool fail;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    if (fail) {
      return (
        notes: const <Note>[],
        failure: const LocalFailure('db locked (simulasi)'),
      );
    }
    return (notes: [...items], failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> fetchNote(int id) async {
    for (final note in items) {
      if (note.id == id) return (note: note, failure: null);
    }
    return (note: null, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    final note = Note(
      id: items.length + 1,
      title: title,
      body: body,
      updatedAt: DateTime(2026, 9, 27),
      dirty: true,
    );
    items.add(note);
    return (note: note, failure: null);
  }

  @override
  Future<Failure?> updateNote(Note note) async {
    final index = items.indexWhere((item) => item.id == note.id);
    if (index >= 0) items[index] = note;
    return null;
  }

  @override
  Future<Failure?> deleteNote(int id) async {
    items.removeWhere((note) => note.id == id);
    return null;
  }

  @override
  Future<({int count, Failure? failure})> countDirty() async =>
      (count: items.where((note) => note.dirty).length, failure: null);

  @override
  Future<Failure?> markAllSynced() async => null;
}
