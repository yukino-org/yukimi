import 'package:args/args.dart';
import 'package:tenka/tenka.dart';
import 'package:utilx/locale.dart';
import '../config/meta.dart';
import '../config/paths.dart';
import '../core/database/settings.dart';
import '../core/tenka.dart';
import 'exceptions.dart';

enum CustomQualities {
  best,
  worst,
}

abstract class QualityArgs {
  static final Map<CustomQualities, Quality> customQualities =
      CustomQualities.values.asMap().map(
            (final int _, final CustomQualities x) =>
                MapEntry<CustomQualities, Quality>(
              x,
              Quality(Qualities.unknown, x.name, x.name),
            ),
          );

  static final List<String> customQualityCodes =
      CustomQualities.values.map((final CustomQualities x) => x.name).toList();

  static final List<String> allQualityCodes = <String>[
    ...customQualityCodes,
    ...Quality.qualities.values.map((final Quality x) => x.code),
  ];

  static Quality parse(final String value) {
    if (customQualityCodes.contains(value)) {
      return customQualities.entries
          .firstWhere(
            (final MapEntry<CustomQualities, Quality> x) =>
                x.value.code == value,
          )
          .value;
    }

    return Quality.parse(value);
  }
}

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

class CommandArgumentTemplates {
  const CommandArgumentTemplates(this.variables);

  factory CommandArgumentTemplates.withDefaultTemplates(
    final Map<String, String> variables,
  ) =>
      CommandArgumentTemplates(defaultVariables()..addAll(variables));

  final Map<String, String> variables;

  String replace(final String value) => value.replaceAllMapped(
        RegExp(r'\${([^}]+)}'),
        (final Match x) {
          final String key = x.group(1)!;
          if (variables.containsKey(key)) {
            return variables[key]!;
          }

          return x.group(0)!;
        },
      );

  CommandArgumentTemplates copyWith(final Map<String, String> variables) =>
      CommandArgumentTemplates(<String, String>{
        ...this.variables,
        ...variables,
      });

  static const String kAppName = 'app.name';
  static const String kAppId = 'app.id';
  static const String kAppVersion = 'app.version';
  static const String kSettingsAnimeDownloadDestination =
      'settings.anime.download.destination';
  static const String kSettingsAnimeDownloadSubDestination =
      'settings.anime.download.subdestination';
  static const String kSettingsAnimeDownloadFilename =
      'settings.anime.download.filename';
  static const String kSettingsMangaDownloadDestination =
      'settings.manga.download.destination';
  static const String kSettingsMangaDownloadSubDestination =
      'settings.manga.download.subdestination';
  static const String kSettingsMangaDownloadFilename =
      'settings.manga.download.filename';
  static const String kSettingsAnimePreferredQuality =
      'settings.anime.preferredQuality';
  static const String kSettingsAnimeFallbackQuality =
      'settings.anime.fallbackQuality';
  static const String kAnimeTitle = 'anime.title';
  static const String kAnimeURL = 'anime.url';
  static const String kAnimeLocale = 'anime.locale';
  static const String kAnimeLocaleCode = 'anime.locale.code';
  static const String kEpisodeNumber = 'episode.number';
  static const String kEpisodeQuality = 'episode.quality';
  static const String kEpisodeLocale = 'episode.locale';
  static const String kEpisodeLocaleCode = 'episode.locale.code';
  static const String kMangaTitle = 'manga.title';
  static const String kMangaURL = 'manga.url';
  static const String kMangaLocale = 'manga.locale';
  static const String kMangaLocaleCode = 'manga.locale.code';
  static const String kVolumeNumber = 'chapter.volume';
  static const String kChapterNumber = 'chapter.number';
  static const String kChapterLocale = 'chapter.locale';
  static const String kChapterLocaleCode = 'chapter.locale.code';
  static const String kPageNumber = 'page.number';
  static const String kModuleName = 'extension.name';
  static const String kModuleId = 'extension.id';
  static const String kSysDownloadsDir = 'dirs.downloads';
  static const String kSysDocumentsDir = 'dirs.documents';
  static const String kSysVidoesDir = 'dirs.videos';
  static const String kSysPicturesDir = 'dirs.pictures';

  static Map<String, String> defaultVariables() => <String, String>{
        kAppName: AppMeta.name,
        kAppId: AppMeta.id,
        kAppVersion: GeneratedAppMeta.version,
        kSettingsAnimeDownloadDestination:
            AppSettings.settings.animeDownloadDestination,
        kSettingsAnimeDownloadSubDestination:
            AppSettings.settings.animeDownloadSubDestination,
        kSettingsAnimeDownloadFilename:
            AppSettings.settings.animeDownloadFilename,
        kSettingsMangaDownloadDestination:
            AppSettings.settings.mangaDownloadDestination,
        kSettingsMangaDownloadSubDestination:
            AppSettings.settings.mangaDownloadSubDestination,
        kSettingsMangaDownloadFilename:
            AppSettings.settings.mangaDownloadFilename,
        kSettingsAnimePreferredQuality:
            AppSettings.settings.animePreferredQuality,
        kSettingsAnimeFallbackQuality:
            AppSettings.settings.animeFallbackQuality,
        kSysDownloadsDir: Paths.uDownloadsDir,
        kSysDocumentsDir: Paths.uDocumentsDir,
        kSysVidoesDir: Paths.uVideosDir,
        kSysPicturesDir: Paths.uPicturesDir,
      };
}
