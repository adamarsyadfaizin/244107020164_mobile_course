import 'dart:typed_data';

import 'package:campus_notify/data/api_client.dart';
import 'package:campus_notify/data/api_errors.dart';
import 'package:campus_notify/data/auth_repository.dart';
import 'package:campus_notify/data/token_store.dart';
import 'package:campus_notify/routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/providers/auth_provider.dart';
import 'package:campus_notify/router.dart';

class FakeTokenStore extends TokenStore {
  String? access = 'expired-access';
  String? refresh = 'valid-refresh';

  @override
  Future<String?> readAccess() async => access;

  @override
  Future<String?> readRefresh() async => refresh;

  @override
  Future<void> save({required String access, required String refresh}) async {
    this.access = access;
    this.refresh = refresh;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository({this.failRefresh = false});
  final bool failRefresh;
  int refreshCount = 0;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async => const AuthSession(access: 'mock-access', refresh: 'mock-refresh');

  @override
  Future<String> refresh(String refreshToken) async {
    refreshCount++;
    if (failRefresh) throw Exception('refresh gagal');
    return 'renewed-access';
  }
}

class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter({this.alwaysUnauthorized = false});
  final bool alwaysUnauthorized;
  int requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    final unauthorized = alwaysUnauthorized || requestCount == 1;
    return ResponseBody.fromString(
      unauthorized ? '{"error":"unauthorized"}' : '{"ok":true}',
      unauthorized ? 401 : 200,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('route payload kosong dan tanpa slash ditangani', () {
    expect(routeFromMessage({}), AppRoutes.home);
    expect(routeFromMessage({'route': ''}), AppRoutes.home);
    expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
    expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
  });

  test('payload membawa id pengumuman', () {
    const data = {'route': '/pengumuman/3', 'id': '3'};
    expect(data['id'], '3');
    expect(routeFromMessage(data), AppRoutes.announcement('3'));
  });

  test('pesan error ramah pengguna untuk 401, timeout, dan offline', () {
    final options = RequestOptions(path: '/private');
    expect(
      friendlyApiErrorMessage(
        DioException(
          requestOptions: options,
          response: Response(requestOptions: options, statusCode: 401),
        ),
      ),
      contains('login'),
    );
    expect(
      friendlyApiErrorMessage(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        ),
      ),
      contains('lama'),
    );
    expect(
      friendlyApiErrorMessage(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        ),
      ),
      contains('terhubung'),
    );
  });

  test('401 me-refresh token dan mengulang request sekali', () async {
    final store = FakeTokenStore();
    final auth = FakeAuthRepository();
    final adapter = FakeHttpAdapter();
    var expired = 0;
    final dio = buildApiClient(
      store,
      auth,
      onSessionExpired: () async => expired++,
    )..httpClientAdapter = adapter;
    addTearDown(dio.close);

    final response = await dio.get<Map<String, dynamic>>('/private');
    expect(response.data?['ok'], isTrue);
    expect(store.access, 'renewed-access');
    expect(auth.refreshCount, 1);
    expect(adapter.requestCount, 2);
    expect(expired, 0);
  });

  test('refresh gagal membersihkan sesi tanpa retry berulang', () async {
    final store = FakeTokenStore();
    final auth = FakeAuthRepository(failRefresh: true);
    final adapter = FakeHttpAdapter(alwaysUnauthorized: true);
    var expired = 0;
    final dio = buildApiClient(
      store,
      auth,
      onSessionExpired: () async => expired++,
    )..httpClientAdapter = adapter;
    addTearDown(dio.close);

    await expectLater(
      dio.get<Object?>('/private'),
      throwsA(isA<DioException>()),
    );
    expect(store.access, isNull);
    expect(store.refresh, isNull);
    expect(auth.refreshCount, 1);
    expect(adapter.requestCount, 1);
    expect(expired, 1);
  });

  testWidgets('tujuan notifikasi menunggu login lalu membuka pengumuman', (
    tester,
  ) async {
    final store = FakeTokenStore()
      ..access = null
      ..refresh = null;
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(store),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await container.read(authStateProvider.future);
    router.go(AppRoutes.announcement('3'));
    await tester.pumpAndSettle();
    expect(find.text('Login Campus Notify'), findsOneWidget);

    await container
        .read(authStateProvider.notifier)
        .login('a@b.com', 'rahasia');
    await tester.pumpAndSettle();
    expect(find.text('Pengumuman 3'), findsOneWidget);
  });
}
