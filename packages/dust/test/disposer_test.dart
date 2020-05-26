import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

// ignore: avoid_relative_lib_imports
import '../lib/dust.dart';

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

  group('suscription disposer', () {
    group('dispose', () {
      test('cancels subscription', () async {
        final subs = [for (var i = 0; i < 8; i++) _StreamSubscription()];
        final disposer = _SubscriptionDisposer(subs);
        await expectLater(disposer.dispose(), completes);
        for (final sub in subs) {
          verify(sub.cancel());
        }
      });
    }, timeout: const Timeout(Duration(milliseconds: 1000)));
  });
}

class _StreamSubscription extends Mock implements StreamSubscription {}

class _Disposer with Disposer {
  _Disposer(Iterable<DisposerFunc> disposerFuncs) {
    for (final d in disposerFuncs) {
      addDisposer(d);
    }
  }
}

class _SubscriptionDisposer with Disposer, SubscriptionDisposer {
  _SubscriptionDisposer(Iterable<StreamSubscription> subscriptions) {
    for (final sub in subscriptions) {
      manageSubscription(sub);
    }
  }
}

class _EmptyDisposer with Disposer {}
