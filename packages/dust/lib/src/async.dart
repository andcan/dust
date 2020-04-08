import 'dart:async';
import 'package:meta/meta.dart';

mixin Disposable {
  final List<StreamSubscription> _subscriptions = <StreamSubscription>[];

  @protected
  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  @mustCallSuper
  Future<void> dispose() async => Future.wait([
        for (final sub in _subscriptions) sub.cancel(),
      ]);
}
