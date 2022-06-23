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
  bool get reset => get<bool>(kReset);

  static const String kIgnoreSSLCertificate = 'ignoreSSLCertificate';
  bool? get ignoreSSLCertificate => getNullable<bool>(kIgnoreSSLCertificate);

  static const String kMpvPath = 'mpvPath';
  String? get mpvPath => getNullable<String>(kMpvPath);

  static const String kAnimeDir = 'animeDir';
  String? get animeDir => getNullable<String>(kAnimeDir);

  static const String kMangaDir = 'mangaDir';
  String? get mangaDir => getNullable<String>(kMangaDir);

  static const String kAnimePreferredQuality = 'animePreferredQuality';
  String? get animePreferredQuality =>
      getNullable<String>(kAnimePreferredQuality);

  static const String kAnimeFallbackQuality = 'animeFallbackQuality';
  String? get animeFallbackQuality =>
      getNullable<String>(kAnimeFallbackQuality);
}

class SettingsCommand extends Command<void> {
  SettingsCommand() {
    argParser
      ..addFlag(
        _Options.kReset,
        abbr: _Options.kResetAbbr,
        aliases: _Options.kResetAliases,
      )
      ..addFlag(
        _Options.kIgnoreSSLCertificate,
        defaultsTo: null,
      )
      ..addOption(_Options.kMpvPath)
      ..addOption(_Options.kAnimeDir)
      ..addOption(_Options.kMangaDir)
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

    if (options.reset) {
      AppSettings.settings = AppSettings.defaultSettings();
      changes++;
    }

    if (options.ignoreSSLCertificate != null) {
      AppSettings.settings.ignoreSSLCertificate = options.ignoreSSLCertificate!;
      changes++;
    }

    if (options.animeDir != null) {
      AppSettings.settings.animeDestination =
          resolveStringOptionValue(options.animeDir!) ?? d.animeDestination;
      changes++;
    }

    if (options.mangaDir != null) {
      AppSettings.settings.mangaDestination =
          resolveStringOptionValue(options.mangaDir!) ?? d.mangaDestination;
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
      'Anime Download Destination': AppSettings.settings.animeDestination,
      'Anime Preferred Video Quality':
          AppSettings.settings.animePreferredQuality,
      'Anime Fallback Video Quality': AppSettings.settings.animeFallbackQuality,
      'Manga Download Destination': AppSettings.settings.mangaDestination,
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
