import '../../../../core/failures.dart';

abstract class PrefsRepository {
  Future<({bool value, Failure? failure})> getDarkMode();
  Future<Failure?> setDarkMode(bool value);
  Future<({String? value, Failure? failure})> getLastOpened();
  Future<Failure?> markOpenedNow();
}
