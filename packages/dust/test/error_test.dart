import 'package:test/test.dart';

import 'package:dust/dust.dart';
import 'shared.dart';

void main() {
  test('panic', () {
    expect(Panic('MSG').value, equals('MSG'));
    expect(Panic('MSG').toString(), equals('MSG'));
  });

  group('error and stacktrace', () {
    final trace = StackTrace.current;

    test('create', () {
      final est = ErrorAndStackTrace('ERR', trace);
      expect(est.error, equals('ERR'));
      expect(est.stackTrace, equals(trace));
    });

    group('equality', () {
      testEquality(
        description: 'error',
        a: ErrorAndStackTrace('ERR', trace),
        a1: ErrorAndStackTrace('ERR', trace),
        a2: ErrorAndStackTrace('ERR', trace),
        b: ErrorAndStackTrace.current('ERR'),
      );

      testEquality(
        description: 'stackTrace',
        a: ErrorAndStackTrace('ERR', trace),
        a1: ErrorAndStackTrace('ERR', trace),
        a2: ErrorAndStackTrace('ERR', trace),
        b: ErrorAndStackTrace('ERR1', trace),
      );
    });
  });
}
