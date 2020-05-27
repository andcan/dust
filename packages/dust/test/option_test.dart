import 'package:dust/dust.dart';
import 'package:test/test.dart';

import 'shared.dart';

void main() {
  group('option', () {
    group('create', () {
      test('some', () {
        const opt = Option.some(42);
        expect(opt is Some<int>, isTrue);
        expect(opt.isSome, isTrue);
        expect(opt.isNone, isFalse);
        expect((opt as Some).value, equals(42));

        const opt1 = Some(42);
        expect(opt1.value, equals(42));
      });

      test('none', () {
        const opt = Option<int>.none();
        expect(opt.isSome, isFalse);
        expect(opt.isNone, isTrue);
        expect(opt is None<int>, isTrue);
      });
    });

    group('equals', () {
      group('some', () {
        testEquality(
          description: 'with none',
          a: const Some(42),
          a1: const Some(42),
          a2: const Some(42),
          b: const None(),
        );
        testEquality(
          description: 'with some',
          a: const Some(42),
          a1: const Some(42),
          a2: const Some(42),
          b: const Some(8),
        );
      });
      group('none', () {
        testEquality(
          description: 'with some',
          a: const None<int>(),
          a1: const None<int>(),
          a2: const None<int>(),
          b: const Some(42),
        );
        testEquality(
          description: 'with none',
          a: const None<int>(),
          a1: const None<int>(),
          a2: const None<int>(),
          b: const None<bool>(),
        );
      });
    });

    test('and', () {
      expect(
          const None<int>().and(const Some(false)), equals(const None<bool>()));
      expect(
          const Some(42).and(const None<bool>()), equals(const None<bool>()));
      expect(const Some(42).and(const Some(43)), equals(const Some(43)));
      expect(const None<int>().and(const None<bool>()),
          equals(const None<bool>()));
    });

    test('and then', () {
      Some<int> plusOne(int value) => Some(value + 1);
      None<int> err(int value) => const None<int>();
      expect(const Some(42).andThen(plusOne), equals(const Some(43)));
      expect(const Some(42).andThen(plusOne).andThen(plusOne),
          equals(const Some(44)));
      expect(
          const Some(42).andThen(err).andThen(plusOne), equals(const None()));
      expect(const None<int>().andThen(plusOne).andThen(plusOne),
          equals(const None()));
      expect(const None<int>().andThen(plusOne).andThen(plusOne),
          equals(const None()));
    });

    test('cast', () {
      expect(const Some<num>(42).cast<int>() is Some<int>, isTrue);
      expect(const None<num>().cast<int>() is None<int>, isTrue);
    });

    test('contains', () {
      expect(const Some(42).contains(42), isTrue);
      expect(const Some(42).contains(8), isFalse);
      expect(const None<int>().contains(42), isFalse);
      expect(const None<bool>().contains(false), isFalse);
    });

    test('expect', () {
      expect(const Some(42).expect(''), equals(42));
      expect(() => const None().expect('message'), panics);
    });

    test('expect none', () {
      expect(() => const Some(42).expectNone(''), panics);
      expect(() => const None().expectNone('message'), returnsNormally);
    });

    test('flatten', () {
      expect(const Some(Some(42)).flatten(), equals(const Some(42)));
      expect(const Some(None()).flatten(), equals(const None()));
      expect(const None<Option>().flatten(), equals(const None()));
    });

    test('map', () {
      expect(const Some(42).map((value) => value + 1), equals(const Some(43)));
      expect(const None<int>().map((value) => value + 1),
          equals(const None<int>()));
    });

    test('map or', () {
      expect(
        const Some(42).mapOr((value) => value + 1, defaultValue: 12),
        equals(43),
      );
      expect(
        const None<int>().mapOr((value) => value + 1, defaultValue: 12),
        equals(12),
      );
    });

    test('map or else', () {
      expect(
        const Some(42).mapOrElse((value) => value + 1, orElse: () => 12),
        equals(43),
      );
      expect(
        const None<int>().mapOrElse((value) => value + 1, orElse: () => 12),
        equals(12),
      );
    });

    test('match', () {
      expect(
        const Some(42).match(
          some: (value) => value + 1,
          none: () => 13,
        ),
        equals(43),
      );
      expect(
        const None<int>().match(
          some: (value) => value + 1,
          none: () => 13,
        ),
        equals(13),
      );
      expect(() => const Some(42).match(some: null, none: null),
          throwsAssertionError);
      expect(() => const Some(42).match(some: (value) => value + 1, none: null),
          throwsAssertionError);
      expect(() => const Some(42).match(some: null, none: () => 13),
          throwsAssertionError);

      expect(() => const None().match(some: null, none: null),
          throwsAssertionError);
      expect(() => const None().match(some: (value) => value + 1, none: null),
          throwsAssertionError);
      expect(() => const None().match(some: null, none: () => 13),
          throwsAssertionError);
    });

    test('ok or', () {
      expect(const Some(42).okOr('ERR'), equals(const Ok(42)));
      expect(const None().okOr('ERR'), equals(Err('ERR')));
    });

    test('ok or else', () {
      expect(const Some(42).okOrElse(() => 'ERR'), equals(const Ok(42)));
      expect(const None().okOrElse(() => 'ERR'), equals(Err('ERR')));
    });

    test('or', () {
      expect(const Some(42).or(const None()), equals(const Some(42)));
      expect(const None<int>().or(const Some(42)), equals(const Some(42)));
      expect(const Some(13).or(const Some(42)), equals(const Some(13)));
      expect(
          const None<int>().or(const None<int>()), equals(const None<int>()));
    });

    test('or else', () {
      expect(const Some(42).orElse(() => const None()), equals(const Some(42)));
      expect(const None<int>().orElse(() => const Some(42)),
          equals(const Some(42)));
      expect(
          const Some(13).orElse(() => const Some(42)), equals(const Some(13)));
      expect(const None<int>().orElse(() => const None<int>()),
          equals(const None<int>()));
    });

    test('to option', () {
      expect(42.toOption, equals(const Some(42)));
      expect(const Some(42).toOption, equals(const Some(42)));
    });

    test('to string', () {
      expect('${const Some(42)}', equals('Some<int>(42)'));
      expect('${const None()}', equals('None<dynamic>()'));
      expect('${const None<int>()}', equals('None<int>()'));
    });

    test('transpose', () {
      expect(const Some(Ok(42)).transpose(), equals(const Ok(Some(42))));
      expect(const None<Result>().transpose(), equals(const Ok(None())));
      expect(Some(Err('ERR')).transpose(), equals(Err('ERR')));
    });

    test('unwrap', () {
      expect(const Some(42).unwrap(), equals(42));
      expect(() => const None().unwrap(), panics);
    });

    test('unwrap none', () {
      expect(() => const Some(42).unwrapNone(), panics);
      expect(() => const None().unwrapNone(), returnsNormally);
    });

    test('unwrap or', () {
      expect(const Some(42).unwrapOr(13), equals(42));
      expect(const None().unwrapOr(13), equals(13));
    });

    test('unwrap or else', () {
      expect(const Some(42).unwrapOrElse(() => 13), equals(42));
      expect(const None().unwrapOrElse(() => 13), equals(13));
    });

    test('where', () {
      expect(const Some(42).where((value) => value % 2 == 0),
          equals(const Some(42)));
      expect(const Some(42).where((value) => value % 2 != 0),
          equals(const None()));
      expect(
          const None().where((value) => value % 2 == 0), equals(const None()));
    });

    test('xor', () {
      expect(const Some(42).xor(const Some(43)), equals(const None()));
      expect(const Some(42).xor(const None()), equals(const Some(42)));
      expect(const None<int>().xor(const Some(43)), equals(const Some(43)));
      expect(const None().xor(const None()), equals(const None()));
    });
  });
}

void testOption() {}
