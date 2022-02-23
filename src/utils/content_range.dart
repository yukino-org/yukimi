import 'command_exception.dart';

class ContentRange {
  const ContentRange._(this.args, this.contains);

  factory ContentRange.parse(final List<String> args) {
    if (args.length == 1 && args[0].toLowerCase() == 'all') {
      return ContentRange._(args, (final String range) => true);
    }

    final List<String> result = <String>[];

    for (final String x in args) {
      final List<String> splitted = x.split(RegExp(r'-|\.{2,3}'));
      switch (splitted.length) {
        case 1:
          result.addAll(splitted);
          break;

        case 2:
          final int a = int.parse(splitted[0]);
          final int b = int.parse(splitted[1]);
          final int range = b - a + 1;
          if (range < 1) throw CRTException('Invalid range: $x (Bad Range)');
          result.addAll(
            List<String>.generate(range, (final int i) => (a + i).toString()),
          );
          break;

        default:
          throw CRTException('Invalid range: $x');
      }
    }

    return ContentRange._(args, result.contains);
  }

  final List<String> args;
  final bool Function(String) contains;
}
