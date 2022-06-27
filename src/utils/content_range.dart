import 'exceptions.dart';

class ContentRange {
  const ContentRange._(this.args, this.values);

  factory ContentRange.parse(
    final List<String> args, {
    required final List<String> allowed,
  }) {
    final List<String> result = <String>[];

    final int first = allowed.isNotEmpty ? int.parse(allowed.first) : 0;
    final int last = allowed.isNotEmpty ? int.parse(allowed.last) : 0;

    for (final String x in args) {
      final List<String> splitted = x.split(RegExp(r'\.{2,3}'));

      switch (splitted.length) {
        case 1:
          result.add(
            _parseExpression(splitted.first, first: first, last: last)
                .toString(),
          );
          break;

        case 2:
          final int a =
              _parseExpression(splitted.first, first: first, last: last);
          final int b =
              _parseExpression(splitted.last, first: first, last: last);
          final int range = b - a + 1;

          if (range < 1) {
            throw CommandException('Invalid range: $x (Bad Range)');
          }

          result.addAll(
            List<String>.generate(range, (final int i) => (a + i).toString()),
          );
          break;

        default:
          throw CommandException('Invalid range: $x');
      }
    }

    return ContentRange._(
      args,
      result.where((final String x) => allowed.contains(x)).toList(),
    );
  }

  final List<String> args;
  final List<String> values;

  bool contains(final String value) => values.contains(value);

  static int _parseValue(
    final String expression, {
    required final int first,
    required final int last,
  }) {
    switch (expression) {
      case 'first':
        return first;

      case 'last':
        return last;

      default:
        return int.parse(expression);
    }
  }

  static int _parseExpression(
    final String expression, {
    required final int first,
    required final int last,
  }) {
    final RegExpMatch? match =
        RegExp(r'^(\w+)([+-])(\w+)$').firstMatch(expression);
    if (match == null) {
      return _parseValue(expression, first: first, last: last);
    }

    final int a = _parseValue(match.group(1)!, first: first, last: last);
    final int b = _parseValue(match.group(3)!, first: first, last: last);
    final String op = match.group(2)!;

    switch (op) {
      case '+':
        return a + b;

      case '-':
        return a - b;

      default:
        throw CommandException('Invalid operation: $op');
    }
  }
}
