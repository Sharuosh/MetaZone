import 'app_exception.dart';
import 'failure_type.dart';

/// Represents a failure that can safely be exposed to the UI.
final class Failure {
  const Failure({
    required this.message,
    this.type = FailureType.unknown,
    this.code,
    this.exception,
  });

  /// User-friendly message.
  final String message;

  /// Failure category.
  final FailureType type;

  /// Optional error code.
  final String? code;

  /// Original exception.
  final AppException? exception;

  factory Failure.fromException(AppException exception) {
    return Failure(
      message: exception.message,
      type: switch (exception) {
        NetworkException() => FailureType.network,
        ServerException() => FailureType.server,
        AuthenticationException() => FailureType.authentication,
        PermissionException() => FailureType.permission,
        StorageException() => FailureType.storage,
        ValidationException() => FailureType.validation,
        UnknownException() => FailureType.unknown,
        _ => FailureType.unknown,
      },
      code: exception.code,
      exception: exception,
    );
  }

  @override
  String toString() {
    return 'Failure(type: $type, message: $message, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return other is Failure &&
        other.message == message &&
        other.type == type &&
        other.code == code;
  }

  @override
  int get hashCode => Object.hash(message, type, code);
}