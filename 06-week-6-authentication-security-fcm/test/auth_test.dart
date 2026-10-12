import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/data/auth_repository.dart';
import 'package:campus_notify/data/token_store.dart';
import 'package:campus_notify/providers/auth_provider.dart';

class FakeTokenStore extends TokenStore {
  String? access;
  String? refresh;

  @override
  Future<void> save({required String access, required String refresh}) async {
    this.access = access;
    this.refresh = refresh;
  }

  @override
  Future<String?> readAccess() async => access;

  @override
  Future<String?> readRefresh() async => refresh;

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

class FakeAuthRepository extends AuthRepository {
  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return const AuthSession(access: 'access-test', refresh: 'refresh-test');
  }
}

void main() {
  test('repository menolak email atau password yang tidak valid', () async {
    final repository = AuthRepository();
    await expectLater(
      repository.login(email: 'salah', password: '123'),
      throwsException,
    );
  });

  test('repository menghasilkan access dan refresh token mock', () async {
    final session = await AuthRepository().login(
      email: 'mahasiswa@kampus.ac.id',
      password: 'rahasia',
    );
    expect(session.access, contains('mahasiswa@kampus.ac.id'));
    expect(session.refresh, contains('mahasiswa@kampus.ac.id'));
  });

  test('provider login menyimpan token ke secure store', () async {
    final store = FakeTokenStore();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(store),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      ],
    );
    addTearDown(container.dispose);
    expect(await container.read(authStateProvider.future), isFalse);
    await container
        .read(authStateProvider.notifier)
        .login('mahasiswa@kampus.ac.id', 'rahasia');
    expect(container.read(authStateProvider).value, isTrue);
    expect(store.access, 'access-test');
    expect(store.refresh, 'refresh-test');
  });

  test('logout menghapus token dan mengubah status auth', () async {
    final store = FakeTokenStore()
      ..access = 'access-test'
      ..refresh = 'refresh-test';
    final container = ProviderContainer(
      overrides: [tokenStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
    expect(await container.read(authStateProvider.future), isTrue);
    await container.read(authStateProvider.notifier).logout();
    expect(container.read(authStateProvider).value, isFalse);
    expect(store.access, isNull);
    expect(store.refresh, isNull);
  });

  test('refresh token kosong ditolak', () async {
    await expectLater(AuthRepository().refresh(''), throwsException);
  });
}
