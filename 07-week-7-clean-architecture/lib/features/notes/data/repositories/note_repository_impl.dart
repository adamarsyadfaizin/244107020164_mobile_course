import 'package:sqflite/sqflite.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl(this._openDb);

  final Future<Database> Function() _openDb;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    try {
      final db = await _openDb();
      final rows = await db.query('notes', orderBy: 'updated_at DESC');
      return (
        notes: rows.map((row) => NoteModel.fromMap(row).toEntity()).toList(),
        failure: null,
      );
    } catch (_) {
      return (
        notes: const <Note>[],
        failure: const LocalFailure('Gagal membaca catatan lokal.'),
      );
    }
  }

  @override
  Future<({Note? note, Failure? failure})> fetchNote(int id) async {
    try {
      final db = await _openDb();
      final rows = await db.query('notes', where: 'id = ?', whereArgs: [id]);
      return (
        note: rows.isEmpty ? null : NoteModel.fromMap(rows.first).toEntity(),
        failure: null,
      );
    } catch (_) {
      return (
        note: null,
        failure: const LocalFailure('Gagal membaca catatan lokal.'),
      );
    }
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    try {
      final db = await _openDb();
      final model = NoteModel(
        title: title,
        body: body,
        updatedAt: DateTime.now(),
        dirty: true,
      );
      final id = await db.insert('notes', model.toMap());
      return (
        note: Note(
          id: id,
          title: model.title,
          body: model.body,
          updatedAt: model.updatedAt,
          dirty: true,
        ),
        failure: null,
      );
    } catch (_) {
      return (
        note: null,
        failure: const LocalFailure('Gagal menyimpan catatan.'),
      );
    }
  }

  @override
  Future<Failure?> updateNote(Note note) async {
    if (note.id == null) {
      return const LocalFailure('Catatan tidak ditemukan.');
    }
    try {
      final db = await _openDb();
      final model = NoteModel(
        id: note.id,
        title: note.title,
        body: note.body,
        updatedAt: DateTime.now(),
        dirty: true,
      );
      await db.update(
        'notes',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
      return null;
    } catch (_) {
      return const LocalFailure('Gagal memperbarui catatan.');
    }
  }

  @override
  Future<Failure?> deleteNote(int id) async {
    try {
      final db = await _openDb();
      await db.delete('notes', where: 'id = ?', whereArgs: [id]);
      return null;
    } catch (_) {
      return const LocalFailure('Gagal menghapus catatan.');
    }
  }

  @override
  Future<({int count, Failure? failure})> countDirty() async {
    try {
      final db = await _openDb();
      final rows = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM notes WHERE dirty = 1',
      );
      return (count: ((rows.first['c'] as num?)?.toInt() ?? 0), failure: null);
    } catch (_) {
      return (
        count: 0,
        failure: const LocalFailure('Gagal menghitung catatan tertunda.'),
      );
    }
  }

  @override
  Future<Failure?> markAllSynced() async {
    try {
      final db = await _openDb();
      await db.update('notes', {'dirty': 0}, where: 'dirty = 1');
      return null;
    } catch (_) {
      return const LocalFailure('Gagal menyelesaikan sinkronisasi.');
    }
  }
}
