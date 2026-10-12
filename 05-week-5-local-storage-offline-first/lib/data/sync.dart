import 'dart:async';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import 'local/cached_post.dart';
import 'local/db.dart';
import 'repositories/note_repository.dart';

class SyncService {
  SyncService({Future<Database> Function()? openDb, Dio? dio})
    : _openDb = openDb ?? openNotesDb,
      _dio =
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

  Future<List<CachedPost>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    return rows
        .map((row) => CachedPost.fromPayload(row['payload'] as String? ?? '{}'))
        .toList();
  }

  Future<List<CachedPost>> loadPostsCacheFirst({
    required bool forceOffline,
    void Function(List<CachedPost>)? onRefreshed,
  }) async {
    final cached = await readCachedPosts();
    if (!forceOffline) {
      unawaited(
        refreshPostsInBackground()
            .then((fresh) => onRefreshed?.call(fresh))
            .catchError((Object _) {}),
      );
    }
    return cached;
  }

  Future<List<CachedPost>> refreshPostsInBackground() async {
    final response = await _dio.get<List>('/posts');
    final posts = (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(CachedPost.fromJson)
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
    return posts;
  }
}

Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  await Future<void>.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}
