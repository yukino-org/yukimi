import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:tenka/tenka.dart';
import '../../config/paths.dart';
import '../../utils/atomic_file.dart';
import '../commander.dart';

abstract class AppSettingsKeys {
  static const String kUsagePolicy = 'usagePolicy';
  static const String kIgnoreSSLCertificate = 'ignoreSSLCertificate';
  static const String kAnimePreferredQuality = 'animePreferredQuality';
  static const String kAnimeFallbackQuality = 'animeFallbackQuality';
  static const String kAnimeDownloadDestination = 'animeDownloadDestination';
  static const String kAnimeDownloadSubDestination =
      'animeDownloadSubDestination';
  static const String kAnimeDownloadFilename = 'animeDownloadFilename';
  static const String kMangaDownloadDestination = 'mangaDownloadDestination';
  static const String kMangaDownloadSubDestination =
      'mangaDownloadSubDestination';
  static const String kMangaDownloadFilename = 'mangaDownloadFilename';
  static const String kMpvPath = 'mpvPath';
}

class AppSettings {
  AppSettings._({
    this.usagePolicy = false,
    this.ignoreSSLCertificate = false,
    this.animePreferredQuality = '',
    this.animeFallbackQuality = '',
    this.animeDownloadDestination = '',
    this.animeDownloadSubDestination = '',
    this.animeDownloadFilename = '',
    this.mangaDownloadDestination = '',
    this.mangaDownloadSubDestination = '',
    this.mangaDownloadFilename = '',
    this.mpvPath,
  });

  factory AppSettings.defaultSettings() => AppSettings._(
        animePreferredQuality: Quality.get(Qualities.q_720p).code,
        animeFallbackQuality: Quality.get(Qualities.unknown).code,
        animeDownloadDestination:
            '\${${CommandArgumentTemplates.kSysDownloadsDir}}',
        animeDownloadSubDestination:
            '[\${${CommandArgumentTemplates.kModuleName}}] \${${CommandArgumentTemplates.kAnimeTitle}} (\${${CommandArgumentTemplates.kEpisodeLocaleCode}})',
        animeDownloadFilename: path.join(
          '\${${CommandArgumentTemplates.kSysDownloadsDir}}',
          '[\${${CommandArgumentTemplates.kModuleName}}] \${${CommandArgumentTemplates.kAnimeTitle}} (\${${CommandArgumentTemplates.kEpisodeLocaleCode}})',
        ),
        mangaDownloadDestination:
            '\${${CommandArgumentTemplates.kSysDownloadsDir}}',
        mangaDownloadSubDestination:
            '[\${${CommandArgumentTemplates.kModuleName}}] \${${CommandArgumentTemplates.kMangaTitle}} (\${${CommandArgumentTemplates.kChapterLocaleCode}})',
        mangaDownloadFilename:
            '[\${${CommandArgumentTemplates.kModuleName}}] \${${CommandArgumentTemplates.kMangaTitle}} — Vol. \${${CommandArgumentTemplates.kVolumeNumber}} Ch. \${${CommandArgumentTemplates.kChapterNumber}}',
      );

  factory AppSettings.fromJson(final Map<dynamic, dynamic> json) {
    final AppSettings d = AppSettings.defaultSettings();

    return AppSettings._(
      usagePolicy: json[AppSettingsKeys.kUsagePolicy] as bool? ?? d.usagePolicy,
      ignoreSSLCertificate:
          json[AppSettingsKeys.kIgnoreSSLCertificate] as bool? ??
              d.ignoreSSLCertificate,
      animePreferredQuality:
          json[AppSettingsKeys.kAnimePreferredQuality] as String? ??
              d.animePreferredQuality,
      animeFallbackQuality:
          json[AppSettingsKeys.kAnimeFallbackQuality] as String? ??
              d.animeFallbackQuality,
      animeDownloadDestination:
          json[AppSettingsKeys.kAnimeDownloadDestination] as String? ??
              d.animeDownloadDestination,
      animeDownloadSubDestination:
          json[AppSettingsKeys.kAnimeDownloadSubDestination] as String? ??
              d.animeDownloadSubDestination,
      animeDownloadFilename:
          json[AppSettingsKeys.kAnimeDownloadDestination] as String? ??
              d.animeDownloadFilename,
      mangaDownloadDestination:
          json[AppSettingsKeys.kMangaDownloadDestination] as String? ??
              d.mangaDownloadDestination,
      mangaDownloadSubDestination:
          json[AppSettingsKeys.kMangaDownloadSubDestination] as String? ??
              d.mangaDownloadSubDestination,
      mangaDownloadFilename:
          json[AppSettingsKeys.kMangaDownloadFilename] as String? ??
              d.mangaDownloadFilename,
      mpvPath: json[AppSettingsKeys.kMpvPath] as String? ?? d.mpvPath,
    );
  }

  bool usagePolicy;
  bool ignoreSSLCertificate;
  String animePreferredQuality;
  String animeFallbackQuality;
  String animeDownloadDestination;
  String animeDownloadSubDestination;
  String animeDownloadFilename;
  String mangaDownloadDestination;
  String mangaDownloadSubDestination;
  String mangaDownloadFilename;
  String? mpvPath;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        AppSettingsKeys.kUsagePolicy: usagePolicy,
        AppSettingsKeys.kIgnoreSSLCertificate: ignoreSSLCertificate,
        AppSettingsKeys.kAnimePreferredQuality: animePreferredQuality,
        AppSettingsKeys.kAnimeFallbackQuality: animeFallbackQuality,
        AppSettingsKeys.kAnimeDownloadDestination: animeDownloadDestination,
        AppSettingsKeys.kAnimeDownloadSubDestination:
            animeDownloadSubDestination,
        AppSettingsKeys.kAnimeDownloadFilename: animeDownloadFilename,
        AppSettingsKeys.kMangaDownloadDestination: mangaDownloadDestination,
        AppSettingsKeys.kMangaDownloadSubDestination:
            mangaDownloadSubDestination,
        AppSettingsKeys.kMangaDownloadFilename: mangaDownloadFilename,
        AppSettingsKeys.kMpvPath: mpvPath,
      };

  static bool ready = false;
  static late AppSettings settings;

  static Future<void> initialize() async {
    final File file = File(Paths.settingsFilePath);

    if (!(await file.exists())) {
      settings = AppSettings.defaultSettings();
      await save();
    } else {
      settings = AppSettings.fromJson(
        json.decode(await file.readAsString()) as Map<dynamic, dynamic>,
      );
    }

    ready = true;
  }

  static Future<void> save() async {
    await AtomicFS.writeFileAtomically(
      File(Paths.settingsFilePath),
      utf8.encode(json.encode(settings.toJson())),
    );
  }
}
