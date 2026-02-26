// Base failure class — all errors in the app extend this
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

// ── Specific Failure Types ─────────────────────────────────

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please check your network.']);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({String message = 'A server error occurred.', this.statusCode}) : super(message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'The requested resource was not found.']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Session expired. Please log in again.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to load cached data.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}

// 👇 Added this specific failure for Firebase Authentication
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}