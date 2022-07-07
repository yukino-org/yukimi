import 'exceptions.dart';

class ContentRange {
  const ContentRange._(this.args, this.values);

  factory ContentRange.parse(
    final List<String> args, {
    required final List<double> allowed,
  }) {
    final List<double> result = <double>[];

    final double first = allowed.isNotEmpty ? allowed.first : 0;
    final double last = allowed.isNotEmpty ? allowed.last : 0;

    for (final String x in args) {
      final List<String> splitted = x.split(RegExp(r'\.{2,3}'));

      switch (splitted.length) {
        case 1:
          result
              .add(_parseExpression(splitted.first, first: first, last: last));
          break;

        case 2:
          final double a =
              _parseExpression(splitted.first, first: first, last: last);
          final double b =
              _parseExpression(splitted.last, first: first, last: last);
          final double range = b - a + 1;

          if (range < 1) {
            throw CommandException('Invalid range: $x (Bad Range)');
          }

          final int start = allowed.indexWhere((final double x) => x >= a);
          final int end = allowed.lastIndexWhere((final double x) => x <= b);

          if (start != -1 && end != -1) {
            result.addAll(allowed.sublist(start, end + 1));
          }
          break;

        default:
          throw CommandException('Invalid range: $x');
      }
    }

    return ContentRange._(
      args,
      result.where((final double x) => allowed.contains(x)).toList(),
    );
  }

  final List<String> args;
  final List<double> values;

  bool contains(final double value) => values.contains(value);

  static double _parseValue(
    final String expression, {
    required final double first,
    required final double last,
  }) {
    switch (expression) {
      case 'first':
        return first;

      case 'last':
        return last;

      default:
        return double.parse(expression);
    }
  }

  static double _parseExpression(
    final String expression, {
    required final double first,
    required final double last,
  }) {
    final RegExpMatch? match =
        RegExp(r'^(\w+)([+-])(\w+)$').firstMatch(expression);
    if (match == null) {
      return _parseValue(expression, first: first, last: last);
    }

    final double a = _parseValue(match.group(1)!, first: first, last: last);
    final double b = _parseValue(match.group(3)!, first: first, last: last);
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
