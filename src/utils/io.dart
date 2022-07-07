import 'dart:async';
import 'package:utilx/utils.dart';

typedef QueuedOperation<T> = Future<T> Function();

class QueuedRunner<T> {
  QueuedRunner(
    this.operations, {
    required this.concurrency,
  });

  final List<QueuedOperation<T>> operations;
  final int concurrency;

  late int _index;
  late int _count;
  late StreamController<TwinTuple<int, T>> _stream;

  void _queue() {
    if (_isQueueFilled) return;

    if (!_hasPendingOperations) {
      if (_isQueueEmpty) {
        _stream.close();
      }
      return;
    }

    final int i = _index++;
    _count++;

    operations[i]().then((final T value) async {
      _stream.add(TwinTuple<int, T>(i, value));
      _count--;
      _queue();
    }).catchError((final Object error, final StackTrace stackTrace) {
      _stream.addError(error, stackTrace);
    });

    _queue();
  }

  Stream<TwinTuple<int, T>> asStream() {
    _index = 0;
    _count = 0;
    _stream = StreamController<TwinTuple<int, T>>();
    _queue();
    return _stream.stream;
  }

  Future<List<T>> asFuture() async {
    final List<T?> results = List<T?>.filled(operations.length, null);
    await for (final TwinTuple<int, T> x in asStream()) {
      results[x.first] = x.last;
    }
    return results.cast<T>();
  }

  bool get _hasPendingOperations => _index < operations.length;
  bool get _isQueueEmpty => _count == 0;
  bool get _isQueueFilled => _count >= concurrency;
}
