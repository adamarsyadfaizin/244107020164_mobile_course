import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/local/cached_post.dart';

void main() {
  test('payload cache dapat diserialisasi dan dibaca kembali', () {
    const post = CachedPost(id: 1, title: 'Judul', body: 'Isi');
    final restored = CachedPost.fromPayload(post.toPayload());
    expect(restored.id, 1);
    expect(restored.title, 'Judul');
    expect(restored.body, 'Isi');
  });

  test('fromJson cache aman terhadap field hilang', () {
    final post = CachedPost.fromJson(const {'id': 2});
    expect(post.id, 2);
    expect(post.title, '');
    expect(post.body, '');
  });
}
