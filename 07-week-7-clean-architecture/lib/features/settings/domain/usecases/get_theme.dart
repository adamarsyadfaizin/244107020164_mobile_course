import '../../../../core/failures.dart';
import '../repositories/prefs_repository.dart';

class GetTheme {
  const GetTheme(this._repository);
  final PrefsRepository _repository;

  Future<({bool value, Failure? failure})> call() => _repository.getDarkMode();
}
