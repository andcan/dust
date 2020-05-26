import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../dust.dart';

/// No value
@immutable
class None<T> extends Option<T> {
  /// Returns a new none
  const None();

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  bool get isNone => true;

  @override
  bool get isSome => false;

  @override
  bool operator ==(Object other) => identical(this, other) || other is None;

  @override
  Option<U> and<U>(Option<U> other) => None<U>();

  @override
  Option<U> andThen<U>(Option<U> Function(T value) f) => None<U>();

  @override
  bool contains(T value) => false;

  @override
  T expect(String message) => throw Panic(message);

  @override
  void expectNone(String message) {}

  @override
  Option<U> map<U>(U Function(T value) f) => None<U>();

  @override
  U mapOr<U>(U Function(T value) f, {@required U defaultValue}) => defaultValue;

  @override
  U mapOrElse<U>(U Function(T value) f, {U Function() orElse}) => orElse();

  @override
  U match<U>({
    @required U Function(T value) some,
    @required U Function() none,
  }) {
    assert(some != null, 'some must not be null');
    assert(none != null, 'none must not be null');
    return none();
  }

  @override
  Option<T> or(Option<T> other) => other;

  @override
  Option<T> orElse(Option<T> Function() f) => f();

  @override
  String toString() => 'None<$T>()';

  @override
  T unwrap() => throw Panic('cannot call unwrap on None');

  @override
  void unwrapNone() {}

  @override
  T unwrapOr(T value) => value;

  @override
  T unwrapOrElse(T Function() f) => f();

  @override
  Option<T> where(bool Function(T value) predicate) => this;

  @override
  Option<T> xor(Option<T> other) =>
      other.match(some: (_) => other, none: () => this);

  @override
  Result<T, E> okOr<E>(E error) => Err(error);

  @override
  Result<T, E> okOrElse<E>(E Function() f) => Err(f());
}

/// Represents an optional value.
///
/// Every [Option] is either [Some] and contains a value, or [None], and does
/// not.
@sealed
abstract class Option<T> {
  /// The constructor
  const Option();

  /// See [None]
  const factory Option.none() = None<T>;

  /// See [Some]
  const factory Option.some(T value) = Some<T>;

  /// Returns [true] if the option is a [None] value.
  bool get isNone;

  /// Returns [true] if the option is a [Some] value.
  bool get isSome;

  /// Provides a view of this option as an option of [R].
  ///
  /// If this option contains an instance of [R], all operations will work
  /// correctly. If any operation tries to access a value that is not an
  /// instance of [R], the access will throw instead.
  Option<R> cast<R>() => andThen((value) => Some<R>(value as R));

  /// Returns this.
  ///
  /// Avoids [OptionExtension] shadowing.
  // ignore: avoid_returning_this
  Option<T> get toOption => this;

  /// Returns [None]<[U]> if the option is [None], otherwise returns [other].
  Option<U> and<U>(Option<U> other);

  /// Returns [None]<[U]> if the option is [None].
  ///
  /// Otherwise calls [f] with the wrapped [value] and returns the result.
  Option<U> andThen<U>(Option<U> Function(T value) f);

  /// Returns [true] if the option is a [Some] value containing the given
  /// [value].
  bool contains(T value);

  /// Unwraps an option, yielding the content of a [Some].
  T expect(String message);

  /// Unwraps an option, expecting [None] and returning nothing.
  void expectNone(String message);

  /// Maps an [Option]<[T]> to [Option]<[U]> by applying [f] to [value].
  Option<U> map<U>(U Function(T value) f);

  /// Applies [f] to the contained value (if any).
  U mapOr<U>(U Function(T value) f, {@required U defaultValue});

  /// Applies a function to the contained [value] (if any).
  U mapOrElse<U>(U Function(T value) f, {@required U Function() orElse});

  /// Returns the result of [some] if this contains a [value].
  ///
  /// Otherwise returns the result of [none].
  U match<U>({
    @required U Function(T value) some,
    @required U Function() none,
  });

  /// Returns [this] if it contains a [value], otherwise returns [other].
  ///
  /// Arguments passed to or are eagerly evaluated; if you are passing the
  /// result of a function call, it is recommended to use [orElse], which is
  /// lazily evaluated.
  Option<T> or(Option<T> other);

  /// Returns the option if it contains a [value], otherwise calls [f] and
  /// returns the result.
  Option<T> orElse(Option<T> Function() f);

  /// Returns [value] if it is Some(v).
  ///
  /// In general, because this function may panic, its use is discouraged.
  /// Instead, prefer [match] and handle the [None] case explicitly.
  T unwrap();

  /// Unwraps an option, expecting [None] and returning nothing.
  ///
  /// Panics if the value is a [Some], with a custom panic message provided by
  /// the [Some]'s value.
  void unwrapNone();

  /// Returns the contained value or a default.
  ///
  /// Arguments passed are eagerly evaluated; if you are passing the result of a
  /// function call, it is recommended to use [unwrapOrElse], which is lazily
  /// evaluated.
  T unwrapOr(T value);

  /// Returns the contained value or returns the result of [f].
  T unwrapOrElse(T Function() f);

  /// Returns [None] if the option is [None].
  ///
  /// Otherwise calls predicate with the wrapped [value] and returns:
  /// * [Some]<[T]>([value]) if predicate returns [true]
  /// * [None]<[T]>() if predicate returns [false]
  ///
  /// This function works similar to [Iterable.where]. You can imagine the
  /// [Option]<[T]> being an iterator over one or zero elements.
  Option<T> where(bool Function(T value) predicate);

  /// Returns [Some] if exactly one of this, other is Some, otherwise returns
  /// [None].
  Option<T> xor(Option<T> other);

  /// Transforms the [Option]<[T]> into a [Result]<[T], [E]>.
  ///
  /// Maps [Some] to [Ok] and [None] to [Err].
  /// Arguments are eagerly evaluated; if you are passing the result of a
  /// function call, it is recommended to use [okOrElse], which is lazily
  /// evaluated.
  Result<T, E> okOr<E>(E error);

  /// Transforms the [Option]<T> into a [Result]<[T], [E]>.
  ///
  /// Maps [Some] to [Ok] and [None] to [Err].
  Result<T, E> okOrElse<E>(E Function() f);
}

/// Some value [T]
@immutable
class Some<T> extends Option<T> {
  /// The [value]
  final T value;

  /// Returns a new [Some] containing [value]
  const Some(this.value);

  @override
  int get hashCode => const DeepCollectionEquality().hash(value);

  @override
  bool get isNone => false;

  @override
  bool get isSome => true;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Some<T> &&
          runtimeType == other.runtimeType &&
          (identical(other.value, value) ||
              const DeepCollectionEquality().equals(other.value, value));

  @override
  Option<U> and<U>(Option<U> other) => other;

  @override
  Option<U> andThen<U>(Option<U> Function(T value) f) => f(value);

  @override
  bool contains(T value) => this.value == value;

  @override
  T expect(String message) => value;

  @override
  void expectNone(String message) => throw Panic(message);

  @override
  Option<U> map<U>(U Function(T value) f) => Some(f(value));

  @override
  U mapOr<U>(U Function(T value) f, {@required U defaultValue}) => f(value);

  @override
  U mapOrElse<U>(U Function(T value) f, {U Function() orElse}) => f(value);

  @override
  U match<U>({
    @required U Function(T value) some,
    @required U Function() none,
  }) {
    assert(some != null, 'some must not be null');
    assert(none != null, 'none must not be null');
    return some(value);
  }

  @override
  Option<T> or(Option<T> other) => this;

  @override
  Option<T> orElse(Option<T> Function() f) => this;

  @override
  String toString() => 'Some<$T>($value)';

  @override
  T unwrap() => value;

  @override
  void unwrapNone() => throw Panic('$value');

  @override
  T unwrapOr(T value) => this.value;

  @override
  T unwrapOrElse(T Function() f) => value;

  @override
  Option<T> where(bool Function(T value) predicate) =>
      predicate(value) ? this : None<T>();

  @override
  Option<T> xor(Option<T> other) =>
      other.match(some: (_) => None(), none: () => this);

  @override
  Result<T, E> okOr<E>(E error) => Ok(value);

  @override
  Result<T, E> okOrElse<E>(E Function() f) => Ok(value);
}

/// Extension for [Option]<[Option]<[T]>>
extension OptionOptionExtension<T> on Option<Option<T>> {
  /// Converts from [Option]<[Option]<[T]>> to [Option]<[T]>
  Option<T> flatten() => match(
        some: (value) => value,
        none: () => None<T>(),
      );
}

/// Extension for [Option]<[Result]<[T],[E]>>
extension OptionResultExtension<T, E> on Option<Result<T, E>> {
  /// Transposes an [Option] of a [Result] into a [Result] of an [Option].
  ///
  /// [None] will be mapped to [Ok] (None). [Some] ([Ok] (_)) and
  /// [Some] ([Err] (_)) will be mapped to [Ok] ([Some] (_)) and [Err] (_).
  Result<Option<T>, E> transpose() => match(
        some: (result) => result.match(
          ok: (value) => Ok(Some(value)),
          err: (error, stackTrace) => Err.withStackTrace(error, stackTrace),
        ),
        none: () => Ok(None()),
      );
}

/// [Object] extension for [Option].
extension OptionExtension<T> on T {
  /// Returns an [Option]<[T]> containing this.
  Option<T> get toOption => Some(this);
}
