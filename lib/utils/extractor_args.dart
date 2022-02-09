import 'package:args/args.dart';
import 'package:extensions/extensions.dart';
import 'package:extensions/metadata.dart';
import 'package:utilx/utilities/locale.dart';
import '../../core/extensions.dart';
import '../../utils/command_exception.dart';

class ExtensionRestArg<T> {
  const ExtensionRestArg({
    required this.storeMetadata,
    required this.extractor,
    required this.locale,
    required this.restArgs,
  });

  final EStoreMetadata storeMetadata;
  final T extractor;
  final Locale locale;
  final List<String> restArgs;

  String get terms => restArgs.join(' ');

  static void addOptions(final ArgParser argParser) => argParser
    ..addOption('locale', aliases: <String>['language', 'lang'])
    ..addOption('extension', aliases: <String>['ext']);

  static Future<ExtensionRestArg<T>> parse<T>(
    final ArgResults argResults,
    final EType eType,
  ) async {
    late final String extensionName;
    late final List<String> restArgs;
    late final Locale locale;

    final List<String> allRestArgs = argResults.rest;
    if (argResults.wasParsed('extension')) {
      extensionName = argResults['extension'] as String;
      restArgs = allRestArgs;
    } else {
      if (allRestArgs.length < 2) {
        throw CRTException('Missing option: extension');
      }

      extensionName = allRestArgs[0];
      restArgs = allRestArgs.sublist(1);
    }

    final String? id =
        ExtensionsManager.repository.storeNameIdMap[extensionName];
    if (id == null) throw CRTException('Invalid extension: $id');

    if (!ExtensionsManager.repository.extensions.containsKey(id)) {
      throw CRTException('Missing extension: $extensionName');
    }

    final EStoreMetadata storeMetadata =
        ExtensionsManager.repository.extensions[id]!;

    final T extractor = await ExtensionsManager.getExtractor<T>(storeMetadata);

    switch (eType) {
      case EType.anime:
        if (extractor is! AnimeExtractor) {
          throw CRTException('Invalid extension type: ${eType.name}');
        }
        break;

      case EType.manga:
        if (extractor is! MangaExtractor) {
          throw CRTException('Invalid extension type: ${eType.name}');
        }
        break;
    }

    if (argResults.wasParsed('locale')) {
      try {
        locale = Locale.parse(argResults['locale'] as String);
      } catch (_) {
        throw CRTException('Invalid locale: ${argResults['locale']}');
      }
    } else if (extractor is AnimeExtractor) {
      locale = extractor.defaultLocale;
    } else if (extractor is MangaExtractor) {
      locale = extractor.defaultLocale;
    }

    return ExtensionRestArg<T>(
      storeMetadata: storeMetadata,
      extractor: extractor,
      locale: locale,
      restArgs: restArgs,
    );
  }
}
