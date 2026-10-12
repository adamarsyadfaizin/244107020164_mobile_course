import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteDetailProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text('Catatan $id')),
      body: noteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(failureMessage(error))),
        data: (note) {
          if (note == null) {
            return const Center(child: Text('Catatan tidak ditemukan.'));
          }
          return _NoteDetailForm(note: note);
        },
      ),
    );
  }
}

class _NoteDetailForm extends ConsumerStatefulWidget {
  const _NoteDetailForm({required this.note});
  final Note note;

  @override
  ConsumerState<_NoteDetailForm> createState() => _NoteDetailFormState();
}

class _NoteDetailFormState extends ConsumerState<_NoteDetailForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _bodyController = TextEditingController(text: widget.note.body);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      TextField(
        controller: _titleController,
        decoration: const InputDecoration(labelText: 'Judul'),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _bodyController,
        minLines: 5,
        maxLines: null,
        decoration: const InputDecoration(labelText: 'Isi'),
      ),
      const SizedBox(height: 24),
      FilledButton(onPressed: _save, child: const Text('Simpan perubahan')),
    ],
  );

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final failure = await ref
        .read(notesProvider.notifier)
        .updateNote(
          Note(
            id: widget.note.id,
            title: title,
            body: _bodyController.text.trim(),
            updatedAt: widget.note.updatedAt,
            dirty: true,
          ),
        );
    if (failure != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message)));
      return;
    }
    ref
      ..invalidate(noteDetailProvider(widget.note.id!))
      ..invalidate(notesSyncProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Catatan diperbarui.')));
  }
}
