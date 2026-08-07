/// Represents the category of a failure.
///
/// The UI should rely on this enum instead of checking
/// error messages.
enum FailureType {
  /// Unknown or unexpected error.
  unknown,

  /// No internet connection.
  network,

  /// Server returned an error.
  server,

  /// Authentication or login failure.
  authentication,

  /// Permission denied.
  permission,

  /// Local storage/database failure.
  storage,

  /// Invalid user input.
  validation,

  /// Request timed out.
  timeout,

  /// Resource was not found.
  notFound,

  /// Request was cancelled.
  cancelled,

  /// Rate limit exceeded.
  rateLimited,
}