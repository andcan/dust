import 'package:test/test.dart';

// ignore: avoid_relative_lib_imports
import '../lib/dust.dart';
import 'shared.dart';

void main() {
  group('create', () {
    test('some', () {
      final opt = Option.some(42);
      expect(opt is Some<int>, isTrue);
      expect(opt.isSome, isTrue);
      expect(opt.isNone, isFalse);
      expect((opt as Some).value, equals(42));

      final opt1 = Some(42);
      expect(opt1.value, equals(42));
    });

    test('none', () {
      final opt = Option<int>.none();
      expect(opt.isSome, isFalse);
      expect(opt.isNone, isTrue);
      expect(opt is None<int>, isTrue);
    });
  });

  group('equals', () {
    group('some', () {
      testEquality('with none',
          a: Some(42), a1: Some(42), a2: Some(42), b: None());
      testEquality('with some',
          a: Some(42), a1: Some(42), a2: Some(42), b: Some(8));
    });
    group('none', () {
      testEquality('with some',
          a: None<int>(), a1: None<int>(), a2: None<int>(), b: Some(42));
      testEquality('with none',
          a: None<int>(), a1: None<int>(), a2: None<int>(), b: None<bool>());
    });
  });

  test('and', () {
    expect(None<int>().and(Some(false)), equals(None<bool>()));
    expect(Some(42).and(None<bool>()), equals(None<bool>()));
    expect(Some(42).and(Some(43)), equals(Some(43)));
    expect(None<int>().and(None<bool>()), equals(None<bool>()));
  });

  test('and then', () {
    // ignore: avoid_types_on_closure_parameters
    plusOne(int value) => Some(value + 1);
    // ignore: avoid_types_on_closure_parameters
    err(int value) => None<int>();
    expect(Some(42).andThen(plusOne), equals(Some(43)));
    expect(Some(42).andThen(plusOne).andThen(plusOne), equals(Some(44)));
    expect(Some(42).andThen(err).andThen(plusOne), equals(None()));
    expect(None<int>().andThen(plusOne).andThen(plusOne), equals(None()));
    expect(None<int>().andThen(plusOne).andThen(plusOne), equals(None()));
  });

  test('contains', () {
    expect(Some(42).contains(42), isTrue);
    expect(Some(42).contains(8), isFalse);
    expect(None<int>().contains(42), isFalse);
    expect(None<bool>().contains(false), isFalse);
  });

  test('expect', () {
    expect(Some(42).expect(''), equals(42));
    expect(() => None().expect('message'), panics);
  });

  test('expect none', () {
    expect(() => Some(42).expectNone(''), panics);
    expect(() => None().expectNone('message'), returnsNormally);
  });

  test('flatten', () {
    expect(Some(Some(42)).flatten(), equals(Some(42)));
    expect(Some(None()).flatten(), equals(None()));
    expect(None<Option>().flatten(), equals(None()));
  });

  test('map', () {
    expect(Some(42).map((value) => value + 1), equals(Some(43)));
    expect(None<int>().map((value) => value + 1), equals(None<int>()));
  });

  test('map or', () {
    expect(
      Some(42).mapOr((value) => value + 1, defaultValue: 12),
      equals(43),
    );
    expect(
      None<int>().mapOr((value) => value + 1, defaultValue: 12),
      equals(12),
    );
  });

  test('map or else', () {
    expect(
      Some(42).mapOrElse((value) => value + 1, orElse: () => 12),
      equals(43),
    );
    expect(
      None<int>().mapOrElse((value) => value + 1, orElse: () => 12),
      equals(12),
    );
  });

  test('match', () {
    expect(
      Some(42).match(
        some: (value) => value + 1,
        none: () => 13,
      ),
      equals(43),
    );
    expect(
      None<int>().match(
        some: (value) => value + 1,
        none: () => 13,
      ),
      equals(13),
    );
    expect(() => Some(42).match(some: null, none: null), throwsAssertionError);
    expect(() => Some(42).match(some: (value) => value + 1, none: null),
        throwsAssertionError);
    expect(
        () => Some(42).match(some: null, none: () => 13), throwsAssertionError);

    expect(() => None().match(some: null, none: null), throwsAssertionError);
    expect(() => None().match(some: (value) => value + 1, none: null),
        throwsAssertionError);
    expect(
        () => None().match(some: null, none: () => 13), throwsAssertionError);
  });

  test('ok or', () {
    expect(Some(42).okOr('ERR'), equals(Ok(42)));
    expect(None().okOr('ERR'), equals(Err('ERR')));
  });

  test('ok or else', () {
    expect(Some(42).okOrElse(() => 'ERR'), equals(Ok(42)));
    expect(None().okOrElse(() => 'ERR'), equals(Err('ERR')));
  });

  test('or', () {
    expect(Some(42).or(None()), equals(Some(42)));
    expect(None<int>().or(Some(42)), equals(Some(42)));
    expect(Some(13).or(Some(42)), equals(Some(13)));
    expect(None<int>().or(None<int>()), equals(None<int>()));
  });

  test('or else', () {
    expect(Some(42).orElse(() => None()), equals(Some(42)));
    expect(None<int>().orElse(() => Some(42)), equals(Some(42)));
    expect(Some(13).orElse(() => Some(42)), equals(Some(13)));
    expect(None<int>().orElse(() => None<int>()), equals(None<int>()));
  });

  test('to option', () {
    expect(42.toOption, equals(Some(42)));
    expect(Some(42).toOption, equals(Some(42)));
  });

  test('to string', () {
    expect('${Some(42)}', equals('Some<int>(42)'));
    expect('${None()}', equals('None<dynamic>()'));
    expect('${None<int>()}', equals('None<int>()'));
  });

  test('transpose', () {
    expect(Some(Ok(42)).transpose(), equals(Ok(Some(42))));
    expect(None<Result>().transpose(), equals(Ok(None())));
    expect(Some(Err('ERR')).transpose(), equals(Err('ERR')));
  });

  test('unwrap', () {
    expect(Some(42).unwrap(), equals(42));
    expect(() => None().unwrap(), panics);
  });

  test('unwrap none', () {
    expect(() => Some(42).unwrapNone(), panics);
    expect(() => None().unwrapNone(), returnsNormally);
  });

  test('unwrap or', () {
    expect(Some(42).unwrapOr(13), equals(42));
    expect(None().unwrapOr(13), equals(13));
  });

  test('unwrap or else', () {
    expect(Some(42).unwrapOrElse(() => 13), equals(42));
    expect(None().unwrapOrElse(() => 13), equals(13));
  });

  test('where', () {
    expect(Some(42).where((value) => value % 2 == 0), equals(Some(42)));
    expect(Some(42).where((value) => value % 2 != 0), equals(None()));
    expect(None().where((value) => value % 2 == 0), equals(None()));
  });

  test('xor', () {
    expect(Some(42).xor(Some(43)), equals(None()));
    expect(Some(42).xor(None()), equals(Some(42)));
    expect(None<int>().xor(Some(43)), equals(Some(43)));
    expect(None().xor(None()), equals(None()));
  });
}
