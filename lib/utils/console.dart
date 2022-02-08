import 'dart:convert';
import 'package:colorize/colorize.dart';
import 'package:utilx/utilities/utils.dart';
import '../config/constants.dart';
import '../config/meta.g.dart';

class Dye extends Colorize {
  Dye(final String text) : super(text);

  factory Dye.dye(final String text, final String styles) {
    final Dye dye = Dye(text);
    for (final String x in styles.split(',')) {
      dye.apply(parseStyle(x.trim()));
    }
    return dye;
  }

  static final Map<String, Styles> _styles = Styles.values.asMap().map(
        (final int i, final Styles x) => MapEntry<String, Styles>(
          StringUtils.snakeToPascalCase(x.name.toLowerCase()),
          x,
        ),
      );

  static Styles parseStyle(final String style) => _styles[style]!;
}

void printJson(final dynamic text) => print(json.encode(text));

void printTitle([final String? title]) {
  print(
    Dye.dye(
      '${Constants.appName} v${GeneratedAppMeta.version}\n',
      'darkGray',
    ),
  );

  if (title != null) {
    print(Dye.dye(title, 'underline'));
  }
}

void println() => print(' ');
