import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/core/format.dart';

void main() {
  test('parseNoteId aman untuk route tidak valid', () {
    expect(parseNoteId('7'), 7);
    expect(parseNoteId('abc'), 0);
    expect(parseNoteId(null), 0);
  });

  test('formatLastOpened menjaga teks waktu atau fallback', () {
    expect(formatLastOpened(null), 'Belum pernah dibuka');
    expect(formatLastOpened('2026-09-27T10:00:00'), '2026-09-27T10:00:00');
  });
}
