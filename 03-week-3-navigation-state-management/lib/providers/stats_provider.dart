import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsNotifier extends AsyncNotifier<List<String>> {
  StatsNotifier({
    double Function()? randomValue,
    this.delay = const Duration(seconds: 2),
  }) : _randomValue = randomValue ?? Random().nextDouble,
       assert(!delay.isNegative);

  final double Function() _randomValue;
  final Duration delay;

  @override
  Future<List<String>> build() => _fetchStats();

  Future<List<String>> _fetchStats() async {
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
    if (_randomValue() < 0.3) {
      throw Exception('Gagal mengambil data statistik');
    }
    return const [
      'Total tugas: 10',
      'Tugas selesai: 7',
      'Tugas belum selesai: 3',
    ];
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchStats);
  }
}

final AsyncNotifierProvider<StatsNotifier, List<String>> statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<String>>(
      StatsNotifier.new,
      retry: (retryCount, error) => null,
    );
