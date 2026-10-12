import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/app_providers.dart';
import 'package:week5_offline_notes/core/failures.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';
import 'package:week5_offline_notes/features/notes/presentation/pages/notes_page.dart';
import 'package:week5_offline_notes/features/notes/presentation/providers/notes_providers.dart';
import 'package:week5_offline_notes/features/posts/domain/entities/cached_post.dart';
import 'package:week5_offline_notes/features/posts/domain/repositories/post_repository.dart';
import 'package:week5_offline_notes/features/posts/presentation/pages/cached_posts_page.dart';
import 'package:week5_offline_notes/features/posts/presentation/providers/posts_providers.dart';
import 'package:week5_offline_notes/features/settings/domain/repositories/prefs_repository.dart';
import 'package:week5_offline_notes/features/settings/presentation/pages/settings_page.dart';
import 'package:week5_offline_notes/features/settings/presentation/providers/settings_providers.dart';

import 'fakes/fake_note_repository.dart';

class _Posts implements PostRepository {
  @override
  Future<({List<CachedPost> posts, Failure? failure})> loadCacheFirst({
    required bool forceOffline,
    void Function(List<CachedPost>)? onRefreshed,
  }) async => (
    posts: const [
      CachedPost(
        id: 1,
        title: 'Cache tersimpan di SQLite',
        body: 'Data bacaan tetap muncul saat forceOffline aktif.',
      ),
      CachedPost(
        id: 2,
        title: 'Cache-first read',
        body: 'Cache lokal ditampilkan sebelum refresh jaringan.',
      ),
      CachedPost(
        id: 3,
        title: 'Offline-first',
        body: 'Baca dan tulis tidak bergantung pada koneksi.',
      ),
    ],
    failure: null,
  );
}

class _Prefs implements PrefsRepository {
  @override
  Future<({bool value, Failure? failure})> getDarkMode() async =>
      (value: false, failure: null);
  @override
  Future<({String? value, Failure? failure})> getLastOpened() async =>
      (value: '2026-09-27T10:00:00', failure: null);
  @override
  Future<Failure?> markOpenedNow() async => null;
  @override
  Future<Failure?> setDarkMode(bool value) async => null;
}

class _Offline extends ForceOfflineNotifier {
  @override
  bool build() => true;
}

void main() {
  setUpAll(_loadFonts);
  for (final (name, page) in <(String, Widget)>[
    ('notes', const NotesPage()),
    ('posts', const CachedPostsPage()),
    ('settings', const SettingsPage()),
  ]) {
    testWidgets('after $name pada layar ponsel', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            noteRepositoryProvider.overrideWithValue(
              FakeNoteRepository(
                items: [
                  Note(
                    id: 1,
                    title: 'Belanja mingguan',
                    body: 'Beras, sayur, dan susu',
                    updatedAt: DateTime(2026, 9, 27),
                    dirty: true,
                  ),
                  Note(
                    id: 2,
                    title: 'Tugas mobile',
                    body: 'Selesaikan praktikum Week 5',
                    updatedAt: DateTime(2026, 9, 26),
                    dirty: true,
                  ),
                  Note(
                    id: 3,
                    title: 'Ide proyek',
                    body: 'Aplikasi catatan offline-first',
                    updatedAt: DateTime(2026, 9, 25),
                    dirty: true,
                  ),
                ],
              ),
            ),
            postRepositoryProvider.overrideWithValue(_Posts()),
            prefsRepositoryProvider.overrideWithValue(_Prefs()),
            forceOfflineProvider.overrideWith(_Offline.new),
          ],
          child: MaterialApp(home: page),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(page.runtimeType),
        matchesGoldenFile('goldens/week7-after-$name.png'),
      );
    });
  }
}

Future<void> _loadFonts() async {
  for (final (family, fileName) in [
    ('Roboto', 'Roboto-Regular.ttf'),
    ('MaterialIcons', 'MaterialIcons-Regular.otf'),
  ]) {
    final bytes = await File('test/fonts/$fileName').readAsBytes();
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
  }
}
