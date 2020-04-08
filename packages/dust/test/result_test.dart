import 'package:test/test.dart';

// ignore: avoid_relative_lib_imports
import '../lib/dust.dart';
import 'shared.dart';

void main() {
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

  group('equals', () {
    group('ok', () {
      testEquality('with err',
          a: Ok(42),
          a1: Ok(42),
          a2: Ok(42),
          b: Err.withStackTrace('ERR', trace));
      testEquality('with ok', a: Ok(42), a1: Ok(42), a2: Ok(42), b: Ok(8));
    });

    group('err', () {
      testEquality('with ok',
          a: Err.withStackTrace('ERR', trace),
          a1: Err.withStackTrace('ERR', trace),
          a2: Err.withStackTrace('ERR', trace),
          b: Ok(42));
      testEquality('with err',
          a: Err.withStackTrace('ERR', trace),
          a1: Err.withStackTrace('ERR', trace),
          a2: Err.withStackTrace('ERR', trace),
          b: Err.withStackTrace('ERR1', trace));
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

  test('to err', () {
    expect(Ok(42).toErr, equals(None()));
    expect(Err.withStackTrace('ERR', trace).toErr,
        equals(Some(ErrorAndStackTrace('ERR', trace))));
  });

  test('to ok', () {
    expect(Ok(42).toOk, equals(Some(42)));
    expect(Err('ERR').toOk, equals(None()));
  });
}
//
//void main() {
//  final trace = Trace.current();
//
//  test('create result value', () {
//    final result = Result.value(42);
//    expect(result.isValue, isTrue);
//    expect(result.isError, isFalse);
//    result.map(
//      error: (_) => fail('should be value'),
//      value: (result) => expect(result.value, equals(42)),
//    );
//    expect(result.contains(42), isTrue);
//    expect(result.containsError(Error()), isFalse);
//    expect(result.containsErrorAndStackTrace(Error(), trace), isFalse);
//    expect(result.toValue.contains(42), isTrue);
//    expect(result.toError.isNone, isTrue);
//  });
//
//  test('create result error', () {
//    final error = Error();
//    final result = Result.error(error, trace);
//    expect(result.isValue, isFalse);
//    expect(result.isError, isTrue);
//    result.when(
//      error: (e, st) {
//        expect(e, equals(error));
//        expect(st, equals(trace));
//      },
//      value: (_) => fail('should be error'),
//    );
//    expect(result.contains(42), isFalse);
//    expect(result.containsError(error), isTrue);
//    expect(result.containsErrorAndStackTrace(error, trace), isTrue);
//    expect(result.toValue.isNone, isTrue);
//    expect(result.toError.contains(ErrorAndStackTrace(error, trace)), isTrue);
//  });
//
//  test('map', () {
//    final value = Result<int, String>.value(42);
//    expect(value.mapValue((value) => value + 1), equals(ValueResult(43)));
//    expect(value.mapError((value) => ''), equals(ValueResult(42)));
//
//    final error = Result<int, String>.error('ERR');
//    expect(error.mapValue((value) => value + 1), equals(ErrorResult('ERR')));
//    expect(error.mapError((value) => '$value!'), equals(ErrorResult('ERR!')));
//  });
//
//  test('and', () {
//    final value = ValueResult<int, String>(42);
//    expect(
//      value.and(ValueResult<double, String>(24.0)),
//      equals(ValueResult<double, String>(24.0)),
//    );
//    expect(
//      value.and(ErrorResult<double, String>('ERR')),
//      equals(ErrorResult<double, String>('ERR')),
//    );
//
//    final error = ErrorResult<int, String>('ERR');
//    expect(
//      error.and(ValueResult<double, String>(24.0)),
//      equals(ErrorResult<double, String>('ERR')),
//    );
//    expect(
//      error.and(ErrorResult<double, String>('ERR1')),
//      equals(ErrorResult<double, String>('ERR')),
//    );
//  });
//
//  test('and then', () {
//    final sq = (int value) => ValueResult<int, String>(value * value);
//    final err = (int value) => ErrorResult<int, String>('ERR');
//
//    final value = ValueResult<int, String>(2);
//    expect(value.andThen(sq), equals(ValueResult<int, String>(4)));
//    expect(value.andThen(sq).andThen(sq), equals(ValueResult<int, String>(16)));
//    expect(
//      value.andThen(sq).andThen(err).andThen(sq),
//      equals(ErrorResult<int, String>('ERR')),
//    );
//
//    final error = ErrorResult<int, String>('ERR1');
//    expect(error.andThen(sq), equals(ErrorResult<int, String>('ERR1')));
//    expect(
//      error.andThen(sq).andThen(sq),
//      equals(ErrorResult<int, String>('ERR1')),
//    );
//    expect(
//      error.andThen(sq).andThen(err).andThen(sq),
//      equals(ErrorResult<int, String>('ERR1')),
//    );
//  });
//}
