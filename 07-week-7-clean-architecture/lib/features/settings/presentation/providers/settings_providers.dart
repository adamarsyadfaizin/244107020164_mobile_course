import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/prefs_repository_impl.dart';
import '../../domain/repositories/prefs_repository.dart';
import '../../domain/usecases/get_theme.dart';

final prefsRepositoryProvider = Provider<PrefsRepository>(
  (ref) => PrefsRepositoryImpl(),
);

final getThemeProvider = Provider<GetTheme>(
  (ref) => GetTheme(ref.watch(prefsRepositoryProvider)),
);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final result = await ref.watch(getThemeProvider).call();
    if (result.failure != null) throw result.failure!;
    return result.value;
  }

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    final failure = await ref.read(prefsRepositoryProvider).setDarkMode(next);
    state = failure == null
        ? AsyncData(next)
        : AsyncError(failure, StackTrace.current);
  }
}

final darkModeProvider = AsyncNotifierProvider<DarkModeNotifier, bool>(
  DarkModeNotifier.new,
);

final lastOpenedProvider = FutureProvider<String?>((ref) async {
  final repository = ref.watch(prefsRepositoryProvider);
  final previous = await repository.getLastOpened();
  if (previous.failure != null) throw previous.failure!;
  final failure = await repository.markOpenedNow();
  if (failure != null) throw failure;
  return previous.value;
});
