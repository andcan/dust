import 'dart:async';

import 'package:meta/meta.dart';

typedef DisposerFunc = FutureOr<void> Function();

extension DisposerSinkExtension on Sink {
  void disposer(Disposer d) => d.addDisposer(close);
}

extension DisposerStreamSubscriptionExtension on StreamSubscription {
  void disposer(Disposer d) => d.addDisposer(cancel);
}

extension DisposerFuncExtension<T> on DisposerFunc {
  void disposer(Disposer d) => d.addDisposer(this);
}

mixin Disposer {
  final List<DisposerFunc> _disposers = <DisposerFunc>[];

  @protected
  void addDisposer(DisposerFunc f) {
    _disposers.add(f);
  }

  @mustCallSuper
  Future<void> dispose() async {
    if (_disposers.isEmpty) {
      return;
    }
    return Future.wait([
      for (final f in _disposers) Future(f),
    ], eagerError: true);
  }
}

mixin SubscriptionDisposer on Disposer {
  @protected
  void manageSubscription(StreamSubscription subscription) =>
      addDisposer(subscription.cancel);
}
