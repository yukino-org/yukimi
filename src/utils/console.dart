import 'dart:convert';
import 'package:colorize/colorize.dart';
import 'package:utilx/utils.dart';
import '../config/constants.dart';
import '../config/meta.g.dart';
import '../core/manager.dart';

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
          StringUtils.snakeToPascalCase(x.name.toLowerCase()),
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
          'cyan',
          if (additionalValueStyles != null) additionalValueStyles
        ].join('/'),
      )}';
}

void printJson(final dynamic text) => print(json.encode(text));

void printHeading(final String heading) =>
    print(Dye.dye(heading, 'white/underline'));

void printTitle([final String? title]) {
  print(
    Dye.dye(
      '${Constants.appName} v${GeneratedAppMeta.version}',
      'darkGray',
    ),
  );

  if (title != null) {
    printHeading(title);
  }
}

void println() => print(' ');

void printWarning(final String value) {
  print(Dye.dye(value, 'lightYellow'));
}

void printError(final Object error, [final StackTrace? stack]) {
  print(Dye.dye(error.toString(), 'lightRed'));
  if (stack != null) {
    print(Dye.dye(stack.toString(), 'darkGray'));
  }
}

void printErrorJson(final Object error) => printJson(<dynamic, dynamic>{
      'error': error.toString(),
      'error_kind': error.runtimeType.toString(),
    });
