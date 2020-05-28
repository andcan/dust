import 'package:dust/dust.dart';
import 'package:test/test.dart';

import 'shared.dart';

void main() {
  group('result', () {
    final trace = StackTrace.current;
    group('create', () {
      test('ok', () {
        const res = Ok(42);
        expect(res.isOk, isTrue);
        expect(res.isErr, isFalse);
        expect(res.value, equals(42));
      });
      test('err', () {
        final res = Err.withStackTrace('ERR', trace);
        expect(res.isOk, isFalse);
        expect(res.isErr, isTrue);
        expect(res.error, equals('ERR'));
        expect(res.stackTrace, equals(trace));
      });
    });

    test('create computation', () {
      expect(Result(() => 42), equals(const Ok(42)));
      final err = Error();
      expect(Result(() => throw err).containsError(err), isTrue);
    });

    group('equals', () {
      group('ok', () {
        testEquality(
          description: 'with err',
          a: const Ok(42),
          a1: const Ok(42),
          a2: const Ok(42),
          b: Err.withStackTrace('ERR', trace),
        );
        testEquality(
          description: 'with ok',
          a: const Ok(42),
          a1: const Ok(42),
          a2: const Ok(42),
          b: const Ok(8),
        );
      });

      group('err', () {
        testEquality(
          description: 'with ok',
          a: Err.withStackTrace('ERR', trace),
          a1: Err.withStackTrace('ERR', trace),
          a2: Err.withStackTrace('ERR', trace),
          b: const Ok(42),
        );
        testEquality(
          description: 'with err',
          a: Err.withStackTrace('ERR', trace),
          a1: Err.withStackTrace('ERR', trace),
          a2: Err.withStackTrace('ERR', trace),
          b: Err.withStackTrace('ERR1', trace),
        );
      });
    });

    test('and', () {
      expect(const Ok(42).and(Err('ERR')), equals(Err('ERR')));
      expect(Err('ERR').and(const Ok(42)), equals(Err('ERR')));
      expect(Err('ERR').and(Err('ERR')), equals(Err('ERR')));
      expect(const Ok(42).and(const Ok(43)), equals(const Ok(43)));
    });

    test('and then', () {
      expect(const Ok(42).andThen((_) => Err('ERR')), equals(Err('ERR')));
      expect(Err('ERR').andThen((_) => const Ok(42)), equals(Err('ERR')));
      expect(Err('ERR').andThen((_) => Err('ERR')), equals(Err('ERR')));
      expect(const Ok(42).andThen((_) => const Ok(43)), equals(const Ok(43)));
    });

    test('capture', () async {
      expect(await Future.value(42).capture(), equals(const Ok(42)));
      expect(await Future.error('ERR', trace).capture(),
          equals(Err.withStackTrace('ERR', trace)));
    });

    test('capture stream', () async {
      expect(
          Stream.fromIterable([42, 'ERR', 12, 'ERR1'])
              .map((e) => e is String ? throw e : e)
              .capture(),
          emitsInOrder([
            const Ok(42),
            Err('ERR'),
            const Ok(12),
            Err('ERR1'),
          ]));
    });

    test('contains', () {
      expect(const Ok(42).contains(42), equals(isTrue));
      expect(const Ok(42).contains(13), equals(isFalse));
      expect(Err('ERR').contains(13), equals(isFalse));
    });

    test('contains error', () {
      expect(Err('ERR').containsError('ERR'), equals(isTrue));
      expect(Err('ERR').containsError('ERR1'), equals(isFalse));
      expect(const Ok(42).containsError('ERR'), equals(isFalse));
    });

    test('expect', () {
      expect(const Ok(42).expect(''), equals(42));
      expect(() => Err('ERR').expect(''), panics);
    });

    test('expect error', () {
      expect(() => const Ok(42).expectError(''), panics);
      expect(Err.withStackTrace('ERR', trace).expectError(''),
          equals(ErrorAndStackTrace('ERR', trace)));
    });

    test('map', () {
      expect(const Ok(42).map((value) => value + 1), equals(const Ok(43)));
      expect(Err('ERR').map((value) => value + 1), equals(Err('ERR')));
    });

    test('map error', () {
      expect(const Ok(42).mapError((err, st) => '$err!'), equals(const Ok(42)));
      expect(
        Err('ERR').mapError((err, st) => '$err!'),
        equals(Err('ERR!')),
      );
    });

    test('map or', () {
      expect(
        const Ok(42).mapOr((value) => value + 1, defaultValue: 13),
        equals(43),
      );
      expect(
        Err.withStackTrace('ERR', trace)
            .mapOr((value) => value + 1, defaultValue: 13),
        equals(13),
      );
    });

    test('map or else', () {
      expect(
        const Ok(42)
            .mapOrElse((value) => value + 1, orElse: (error, stackTrace) => 13),
        equals(43),
      );
      expect(
        Err.withStackTrace('ERR', trace)
            .mapOrElse((value) => value + 1, orElse: (error, stackTrace) => 13),
        equals(13),
      );
    });

    test('or', () {
      expect(const Ok(42).or(Err.withStackTrace('ERR', trace)),
          equals(const Ok(42)));
      expect(Err.withStackTrace('ERR', trace).or(const Ok(42)),
          equals(const Ok(42)));
      expect(
        Err.withStackTrace('ERR', trace).or(Err.withStackTrace('ERR1', trace)),
        equals(Err.withStackTrace('ERR1', trace)),
      );
      expect(
        Err.withStackTrace('ERR1', trace).or(Err.withStackTrace('ERR', trace)),
        equals(Err.withStackTrace('ERR', trace)),
      );
      expect(const Ok(42).or(const Ok(13)), equals(const Ok(42)));
    });

    test('or else', () {
      expect(
          const Ok(42).orElse((error, _) => Err.withStackTrace('ERR', trace)),
          equals(const Ok(42)));
      expect(
          Err.withStackTrace('ERR', trace).orElse((error, _) => const Ok(42)),
          equals(const Ok(42)));
      expect(
        Err.withStackTrace('ERR', trace)
            .orElse((error, _) => Err.withStackTrace('ERR1', trace)),
        equals(Err.withStackTrace('ERR1', trace)),
      );
      expect(
        Err.withStackTrace('ERR1', trace)
            .orElse((error, _) => Err.withStackTrace('ERR', trace)),
        equals(Err.withStackTrace('ERR', trace)),
      );
      expect(const Ok(42).orElse((error, _) => const Ok(13)),
          equals(const Ok(42)));
    });

    test('to err', () {
      expect(const Ok(42).err(), equals(const None()));
      expect(Err.withStackTrace('ERR', trace).err(),
          equals(Some(ErrorAndStackTrace('ERR', trace))));
    });

    test('to ok', () {
      expect(const Ok(42).ok(), equals(const Some(42)));
      expect(Err('ERR').ok(), equals(const None()));
    });

    test('to result', () {
      expect(42.toResult, equals(const Ok(42)));
    });

    test('unwrap', () {
      expect(const Ok(42).unwrap(), equals(42));
      expect(() => Err('ERR').unwrap(), panics);
    });
  });
}
