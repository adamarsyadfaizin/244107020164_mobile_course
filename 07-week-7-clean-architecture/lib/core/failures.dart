sealed class Failure {
  const Failure(this.message);
  final String message;
}

class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

String failureMessage(Object error) =>
    error is Failure ? error.message : 'Terjadi kesalahan.';
