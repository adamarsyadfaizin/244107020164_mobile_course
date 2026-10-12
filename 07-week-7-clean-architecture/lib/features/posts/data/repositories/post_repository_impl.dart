import 'dart:async';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/cached_post.dart';
import '../../domain/repositories/post_repository.dart';
import '../models/cached_post_model.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl(this._openDb, {Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://jsonplaceholder.typicode.com',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  final Future<Database> Function() _openDb;
  final Dio _dio;

  @override
  Future<({List<CachedPost> posts, Failure? failure})> loadCacheFirst({
    required bool forceOffline,
    void Function(List<CachedPost>)? onRefreshed,
  }) async {
    try {
      final db = await _openDb();
      final rows = await db.query('cached_posts', orderBy: 'id ASC');
      final cached = rows
          .map(
            (row) =>
                CachedPostModel.fromPayload(row['payload'] as String? ?? '{}')
                    .toEntity(),
          )
          .toList();
      if (!forceOffline) {
        unawaited(
          _refreshInBackground()
              .then((fresh) => onRefreshed?.call(fresh))
              .catchError((Object _) {}),
        );
      }
      return (posts: cached, failure: null);
    } catch (_) {
      return (
        posts: const <CachedPost>[],
        failure: const LocalFailure('Gagal membaca cache lokal.'),
      );
    }
  }

  Future<List<CachedPost>> _refreshInBackground() async {
    final response = await _dio.get<List>('/posts');
    final posts = (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(CachedPostModel.fromJson)
        .toList();
    final db = await _openDb();
    await db.transaction((txn) async {
      await txn.delete('cached_posts');
      final batch = txn.batch();
      final cachedAt = DateTime.now().toIso8601String();
      for (final post in posts) {
        batch.insert('cached_posts', {
          'id': post.id,
          'payload': post.toPayload(),
          'cached_at': cachedAt,
        });
      }
      await batch.commit(noResult: true);
    });
    return posts.map((post) => post.toEntity()).toList();
  }
}
