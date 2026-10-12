import 'package:flutter/material.dart';

import '../providers/todo_provider.dart';

class TodoTile extends StatelessWidget {
  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onRemove,
  });

  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Checkbox(value: todo.done, onChanged: (_) => onToggle()),
    title: Text(
      todo.title,
      style: TextStyle(
        decoration: todo.done ? TextDecoration.lineThrough : null,
      ),
    ),
    trailing: IconButton(
      icon: const Icon(Icons.delete_outline),
      onPressed: onRemove,
    ),
  );
}
