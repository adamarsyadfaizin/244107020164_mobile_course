import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/core/failures.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';
import 'package:week5_offline_notes/features/notes/domain/usecases/add_note.dart';
import 'package:week5_offline_notes/features/notes/domain/usecases/get_notes.dart';

import 'fakes/fake_note_repository.dart';

void main() {
  test('GetNotes meneruskan daftar dari repository palsu', () async {
    final repo = FakeNoteRepository(
      items: [Note(title: 'A', updatedAt: DateTime(2026, 9, 27))],
    );
    final result = await GetNotes(repo)();
    expect(result.failure, isNull);
    expect(result.notes.single.title, 'A');
  });

  test('GetNotes meneruskan Failure tanpa melempar', () async {
    final result = await GetNotes(FakeNoteRepository(fail: true))();
    expect(result.failure, isA<LocalFailure>());
    expect(result.notes, isEmpty);
  });

  test('AddNote menolak judul kosong sebelum menyentuh repository', () async {
    final repo = FakeNoteRepository();
    final result = await AddNote(repo)(title: '   ');
    expect(result.failure, isA<LocalFailure>());
    expect(repo.items, isEmpty);
  });
}
