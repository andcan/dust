import 'package:dust/dust.dart';
import 'package:test/test.dart';

void main() {
  group('disposer', () {
    group('dispose', () {
      test('calls disposers', () async {
        final disposer = _Disposer([
          for (var i = 0; i < 8; i++)
            expectAsync0(
              () => null,
              reason: 'should be called on dispose',
            )
        ]);
        expect(disposer.dispose(), completes);
      });
      test('completes with error when any disposer fail', () async {
        final disposer = _Disposer([
          for (var i = 0; i < 8; i++)
            expectAsync0(
              i == 3 ? () => throw Exception() : () => null,
              reason: 'should be called on dispose',
            )
        ]);
        expect(disposer.dispose(), throwsA(anything));
      });
      test('when empty', () async {
        final disposer = _EmptyDisposer();
        expect(disposer.dispose(), completes);
      });
    }, timeout: const Timeout(Duration(milliseconds: 1000)));
  });
}

class _Disposer with Disposer {
  _Disposer(Iterable<DisposerFunc> disposerFuncs) {
    for (final d in disposerFuncs) {
      addDisposer(d);
    }
  }
}

class _EmptyDisposer with Disposer {}
