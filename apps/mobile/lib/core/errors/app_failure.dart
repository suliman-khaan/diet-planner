/// Typed failures that cross layer boundaries. Screens show friendly text for each kind and
/// never the raw exception.
sealed class AppFailure implements Exception {
  const AppFailure(this.debugMessage);

  /// For logs only. Must not contain personal or health data.
  final String debugMessage;

  @override
  String toString() => '$runtimeType: $debugMessage';
}

/// The local database or a stored record could not be read. Never silently reset;
/// the user is shown a recovery screen.
class StorageCorrupted extends AppFailure {
  const StorageCorrupted(super.debugMessage);
}

class StorageFailure extends AppFailure {
  const StorageFailure(super.debugMessage);
}

/// The bundled or downloaded food pack failed validation.
class InvalidFoodPack extends AppFailure {
  const InvalidFoodPack(super.debugMessage);
}

/// An imported backup file is not valid. Nothing was changed.
class InvalidImportFile extends AppFailure {
  const InvalidImportFile(super.debugMessage);
}

class PlatformServiceFailure extends AppFailure {
  const PlatformServiceFailure(super.debugMessage);
}

/// Result type for operations whose failure the UI must handle explicitly.
sealed class Result<T> {
  const Result();

  R when<R>(
          {required R Function(T value) ok,
          required R Function(AppFailure failure) err}) =>
      switch (this) {
        Ok<T>(:final value) => ok(value),
        Err<T>(:final failure) => err(failure),
      };
}

class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

class Err<T> extends Result<T> {
  const Err(this.failure);
  final AppFailure failure;
}
