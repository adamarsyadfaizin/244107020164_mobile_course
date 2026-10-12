import 'package:dio/dio.dart';

import 'auth_repository.dart';
import 'token_store.dart';

Dio buildApiClient(
  TokenStore store,
  AuthRepository auth, {
  Future<void> Function()? onSessionExpired,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example-campus-api.test'));
  Future<void> endSession() async {
    await store.clear();
    await onSessionExpired?.call();
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.readAccess();
        if (access != null) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final alreadyRetried = error.requestOptions.extra['retried'] == true;
        if (error.response?.statusCode == 401 && alreadyRetried) {
          await endSession();
          return handler.next(error);
        }
        if (error.response?.statusCode == 401 && !alreadyRetried) {
          final refresh = await store.readRefresh();
          if (refresh == null || refresh.isEmpty) {
            await endSession();
            return handler.next(error);
          }
          try {
            final renewed = await auth.refresh(refresh);
            await store.save(access: renewed, refresh: refresh);
            error.requestOptions
              ..extra['retried'] = true
              ..headers['Authorization'] = 'Bearer $renewed';
            final retry = await dio.fetch<Object?>(error.requestOptions);
            return handler.resolve(retry);
          } catch (_) {
            await endSession();
          }
        }
        handler.next(error);
      },
    ),
  );
  return dio;
}
