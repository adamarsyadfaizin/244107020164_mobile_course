import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/network_errors.dart';
import 'package:week4_api/data/paged_posts.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/post_repository.dart';
import 'package:week4_api/pages/paged_post_page.dart';

class FakePostRepository extends PostRepository {
  FakePostRepository({this.items, this.throwError = false}) : super(Dio());
  final List<Post>? items;
  final bool throwError;

  @override
  Future<List<Post>> fetchPosts() async {
    if (throwError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );
    }
    return items ?? const [];
  }

  @override
  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) {
    return fetchPosts();
  }
}

class CountingPostRepository extends PostRepository {
  CountingPostRepository() : super(Dio());

  final nextPage = Completer<List<Post>>();
  int pageTwoCalls = 0;

  @override
  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) {
    if (page == 1) {
      return Future.value(
        List.generate(
          10,
          (index) => Post(userId: 1, id: index + 1, title: 'Post', body: ''),
        ),
      );
    }
    pageTwoCalls++;
    return nextPage.future;
  }
}

void main() {
  test('fromJson aman terhadap field yang hilang', () {
    final post = Post.fromJson({'id': 7});
    expect(post.id, 7);
    expect(post.title, '');
    expect(post.userId, 0);
  });

  test('friendlyErrorMessage untuk connection error', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/posts'),
      type: DioExceptionType.connectionError,
    );
    expect(friendlyErrorMessage(error), contains('terhubung'));
  });

  test('provider sukses dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        postRepositoryProvider.overrideWithValue(
          FakePostRepository(
            items: const [Post(userId: 1, id: 1, title: 'Tes', body: 'Isi')],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    final posts = await readPostsOnce(container);
    expect(posts.length, 1);
    expect(posts.first.title, 'Tes');
  });

  test('provider error dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        postRepositoryProvider.overrideWithValue(
          FakePostRepository(throwError: true),
        ),
      ],
    );
    addTearDown(container.dispose);
    final error = await readPostsErrorOnce(container);
    expect(error, isA<DioException>());
    expect(friendlyErrorMessage(error!), contains('terhubung'));
  });

  testWidgets('halaman menampilkan empty saat API tidak memberi post', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWithValue(FakePostRepository()),
        ],
        child: const MaterialApp(home: PagedPostPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Belum ada data dari server.'), findsOneWidget);
  });

  test('pagination tidak mengirim request halaman sama dua kali', () async {
    final repository = CountingPostRepository();
    final container = ProviderContainer(
      overrides: [postRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final firstPageReady = Completer<void>();
    final subscription = container.listen(pagedPostsProvider, (previous, next) {
      if (next.page == 1 && !firstPageReady.isCompleted) {
        firstPageReady.complete();
      }
    }, fireImmediately: true);
    addTearDown(subscription.close);
    await firstPageReady.future;

    final notifier = container.read(pagedPostsProvider.notifier);
    final first = notifier.loadNextPage();
    final duplicate = notifier.loadNextPage();
    expect(repository.pageTwoCalls, 1);
    repository.nextPage.complete(const []);
    await Future.wait([first, duplicate]);
    expect(container.read(pagedPostsProvider).page, 2);
  });
}
