import 'dart:convert';

import '../../domain/entities/cached_post.dart';

class CachedPostModel extends CachedPost {
  const CachedPostModel({
    required super.id,
    required super.title,
    required super.body,
  });

  factory CachedPostModel.fromJson(Map<String, dynamic> json) =>
      CachedPostModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );

  String toPayload() => jsonEncode({'id': id, 'title': title, 'body': body});

  factory CachedPostModel.fromPayload(String payload) {
    final value = jsonDecode(payload);
    return CachedPostModel.fromJson(
      value is Map<String, dynamic> ? value : const {},
    );
  }

  CachedPost toEntity() => CachedPost(id: id, title: title, body: body);
}
