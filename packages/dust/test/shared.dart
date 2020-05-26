import 'package:test/test.dart';
import 'package:meta/meta.dart';

// ignore: avoid_relative_lib_imports
import '../lib/dust.dart';

Matcher get isPanicError => isA<Panic>();

Matcher get isAssertionError => isA<AssertionError>();

Matcher get panics => throwsA(isPanicError);

Matcher get throwsAssertionError => throwsA(isAssertionError);

void testEquality<T>({
  dynamic description,
  @required T a,
  @required T a1,
  @required T a2,
  @required T b,
}) {

  void runTests() {
    test('reflexive', () {
      expect(a, equals(a));
      expect(a.hashCode, equals(a.hashCode));
    });

    test('symmetric', () {
      expect((a == b) == (b == a), isTrue);
      expect((a.hashCode == b.hashCode) == (b.hashCode == a.hashCode), isTrue);

      expect((a == a1) == (a1 == a), isTrue);
      expect(
          (a.hashCode == a1.hashCode) == (a1.hashCode == a.hashCode), isTrue);
    });

    test('transitive', () {
      expect((a == a1 && a1 == a2) == (a == a2), isTrue);
      expect(
          (a.hashCode == a1.hashCode && a1.hashCode == a2.hashCode) ==
              (a.hashCode == a2.hashCode),
          isTrue);

      expect((a == a1 && a1 == b) == (a == b), isTrue);
      expect(
          (a.hashCode == a1.hashCode && a1.hashCode == b.hashCode) ==
              (a.hashCode == b.hashCode),
          isTrue);
    });
  };

  if(description != null) {
    group(description, runTests);
  } else {
    runTests();
  }
}
