import 'package:test/test.dart';

// ignore: avoid_relative_lib_imports
import '../lib/dust.dart';
import 'shared.dart';

void main() {
  group('result', () {
    final trace = StackTrace.current;
    group('create', () {
      test('ok', () {
        final res = Ok(42);
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
      expect(Result(() => 42), equals(Ok(42)));
      final err = Error();
      expect(Result(() => throw err).containsError(err), isTrue);
    });

    group('equals', () {
      group('ok', () {
        testEquality(
          description: 'with err',
          a: Ok(42),
          a1: Ok(42),
          a2: Ok(42),
          b: Err.withStackTrace('ERR', trace),
        );
        testEquality(
          description: 'with ok',
          a: Ok(42),
          a1: Ok(42),
          a2: Ok(42),
          b: Ok(8),
        );
      });

      group('err', () {
        testEquality(
          description: 'with ok',
          a: Err.withStackTrace('ERR', trace),
          a1: Err.withStackTrace('ERR', trace),
          a2: Err.withStackTrace('ERR', trace),
          b: Ok(42),
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
      expect(Ok(42).and(Err('ERR')), equals(Err('ERR')));
      expect(Err('ERR').and(Ok(42)), equals(Err('ERR')));
      expect(Err('ERR').and(Err('ERR')), equals(Err('ERR')));
      expect(Ok(42).and(Ok(43)), equals(Ok(43)));
    });

    test('and then', () {
      expect(Ok(42).andThen((_) => Err('ERR')), equals(Err('ERR')));
      expect(Err('ERR').andThen((_) => Ok(42)), equals(Err('ERR')));
      expect(Err('ERR').andThen((_) => Err('ERR')), equals(Err('ERR')));
      expect(Ok(42).andThen((_) => Ok(43)), equals(Ok(43)));
    });

    test('capture', () async {
      expect(await Future.value(42).capture(), equals(Ok(42)));
      expect(await Future.error('ERR', trace).capture(),
          equals(Err.withStackTrace('ERR', trace)));
    });

    test('contains', () {
      expect(Ok(42).contains(42), equals(isTrue));
      expect(Ok(42).contains(13), equals(isFalse));
      expect(Err('ERR').contains(13), equals(isFalse));
    });

    test('contains error', () {
      expect(Err('ERR').containsError('ERR'), equals(isTrue));
      expect(Err('ERR').containsError('ERR1'), equals(isFalse));
      expect(Ok(42).containsError('ERR'), equals(isFalse));
    });

    test('expect', () {
      expect(Ok(42).expect(''), equals(42));
      expect(() => Err('ERR').expect(''), panics);
    });

    test('expect error', () {
      expect(() => Ok(42).expectError(''), panics);
      expect(Err.withStackTrace('ERR', trace).expectError(''),
          equals(ErrorAndStackTrace('ERR', trace)));
    });

    test('map', () {
      expect(Ok(42).map((value) => value + 1), equals(Ok(43)));
      expect(Err('ERR').map((value) => value + 1), equals(Err('ERR')));
    });

    test('map error', () {
      expect(Ok(42).mapError((err, st) => '$err!'), equals(Ok(42)));
      expect(
        Err('ERR').mapError((err, st) => '$err!'),
        equals(Err('ERR!')),
      );
    });

    test('map or', () {
      expect(
        Ok(42).mapOr((value) => value + 1, defaultValue: 13),
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
        Ok(42).mapOrElse((value) => value + 1, orElse: (error, stackTrace) => 13),
        equals(43),
      );
      expect(
        Err.withStackTrace('ERR', trace)
            .mapOrElse((value) => value + 1, orElse: (error, stackTrace) => 13),
        equals(13),
      );
    });

    test('or', () {
      expect(Ok(42).or(Err.withStackTrace('ERR', trace)), equals(Ok(42)));
      expect(Err.withStackTrace('ERR', trace).or(Ok(42)), equals(Ok(42)));
      expect(
        Err.withStackTrace('ERR', trace).or(Err.withStackTrace('ERR1', trace)),
        equals(Err.withStackTrace('ERR1', trace)),
      );
      expect(
        Err.withStackTrace('ERR1', trace).or(Err.withStackTrace('ERR', trace)),
        equals(Err.withStackTrace('ERR', trace)),
      );
      expect(Ok(42).or(Ok(13)), equals(Ok(42)));
    });

    test('or else', () {
      expect(Ok(42).orElse((error, _) => Err.withStackTrace('ERR', trace)),
          equals(Ok(42)));
      expect(Err.withStackTrace('ERR', trace).orElse((error, _) => Ok(42)),
          equals(Ok(42)));
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
      expect(Ok(42).orElse((error, _) => Ok(13)), equals(Ok(42)));
    });

    test('to err', () {
      expect(Ok(42).toErr, equals(None()));
      expect(Err.withStackTrace('ERR', trace).toErr,
          equals(Some(ErrorAndStackTrace('ERR', trace))));
    });

    test('to ok', () {
      expect(Ok(42).toOk, equals(Some(42)));
      expect(Err('ERR').toOk, equals(None()));
    });

    test('to result', () {
      expect(42.toResult, equals(Ok(42)));
    });
  });
}
