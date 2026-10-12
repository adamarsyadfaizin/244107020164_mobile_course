import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/providers/todo_provider.dart';

void main() {
  test('TodoListNotifier mengubah state secara immutable', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(todoListProvider.notifier);
    notifier.add('Belajar Riverpod');
    final beforeToggle = container.read(todoListProvider);
    notifier.toggle(0);
    final afterToggle = container.read(todoListProvider);
    expect(beforeToggle, isNot(same(afterToggle)));
    expect(afterToggle.single.done, isTrue);
  });

  test('provider turunan hanya menampilkan tugas yang belum selesai', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(todoListProvider.notifier);
    notifier.add('Selesai');
    notifier.add('Belum selesai');
    notifier.toggle(0);
    expect(container.read(pendingTodoListProvider).map((todo) => todo.title), [
      'Belum selesai',
    ]);
  });
}
