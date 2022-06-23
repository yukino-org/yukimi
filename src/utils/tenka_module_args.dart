import 'package:args/args.dart';
import 'package:tenka/tenka.dart';
import 'package:utilx/locale.dart';
import '../core/tenka.dart';
import 'exceptions.dart';

class TenkaModuleArgs<T> {
  const TenkaModuleArgs({
    required this.metadata,
    required this.extractor,
    required this.locale,
    required this.restArgs,
  });

  final TenkaMetadata metadata;
  final T extractor;
  final Locale locale;
  final List<String> restArgs;

  String get terms => restArgs.join(' ');

  static void addOptions(final ArgParser argParser) => argParser
    ..addOption('locale', abbr: 'l', aliases: <String>['language', 'lang'])
    ..addOption('module', abbr: 'm', aliases: <String>['extension', 'ext']);

  static Future<TenkaModuleArgs<T>> parse<T>(
    final ArgResults argResults,
    final TenkaType type,
  ) async {
    late final String moduleName;
    late final List<String> restArgs;
    late final Locale locale;

    final List<String> allRestArgs = argResults.rest;
    if (argResults.wasParsed('module')) {
      moduleName = (argResults['module'] as String).toLowerCase();
      restArgs = allRestArgs;
    } else {
      if (allRestArgs.length < 2) {
        throw CommandException.missingOption('module');
      }

      moduleName = allRestArgs[0].toLowerCase();
      restArgs = allRestArgs.sublist(1);
    }

    final String? id = TenkaManager.repository.storeNameIdMap[moduleName];
    if (id == null) throw CommandException('Invalid module: $moduleName');

    if (!TenkaManager.repository.installed.containsKey(id)) {
      throw CommandException('Missing module: $moduleName');
    }

    final TenkaMetadata metadata = TenkaManager.repository.installed[id]!;
    final T extractor = await TenkaManager.getExtractor<T>(metadata);

    switch (type) {
      case TenkaType.anime:
        if (extractor is! AnimeExtractor) {
          throw CommandException('Invalid module type: ${type.name}');
        }
        break;

      case TenkaType.manga:
        if (extractor is! MangaExtractor) {
          throw CommandException('Invalid module type: ${type.name}');
        }
        break;
    }

    if (argResults.wasParsed('locale')) {
      try {
        locale = Locale.parse(argResults['locale'] as String);
      } catch (_) {
        throw CommandException('Invalid locale: ${argResults['locale']}');
      }
    } else if (extractor is AnimeExtractor) {
      locale = extractor.defaultLocale;
    } else if (extractor is MangaExtractor) {
      locale = extractor.defaultLocale;
    }

    return TenkaModuleArgs<T>(
      metadata: metadata,
      extractor: extractor,
      locale: locale,
      restArgs: restArgs,
    );
  }
}
