import '../errors/failure.dart';

/// Represents the result of an operation.
///
/// Every repository and service in the project should return
/// either a [Success] or a [FailureResult].
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  bool get isFailure => this is FailureResult<T>;

  T? get data => switch (this) {
    Success<T>(:final data) => data,
    FailureResult<T>() => null,
  };

  Failure? get failure => switch (this) {
    Success<T>() => null,
    FailureResult<T>(:final failure) => failure,
  };

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    return switch (this) {
      Success<T>(:final data) => success(data),
      FailureResult<T>(failure: final error) => failure(error),
    };
  }
}

/// Successful operation.
final class Success<T> extends Result<T> {
  const Success(this.data);

  @override
  final T data;
}

/// Failed operation.
final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  @override
  final Failure failure;
}