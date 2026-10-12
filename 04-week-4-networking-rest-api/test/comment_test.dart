import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  test('Comment.fromJson aman terhadap field yang hilang', () {
    final comment = Comment.fromJson({'id': 5});
    expect(comment.id, 5);
    expect(comment.postId, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });

  test('Comment.fromJson menerima num untuk id sebagai edge case', () {
    final comment = Comment.fromJson({'postId': 2.0, 'id': 8.0});
    expect(comment.postId, 2);
    expect(comment.id, 8);
  });
}
