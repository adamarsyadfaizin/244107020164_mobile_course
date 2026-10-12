import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/providers/stats_provider.dart';

void main() {
  test('StatsNotifier menghasilkan tiga item saat sukses', () async {
    final container = ProviderContainer(
      overrides: [
        statsProvider.overrideWith(
          () => StatsNotifier(randomValue: () => 0.9, delay: Duration.zero),
        ),
      ],
    );
    addTearDown(container.dispose);
    expect(await container.read(statsProvider.future), hasLength(3));
  });

  test('StatsNotifier memodelkan kegagalan sebagai AsyncError', () async {
    final container = ProviderContainer(
      overrides: [
        statsProvider.overrideWith(
          () => StatsNotifier(randomValue: () => 0.1, delay: Duration.zero),
        ),
      ],
    );
    addTearDown(container.dispose);
    await expectLater(container.read(statsProvider.future), throwsException);
    expect(container.read(statsProvider), isA<AsyncError<List<String>>>());
  });
}
