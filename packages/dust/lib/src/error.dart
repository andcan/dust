import 'package:meta/meta.dart';

/// Represents an unexpected state.
class Panic extends Error {
  /// The error message.
  final String message;

  /// Returns [Panic] with message.
  Panic(dynamic message) : message = message.toString();
}

/// An Object which acts as a tuple containing both an error and the
/// corresponding stack trace.
@immutable
class ErrorAndStackTrace<E> {
  /// The error.
  final E error;

  /// The stack trace.
  final StackTrace stackTrace;

  /// Creates an [ErrorAndStackTrace] containing both [error] and the
  /// corresponding [stackTrace].
  const ErrorAndStackTrace(this.error, this.stackTrace);

  /// Creates an [ErrorAndStackTrace] containing both [error] and
  /// [StackTrace.current].
  ErrorAndStackTrace.current(this.error) : stackTrace = StackTrace.current;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorAndStackTrace &&
          runtimeType == other.runtimeType &&
          error == other.error &&
          stackTrace == other.stackTrace;

  @override
  int get hashCode => error.hashCode ^ stackTrace.hashCode;
}
