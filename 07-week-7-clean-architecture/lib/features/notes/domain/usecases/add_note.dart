import '../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class AddNote {
  const AddNote(this._repository);
  final NoteRepository _repository;

  Future<({Note? note, Failure? failure})> call({
    required String title,
    String body = '',
  }) {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      return Future.value((
        note: null,
        failure: const LocalFailure('Judul catatan harus diisi.'),
      ));
    }
    return _repository.addNote(title: cleanTitle, body: body.trim());
  }
}
