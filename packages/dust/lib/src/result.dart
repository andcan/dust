import 'dart:async';

import 'package:dust/dust.dart';
import 'package:meta/meta.dart';

/// Contains the error value.
@immutable
class Err<T, E> implements Result<T, E> {
  /// The error.
  final E error;

  /// The stack trace.
  final StackTrace stackTrace;

  /// Returns Err with [error] and [StackTrace.current]
  factory Err(E error) => Err.withStackTrace(error, StackTrace.current);

  /// Returns Err with [error] and [stackTrace].
  const Err.withStackTrace(this.error, this.stackTrace);

  @override
  int get hashCode => error.hashCode;

  @override
  bool get isErr => true;

  @override
  bool get isOk => false;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Err && error == other.error;

  @override
  Result<U, E> and<U>(Result<U, E> result) =>
      Err<U, E>.withStackTrace(error, stackTrace);

  @override
  Result<U, E> andThen<U, F>(Result<U, E> Function(T value) then) =>
      Err<U, E>.withStackTrace(error, stackTrace);

  @override
  bool contains(T value) => false;

  @override
  bool containsError(E error, [StackTrace stackTrace]) {
    final contains = error == this.error;
    if (stackTrace != null) {
      return contains && stackTrace == this.stackTrace;
    }
    return contains;
  }

  @override
  Option<ErrorAndStackTrace<E>> err() =>
      Some(ErrorAndStackTrace(error, stackTrace));

  @override
  T expect(String message) => throw Panic('$message: $error');

  @override
  ErrorAndStackTrace<E> expectError(String message) =>
      ErrorAndStackTrace(error, stackTrace);

  @override
  Result<U, E> map<U>(U Function(T result) map) =>
      Err.withStackTrace(error, stackTrace);

  @override
  Result<T, F> mapError<F>(F Function(E error, StackTrace stackTrace) map) =>
      Err.withStackTrace(map(error, stackTrace), stackTrace);

  @override
  U mapOr<U>(U Function(T result) f, {U defaultValue}) => defaultValue;

  @override
  U mapOrElse<U>(
    U Function(T result) f, {
    @required U Function(E error, StackTrace stackTrace) orElse,
  }) =>
      orElse(error, stackTrace);

  @override
  U match<U>({
    @required U Function(T value) ok,
    @required U Function(E error, StackTrace stackTrace) err,
  }) =>
      err(error, stackTrace);

  @override
  Option<T> ok() => None<T>();

  @override
  Result<T, F> or<F>(Result<T, F> other) => other;

  @override
  Result<T, F> orElse<F>(
    Result<T, F> Function(E error, StackTrace stackTrace) orElse,
  ) =>
      orElse(error, stackTrace);

  @override
  String toString() => 'Err<$T,$E>($error)';

  @override
  T unwrap() => throw Panic('called unwrap on an Err: $error');
}

/// Contains the success value.
@immutable
class Ok<T, E> implements Result<T, E> {
  /// The value
  final T value;

  /// Returns [Ok] with [value].
  const Ok(this.value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool get isErr => false;

  @override
  bool get isOk => true;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Ok && value == other.value;

  @override
  Result<U, E> and<U>(Result<U, E> result) => result;

  @override
  Result<U, E> andThen<U, F>(Result<U, E> Function(T value) then) =>
      then(value);

  @override
  bool contains(T value) => value == this.value;

  @override
  bool containsError(E error, [StackTrace stackTrace]) => false;

  @override
  Option<ErrorAndStackTrace<E>> err() => None<ErrorAndStackTrace<E>>();

  @override
  T expect(String message) => value;

  @override
  ErrorAndStackTrace<E> expectError(String message) =>
      throw Panic('$message: $value');

  @override
  Result<U, E> map<U>(U Function(T result) f) => Ok(f(value));

  @override
  Result<T, F> mapError<F>(F Function(E error, StackTrace stackTrace) f) =>
      Ok(value);

  @override
  U mapOr<U>(U Function(T result) f, {@required U defaultValue}) => f(value);

  @override
  U mapOrElse<U>(
    U Function(T result) f, {
    @required U Function(E error, StackTrace stackTrace) orElse,
  }) =>
      f(value);

  @override
  U match<U>({
    @required U Function(T value) ok,
    @required U Function(E error, StackTrace stackTrace) err,
  }) =>
      ok(value);

  @override
  Option<T> ok() => Some(value);

  @override
  Result<T, F> or<F>(Result<T, F> other) => Ok(value);

  @override
  Result<T, F> orElse<F>(
    Result<T, F> Function(E error, StackTrace stackTrace) orElse,
  ) =>
      Ok(value);

  @override
  String toString() => 'Ok<$T,$E>($value)';

  @override
  T unwrap() => value;
}

/// [Result] is a type that represents either success ([Ok]<[T], [E]>)
/// or failure ([Err]<[T], [E]).
@sealed
abstract class Result<T, E> {
  /// Executes [computation] returning an [Ok] or [Err] if it throws.
  factory Result(T Function() computation) {
    try {
      return Ok(computation());
    } on E catch (e, st) {
      return Err<T, E>.withStackTrace(e, st);
    }
  }

  /// Returns true if the result is an [Err].
  bool get isErr;

  /// Returns true if the result is a [Ok].
  bool get isOk;

  /// Returns [result] if this is [Ok]
  ///
  /// Otherwise returns the error of this
  Result<U, E> and<U>(Result<U, E> result);

  /// Calls [then] if the result is [Ok].
  ///
  /// Otherwise returns the error of this.
  Result<U, E> andThen<U, F>(Result<U, E> Function(T value) then);

  /// Returns true if the result is a [Ok] containing the given
  /// [value].
  bool contains(T value);

  /// Returns true if the result is an [Err] containing the given error.
  bool containsError(E error, [StackTrace stackTrace]);

  /// Converts from [Result]<[T], [E]> to [Option]<[ErrorAndStackTrace]<[E]>>.
  ///
  /// Converts this into an [Option]<[ErrorAndStackTrace]<[E]>>, and discarding
  /// the value, if any.
  Option<ErrorAndStackTrace<E>> err();

  /// Unwraps a result, yielding the content of an [Ok].
  ///
  /// Panics if the value is an [Err], with a panic message including the passed
  /// [message], and the content of the [Err].
  T expect(String message);

  /// Unwraps a result, yielding the content of an [Err].
  ///
  /// Panics if the value is an [Ok], with a panic message including the passed
  /// [message], and the content of the [Ok].
  ErrorAndStackTrace<E> expectError(String message);

  /// Maps a [Result]<[T], [E]> to [Result]<[U], [E]> by applying [f] to an
  /// [Ok], leaving an [Err] untouched.
  Result<U, E> map<U>(U Function(T result) f);

  /// Maps a [Result]<[T], [E]> to [Result]<[T], [F]> by applying [f] to an
  /// [Err], leaving a [Ok] untouched.
  Result<T, F> mapError<F>(F Function(E error, StackTrace stackTrace) f);

  /// Applies [f] to the contained value (if any), or returns the
  /// provided [defaultValue] (if not).
  U mapOr<U>(U Function(T result) f, {@required U defaultValue});

  /// Maps a [Result]<[T], [E]> to [U] by applying f to an [Ok].
  ///
  /// Or a fallback function to a contained [Err] value. This function can be
  /// used to unpack a successful result while handling an error.
  U mapOrElse<U>(
    U Function(T result) f, {
    @required U Function(E error, StackTrace stackTrace) orElse,
  });

  /// Returns the result of [ok] if this contains a [value].
  ///
  /// Otherwise returns the result of [err].
  U match<U>({
    @required U Function(T value) ok,
    @required U Function(E error, StackTrace stackTrace) err,
  });

  /// Converts from [Result]<[T], [E]> to [Option]<[T]>.
  ///
  /// Converts this into an [Option]<[T]>, and discarding the error, if any.
  Option<T> ok();

  /// Returns [other] if the result is [Err], otherwise returns this.
  ///
  /// Arguments are eagerly evaluated; if you are passing the result of a
  /// function call, it is recommended to use [orElse], which is lazily
  /// evaluated.
  Result<T, F> or<F>(Result<T, F> other);

  /// Calls [orElse] if the result is [Err].
  ///
  /// Otherwise returns the [Ok] value. This function can be used for control
  /// flow based on result values.
  Result<T, F> orElse<F>(
    Result<T, F> Function(E error, StackTrace stackTrace) orElse,
  );

  /// Returns the contained [Ok] value.
  /// Because this function may panic, its use is generally discouraged.
  /// Instead, prefer to use [match] and handle the [Err] case explicitly, or
  /// call [unwrapOr], [unwrapOrElse], or [unwrapOrDefault].
  T unwrap();
}

/// Used by [ResultStreamExtension.capture].
class _CaptureResultSink<T, E> implements EventSink<T> {
  final EventSink<Result<T, E>> _sink;

  _CaptureResultSink(EventSink<Result<T, E>> sink) : _sink = sink;

  @override
  void add(T value) => _sink.add(Ok<T, E>(value));

  @override
  void addError(Object error, [StackTrace stackTrace]) =>
      _sink.add(Err<T, E>.withStackTrace(error as E, stackTrace));

  @override
  void close() => _sink.close();
}

class _CaptureResultStreamTransformer<T, E>
    extends StreamTransformerBase<T, Result<T, E>> {
  const _CaptureResultStreamTransformer();

  @override
  Stream<Result<T, E>> bind(Stream<T> source) =>
      Stream<Result<T, E>>.eventTransformed(
          source, (sink) => _CaptureResultSink<T, E>(sink));
}

/// [Object] extension for [Result].
extension ResultExtension<T, E> on T {
  /// Returns a [Result]<[T], [E]> containing this.
  Result<T, E> get toResult => Ok(this);
}

/// [Future] extension for [Result].
extension ResultFutureExtension<T, E> on Future<T> {
  /// Transforms this into a [Result]<[T], [E]>.
  ///
  /// Returns [Ok] if this completes with a value, otherwise returns [Err].
  Future<Result<T, E>> capture() => then(
        (value) => Ok<T, E>(value),
        onError: (E error, StackTrace stackTrace) =>
            Err<T, E>.withStackTrace(error, stackTrace),
      );
}

extension ResultStreamExtension<T, E> on Stream<T> {
  /// Captures the results of a stream into a stream of [Result]<[T], [E]> values.
  ///
  /// The returned stream will not have any error events.
  /// Errors from the source stream have been converted to [Err]s.
  Stream<Result<T, E>> capture() =>
      transform(_CaptureResultStreamTransformer<T, E>());
}
