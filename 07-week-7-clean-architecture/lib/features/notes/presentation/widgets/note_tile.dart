import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({super.key, required this.note, required this.onDelete});

  final Note note;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: note.id == null ? null : () => context.push('/note/${note.id}'),
    title: Text(note.title),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (note.body.isNotEmpty)
          Text(note.body, maxLines: 1, overflow: TextOverflow.ellipsis),
        if (note.dirty)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Chip(
              label: Text('Belum tersinkron'),
              visualDensity: VisualDensity.compact,
            ),
          ),
      ],
    ),
    trailing: IconButton(
      icon: const Icon(Icons.delete_outline),
      onPressed: onDelete,
    ),
  );
}
