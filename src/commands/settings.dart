import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import '../core/commander.dart';
import '../core/database/settings.dart';
import '../core/manager.dart';
import '../utils/console.dart';

class _Options extends CommandOptions {
  const _Options(final ArgResults results) : super(results);

  static const String kReset = 'reset';
  static const String kResetAbbr = 'r';
  static const List<String> kResetAliases = <String>['clear', 'default'];
  static final List<String> kResetAllowed =
      AppSettings.defaultSettings().toJson().keys.toList().cast<String>();
  List<String>? get reset => getNullable<List<dynamic>>(kReset)?.cast<String>();

  static const String kResetAll = 'reset-all';
  static const List<String> kResetAllAliases = <String>[
    'r-all',
    'clear-all',
    'default-all'
  ];
  bool get resetAll => get<bool>(kResetAll);

  static const String kIgnoreSSLCertificate =
      AppSettingsKeys.kIgnoreSSLCertificate;
  static const bool? kIgnoreSSLCertificateDefaultsTo = null;
  bool? get ignoreSSLCertificate => getNullable<bool>(kIgnoreSSLCertificate);

  static const String kMpvPath = AppSettingsKeys.kMpvPath;
  String? get mpvPath => getNullable<String>(kMpvPath);

  static const String kAnimeDownloadDestination =
      AppSettingsKeys.kAnimeDownloadDestination;
  String? get animeDownloadDestination =>
      getNullable<String>(kAnimeDownloadDestination);

  static const String kAnimeDownloadSubDestination =
      AppSettingsKeys.kAnimeDownloadSubDestination;
  String? get animeDownloadSubDestination =>
      getNullable<String>(kAnimeDownloadSubDestination);

  static const String kAnimeDownloadFilename =
      AppSettingsKeys.kAnimeDownloadFilename;
  String? get animeDownloadFilename =>
      getNullable<String>(kAnimeDownloadFilename);

  static const String kMangaDownloadDestination =
      AppSettingsKeys.kMangaDownloadDestination;
  String? get mangaDownloadDestination =>
      getNullable<String>(kMangaDownloadDestination);

  static const String kMangaDownloadSubDestination =
      AppSettingsKeys.kMangaDownloadSubDestination;
  String? get mangaDownloadSubDestination =>
      getNullable<String>(kMangaDownloadSubDestination);

  static const String kMangaDownloadFilename =
      AppSettingsKeys.kMangaDownloadFilename;
  String? get mangaDownloadFilename =>
      getNullable<String>(kMangaDownloadFilename);

  static const String kAnimePreferredQuality =
      AppSettingsKeys.kAnimePreferredQuality;
  String? get animePreferredQuality =>
      getNullable<String>(kAnimePreferredQuality);

  static const String kAnimeFallbackQuality =
      AppSettingsKeys.kAnimeFallbackQuality;
  String? get animeFallbackQuality =>
      getNullable<String>(kAnimeFallbackQuality);
}

class SettingsCommand extends Command<void> {
  SettingsCommand() {
    argParser
      ..addMultiOption(
        _Options.kReset,
        abbr: _Options.kResetAbbr,
        aliases: _Options.kResetAliases,
        allowed: _Options.kResetAllowed,
      )
      ..addFlag(
        _Options.kResetAll,
        aliases: _Options.kResetAllAliases,
      )
      ..addFlag(
        _Options.kIgnoreSSLCertificate,
        defaultsTo: _Options.kIgnoreSSLCertificateDefaultsTo,
      )
      ..addOption(_Options.kMpvPath)
      ..addOption(_Options.kAnimeDownloadDestination)
      ..addOption(_Options.kAnimeDownloadSubDestination)
      ..addOption(_Options.kAnimeDownloadFilename)
      ..addOption(_Options.kMangaDownloadDestination)
      ..addOption(_Options.kMangaDownloadSubDestination)
      ..addOption(_Options.kMangaDownloadFilename)
      ..addOption(_Options.kAnimePreferredQuality)
      ..addOption(_Options.kAnimeFallbackQuality);
  }

  @override
  final String name = 'settings';

  @override
  final List<String> aliases = <String>[];

  @override
  final String description = 'Display the app settings.';

  @override
  Future<void> run() async {
    if (AppManager.isJsonMode) {
      printJson(AppSettings.settings.toJson());
      return;
    }

    final _Options options = _Options(argResults!);
    final AppSettings d = AppSettings.defaultSettings();

    int changes = 0;

    if (options.reset != null) {
      final Map<dynamic, dynamic> dJson = d.toJson();

      AppSettings.settings = AppSettings.fromJson(
        AppSettings.settings.toJson()
          ..addEntries(
            options.reset!.map(
              (final String x) => MapEntry<dynamic, dynamic>(x, dJson[x]),
            ),
          ),
      );
      changes++;
    }

    if (options.resetAll) {
      AppSettings.settings = AppSettings.defaultSettings();
      changes++;
    }

    if (options.ignoreSSLCertificate != null) {
      AppSettings.settings.ignoreSSLCertificate = options.ignoreSSLCertificate!;
      changes++;
    }

    if (options.animeDownloadDestination != null) {
      AppSettings.settings.animeDownloadDestination =
          resolveStringOptionValue(options.animeDownloadDestination!) ??
              d.animeDownloadDestination;
      changes++;
    }

    if (options.animeDownloadSubDestination != null) {
      AppSettings.settings.animeDownloadSubDestination =
          resolveStringOptionValue(options.animeDownloadSubDestination!) ??
              d.animeDownloadSubDestination;
      changes++;
    }

    if (options.animeDownloadFilename != null) {
      AppSettings.settings.animeDownloadFilename =
          resolveStringOptionValue(options.animeDownloadFilename!) ??
              d.animeDownloadFilename;
      changes++;
    }

    if (options.mangaDownloadDestination != null) {
      AppSettings.settings.mangaDownloadDestination =
          resolveStringOptionValue(options.mangaDownloadDestination!) ??
              d.mangaDownloadDestination;
      changes++;
    }

    if (options.mangaDownloadSubDestination != null) {
      AppSettings.settings.mangaDownloadSubDestination =
          resolveStringOptionValue(options.mangaDownloadSubDestination!) ??
              d.mangaDownloadSubDestination;
      changes++;
    }

    if (options.mangaDownloadFilename != null) {
      AppSettings.settings.mangaDownloadFilename =
          resolveStringOptionValue(options.mangaDownloadFilename!) ??
              d.mangaDownloadFilename;
      changes++;
    }

    if (options.mpvPath != null) {
      AppSettings.settings.mpvPath =
          resolveStringOptionValue(options.mpvPath!) ?? d.mpvPath;
      changes++;
    }

    if (options.animePreferredQuality != null) {
      AppSettings.settings.animePreferredQuality =
          resolveStringOptionValue(options.animePreferredQuality!) ??
              d.animePreferredQuality;
      changes++;
    }

    if (options.animeFallbackQuality != null) {
      AppSettings.settings.animeFallbackQuality =
          resolveStringOptionValue(options.animeFallbackQuality!) ??
              d.animeFallbackQuality;
      changes++;
    }

    if (changes > 0) {
      await AppSettings.save();
    }

    printTitle('Settings');

    final Map<String, String> mapped = <String, String>{
      'Ignore SSL Certificate':
          AppSettings.settings.ignoreSSLCertificate.toString(),
      'Anime Download Destination':
          AppSettings.settings.animeDownloadDestination,
      'Anime Download Sub-Destination':
          AppSettings.settings.animeDownloadSubDestination,
      'Anime Download Filename': AppSettings.settings.animeDownloadFilename,
      'Anime Preferred Video Quality':
          AppSettings.settings.animePreferredQuality,
      'Anime Fallback Video Quality': AppSettings.settings.animeFallbackQuality,
      'Manga Download Destination':
          AppSettings.settings.mangaDownloadDestination,
      'Manga Download Sub-Destination':
          AppSettings.settings.mangaDownloadSubDestination,
      'Manga Download Filename': AppSettings.settings.mangaDownloadFilename,
      'MPV Path': AppSettings.settings.mpvPath ?? '-',
    };

    mapped.forEach(
      (final String k, final String v) => print(DyeUtils.dyeKeyValue(k, v)),
    );
  }
}

String? resolveStringOptionValue(final String value) {
  if (value.trim() == '-') return null;
  return value;
}
