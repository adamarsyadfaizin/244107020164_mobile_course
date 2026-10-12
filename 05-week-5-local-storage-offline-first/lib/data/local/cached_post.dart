import 'dart:convert';

class CachedPost {
  const CachedPost({required this.id, required this.title, required this.body});

  final int id;
  final String title;
  final String body;

  factory CachedPost.fromJson(Map<String, dynamic> json) => CachedPost(
    id: (json['id'] as num?)?.toInt() ?? 0,
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
  );

  String toPayload() => jsonEncode({'id': id, 'title': title, 'body': body});

  factory CachedPost.fromPayload(String payload) {
    final json = jsonDecode(payload);
    return CachedPost.fromJson(json is Map<String, dynamic> ? json : const {});
  }
}
