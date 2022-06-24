import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import '../commands/agree_to_usage.dart';
import '../commands/anime.dart';
import '../commands/manga.dart';
import '../commands/settings.dart';
import '../commands/tenka.dart';
import '../commands/terminal.dart';
import '../commands/version.dart';
import '../config/meta.dart';
import '../config/paths.dart';
import 'database/settings.dart';

abstract class CommandOptions {
  const CommandOptions(this.results);

  final ArgResults results;

  bool wasParsed(final String name) => results.wasParsed(name);

  T? getNullable<T>(final String key) =>
      results.wasParsed(key) ? results[key] as T : null;

  T get<T>(final String key) => results[key] as T;
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

  static const String kAppName = 'app.name';
  static const String kAppId = 'app.id';
  static const String kAppVersion = 'app.version';
  static const String kSettingsAnimeDownloadDestination =
      'settings.anime.download.destination';
  static const String kSettingsAnimeDownloadFilename =
      'settings.anime.download.filename';
  static const String kSettingsMangaDownloadDestination =
      'settings.manga.download.destination';
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
        kSettingsAnimeDownloadFilename:
            AppSettings.settings.animeDownloadFilename,
        kSettingsMangaDownloadDestination:
            AppSettings.settings.mangaDownloadDestination,
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

abstract class AppCommander {
  static CommandRunner<void> get() {
    final CommandRunner<void> runner =
        CommandRunner<void>(AppMeta.id, AppMeta.description);

    runner.argParser
      ..addFlag('json', negatable: false)
      ..addFlag('color', defaultsTo: true);

    runner
      ..addCommand(AgreeToUsagePolicyCommand())
      ..addCommand(AnimeCommand())
      ..addCommand(MangaCommand())
      ..addCommand(TenkaCommand())
      ..addCommand(SettingsCommand())
      ..addCommand(TerminalCommand())
      ..addCommand(VersionCommand());

    return runner;
  }
}
