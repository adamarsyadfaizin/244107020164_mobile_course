import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/failures.dart';
import '../../domain/repositories/prefs_repository.dart';

class PrefsRepositoryImpl implements PrefsRepository {
  static const _darkModeKey = 'dark_mode';
  static const _lastOpenedKey = 'last_opened_at';

  @override
  Future<({bool value, Failure? failure})> getDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (value: prefs.getBool(_darkModeKey) ?? false, failure: null);
    } catch (_) {
      return (value: false, failure: const LocalFailure('Gagal membaca tema.'));
    }
  }

  @override
  Future<Failure?> setDarkMode(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, value);
      return null;
    } catch (_) {
      return const LocalFailure('Gagal menyimpan tema.');
    }
  }

  @override
  Future<({String? value, Failure? failure})> getLastOpened() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (value: prefs.getString(_lastOpenedKey), failure: null);
    } catch (_) {
      return (
        value: null,
        failure: const LocalFailure('Gagal membaca waktu terakhir.'),
      );
    }
  }

  @override
  Future<Failure?> markOpenedNow() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastOpenedKey, DateTime.now().toIso8601String());
      return null;
    } catch (_) {
      return const LocalFailure('Gagal menyimpan waktu terakhir.');
    }
  }
}
