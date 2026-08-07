/// Base exception for the entire application.
///
/// Every custom exception should extend this class.
sealed class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.cause,
    this.stackTrace,
  });

  /// Human-readable error message.
  final String message;

  /// Optional error code from APIs or services.
  final String? code;

  /// Original exception.
  final Object? cause;

  /// Original stack trace.
  final StackTrace? stackTrace;

  @override
  String toString() {
    return '$runtimeType(message: $message, code: $code)';
  }
}

/// Internet connection problems.
final class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection.',
    super.code,
    super.cause,
    super.stackTrace,
  });
}

/// API / Server errors.
final class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.cause,
    super.stackTrace,
  });
}

/// Authentication errors.
final class AuthenticationException extends AppException {
  const AuthenticationException({
    required super.message,
    super.code,
    super.cause,
    super.stackTrace,
  });
}

/// Permission denied.
final class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
    super.cause,
    super.stackTrace,
  });
}

/// Local database / storage errors.
final class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.cause,
    super.stackTrace,
  });
}

/// Validation errors.
final class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.cause,
    super.stackTrace,
  });
}

/// Unexpected application errors.
final class UnknownException extends AppException {
  const UnknownException({
    super.message = 'Unknown error occurred.',
    super.code,
    super.cause,
    super.stackTrace,
  });
}