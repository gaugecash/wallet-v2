import 'package:flutter/cupertino.dart';

/// Stream that keeps track of the last value emitted.
/// todo: save the last value in Hive for offline use
/// It expects a broadcast stream.
class GStream<T> {
  GStream(this.stream) {
    stream.listen((value) {
      lastValue = value;
    });
  }

  final Stream<T> stream;
  T? lastValue;
}

// todo migrate all stream builders to this one
class GStreamBuilder<T> extends StatelessWidget {
  const GStreamBuilder({
    required this.builder,
    required this.gStream,
    super.key,
  });

  final GStream<T> gStream;
  final AsyncWidgetBuilder<T> builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      builder: builder,
      stream: gStream.stream,
      initialData: gStream.lastValue,
    );
  }
}
