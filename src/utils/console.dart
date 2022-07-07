import 'dart:convert';
import 'dart:io';
import 'package:colorize/colorize.dart';
import 'package:utilx/utils.dart';
import '../core/manager.dart';
import 'others.dart';

abstract class AnsiCodes {
  static const String esc = '\x1B';
  static const String reset = '\r';
  static String moveCursorUp(final int lines) => '$esc[${lines}F';
}

abstract class Symbols {
  static const String tick = '✓';
  static const String cross = '✕';

  static final String greenTick = Dye.dye(tick, 'lightGreen').toString();
  static final String redCross = Dye.dye(cross, 'lightRed').toString();
}

class Dye {
  Dye(this.text);

  factory Dye.dye(final String text, final String styles) =>
      Dye(text).apply(styles);

  final String text;
  late final Colorize _colorize = Colorize(text);

  Dye apply(final String styles) {
    if (AppManager.globalArgResults?['color'] == false) return this;

    for (final String x in styles.split('/')) {
      _colorize.apply(parseStyle(x.trim()));
    }
    return this;
  }

  @override
  String toString() => _colorize.toString();

  static final Map<String, Styles> _styles = Styles.values.asMap().map(
        (final int i, final Styles x) => MapEntry<String, Styles>(
          StringCase(x.name.toLowerCase()).camelCase,
          x,
        ),
      );

  static Styles parseStyle(final String style) {
    if (!_styles.containsKey(style)) {
      throw Exception('Invalid style: $style');
    }

    return _styles[style]!;
  }
}

abstract class DyeUtils {
  static String dyeKeyValue(
    final String key,
    final String value, {
    final String? additionalValueStyles,
  }) =>
      '$key: ${Dye.dye(
        value,
        <String>[
          'lightCyan',
          if (additionalValueStyles != null) additionalValueStyles
        ].join('/'),
      )}';
}

void printJson(final dynamic text) => print(json.encode(text));

void printHeading(final String heading) =>
    print(Dye.dye(heading, 'white/underline'));

String escapeAnsi(final String text) => text.replaceAll(
      RegExp(r'(\x9B|\x1B\[)[0-?]*[ -\/]*[@-~]'),
      '',
    );

TwinTuple<String, String> _wrapTextWithinWidth(
  final String text,
  final int width, [
  final String seperator = ' ',
]) {
  final List<String> split = text.split(seperator);
  final StringBuffer out = StringBuffer();

  while (split.isNotEmpty) {
    final String x = split.first;

    if (x.length + out.length + seperator.length > width) {
      if (out.isEmpty) {
        out.write(x.substring(0, width) + seperator);
        split[0] = x.substring(width);
      }

      break;
    }

    out.write(x + seperator);
    split.removeAt(0);
  }

  return TwinTuple<String, String>(
    out.toString().trim(),
    split.join(seperator),
  );
}

enum PrintAlignment {
  left,
  center,
  right,
}

void printAligned(
  final String text, [
  final PrintAlignment alignment = PrintAlignment.center,
  final String seperator = ' ',
]) {
  final int maxWidth = stdout.terminalColumns;
  String remaining = text;

  while (remaining.isNotEmpty) {
    final TwinTuple<String, String> parsed =
        _wrapTextWithinWidth(remaining, maxWidth, seperator);

    final int remainingWidth = maxWidth - escapeAnsi(parsed.first).length;
    final int leftWidth;
    final int rightWidth;

    switch (alignment) {
      case PrintAlignment.left:
        leftWidth = 0;
        rightWidth = remainingWidth;
        break;

      case PrintAlignment.center:
        leftWidth = (remainingWidth / 2).floor();
        rightWidth = remainingWidth - leftWidth;
        break;

      case PrintAlignment.right:
        leftWidth = remainingWidth;
        rightWidth = 0;
        break;
    }

    print(seperator * leftWidth + parsed.first + seperator * rightWidth);
    remaining = parsed.last;
  }
}

void println() => print(' ');

void printWarning(final String value) {
  print(Dye.dye('[warn] $value', 'lightYellow'));
}

void printDebug(final String text) {
  if (AppManager.debug && !AppManager.isJsonMode) {
    print(Dye.dye('[debug] $text', 'dark'));
  }
}

void printError(final Object error, [final StackTrace? stack]) {
  print(Dye.dye('[error] $error', 'lightRed'));
  if (stack != null) {
    print(Dye.dye(stack.toString(), 'lightRed'));
  }
}

void printErrorJson(final Object error) => printJson(<dynamic, dynamic>{
      'error': error.toString(),
      'error_kind': error.runtimeType.toString(),
    });

String buildDownloadProgressBar(
  final double percent, {
  required final int width,
  final int? currentBytes,
  final int? totalBytes,
}) {
  final String current = currentBytes != null
      ? '${bytesToMb(currentBytes).toStringAsFixed(2)}MB'
      : '?';
  final String total = totalBytes != null
      ? '${bytesToMb(totalBytes).toStringAsFixed(2)}MB'
      : '?';

  return buildProgressBar(
    percent,
    width: width,
    prefix:
        '${Dye.dye('${percent.floor()}%', 'lightCyan')} ${Dye.dye('($current/$total)', 'dark')}',
  );
}

String buildGenericProgressBar(
  final double percent, {
  required final int width,
  final int? current,
  final int? total,
}) =>
    buildProgressBar(
      percent,
      width: width,
      prefix:
          '${Dye.dye('${percent.floor()}%', 'lightCyan')} ${Dye.dye('(${current ?? '?'}/${total ?? '?'})', 'dark')}',
    );

String buildProgressBar(
  final double percent, {
  required final int width,
  final String? prefix,
  final String? suffix,
}) {
  final int maxBarLength = width -
      (prefix != null ? escapeAnsi(prefix).length + 1 : 0) -
      (suffix != null ? escapeAnsi(suffix).length + 1 : 0) -
      2;

  final String bPrefix = '▬' * ((percent / 100) * maxBarLength).floor();
  final String bSuffix = ' ' * (maxBarLength - bPrefix.length);

  return (prefix != null ? '$prefix ' : '') +
      Dye.dye('[', 'dark').toString() +
      Dye.dye(bPrefix, 'lightCyan').toString() +
      Dye.dye(bSuffix, 'dark').toString() +
      Dye.dye(']', 'dark').toString() +
      (suffix != null ? ' $suffix' : '');
}

String getPaddedSingleLinePrint(final String line) =>
    line + (' ' * (stdout.terminalColumns - escapeAnsi(line).length));

String getPaddedPrintText(final String text) =>
    text.split('\n').map(getPaddedSingleLinePrint).join('\n');

int countConsoleTextLines(final String text) => escapeAnsi(text)
    .split('\n')
    .map((final String x) => (x.length / stdout.terminalColumns).ceil())
    .reduce((final int x, final int y) => x + y);
