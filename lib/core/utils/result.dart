/// Generic Result type for repository-layer error handling.
///
/// Every repository method returns `Result<T>` instead of throwing exceptions.
/// Callers pattern-match on [Success] / [Failure] to handle both cases
/// explicitly, eliminating unhandled exceptions in the UI layer.
///
/// Example:
/// ```dart
/// final result = await customerRepository.getCustomer(id);
/// switch (result) {
///   case Success(:final data):
///     state = CustomerLoaded(data);
///   case Failure(:final message):
///     state = CustomerError(message);
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Returns `true` if this is a [Success].
  bool get isSuccess => this is Success<T>;

  /// Returns `true` if this is a [Failure].
  bool get isFailure => this is Failure<T>;

  /// Extracts the data if [Success], otherwise returns `null`.
  T? get dataOrNull => switch (this) {
        Success(:final data) => data,
        Failure() => null,
      };

  /// Extracts the error message if [Failure], otherwise returns `null`.
  String? get errorOrNull => switch (this) {
        Success() => null,
        Failure(:final message) => message,
      };

  /// Transforms the success data using [transform], passing failures through.
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
        Success(:final data) => Success(transform(data)),
        Failure(:final message, :final statusCode) =>
          Failure(message, statusCode: statusCode),
      };

  /// Chains an async operation on the success data.
  Future<Result<R>> flatMap<R>(
    Future<Result<R>> Function(T data) transform,
  ) async =>
      switch (this) {
        Success(:final data) => await transform(data),
        Failure(:final message, :final statusCode) =>
          Failure(message, statusCode: statusCode),
      };

  /// Executes [onSuccess] or [onFailure] depending on the result type.
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode) failure,
  }) =>
      switch (this) {
        Success(:final data) => success(data),
        Failure(:final message, :final statusCode) =>
          failure(message, statusCode),
      };
}

/// Represents a successful result containing [data].
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> && runtimeType == other.runtimeType && data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success($data)';
}

/// Represents a failed result containing an error [message] and optional
/// HTTP [statusCode].
class Failure<T> extends Result<T> {
  final String message;
  final int? statusCode;
  const Failure(this.message, {this.statusCode});

  /// Returns `true` if the failure was caused by an authentication error (401).
  bool get isAuthError => statusCode == 401;

  /// Returns `true` if the failure was caused by a network/timeout error.
  bool get isNetworkError => statusCode == null || statusCode == 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          statusCode == other.statusCode;

  @override
  int get hashCode => Object.hash(message, statusCode);

  @override
  String toString() => 'Failure($message, statusCode: $statusCode)';
}
