import 'dart:convert';
import 'dart:io';
import 'package:tenka/tenka.dart';
import 'package:utilx/utils.dart';
import '../../config/paths.dart';
import '../../utils/atomic_file.dart';
import '../../utils/custom_args.dart';

abstract class AppSettingsKeys {
  static const StringCase kUsagePolicy = StringCase('usagePolicy');

  static const StringCase kIgnoreSSLCertificate =
      StringCase('ignoreSSLCertificate');

  static const StringCase kAnimePreferredQuality =
      StringCase('animePreferredQuality');

  static const StringCase kAnimeFallbackQuality =
      StringCase('animeFallbackQuality');

  static const StringCase kAnimeDownloadDestination =
      StringCase('animeDownloadDestination');

  static const StringCase kAnimeDownloadSubDestination =
      StringCase('animeDownloadSubDestination');

  static const StringCase kAnimeDownloadFilename =
      StringCase('animeDownloadFilename');

  static const StringCase kMangaDownloadDestination =
      StringCase('mangaDownloadDestination');

  static const StringCase kMangaDownloadSubDestination =
      StringCase('mangaDownloadSubDestination');

  static const StringCase kMangaDownloadFilename =
      StringCase('mangaDownloadFilename');

  static const StringCase kMpvPath = StringCase('mpvPath');

  static const StringCase kDownloaderConcurrency =
      StringCase('downloaderConcurrency');
}

class AppSettings {
  AppSettings._({
    required this.usagePolicy,
    required this.ignoreSSLCertificate,
    required this.animePreferredQuality,
    required this.animeFallbackQuality,
    required this.animeDownloadDestination,
    required this.animeDownloadSubDestination,
    required this.animeDownloadFilename,
    required this.mangaDownloadDestination,
    required this.mangaDownloadSubDestination,
    required this.mangaDownloadFilename,
    required this.mpvPath,
    required this.downloaderConcurrency,
  });

  factory AppSettings.defaultSettings() => AppSettings._(
        usagePolicy: false,
        ignoreSSLCertificate: false,
        animePreferredQuality: Quality.get(Qualities.q_720p).code,
        animeFallbackQuality: Quality.get(Qualities.unknown).code,
        animeDownloadDestination:
            '\${${CommandArgumentTemplates.kSysDownloadsDir}}',
        animeDownloadSubDestination:
            '[\${${CommandArgumentTemplates.kModuleName}}] \${${CommandArgumentTemplates.kAnimeTitle}} (\${${CommandArgumentTemplates.kEpisodeLocaleCode}})',
        animeDownloadFilename:
            '[\${${CommandArgumentTemplates.kModuleName}}] \${${CommandArgumentTemplates.kAnimeTitle}} — Ep. \${${CommandArgumentTemplates.kEpisodeNumber}} (\${${CommandArgumentTemplates.kEpisodeQuality}})',
        mangaDownloadDestination:
            '\${${CommandArgumentTemplates.kSysDownloadsDir}}',
        mangaDownloadSubDestination:
            '[\${${CommandArgumentTemplates.kModuleName}}] \${${CommandArgumentTemplates.kMangaTitle}} (\${${CommandArgumentTemplates.kChapterLocaleCode}})',
        mangaDownloadFilename:
            '[\${${CommandArgumentTemplates.kModuleName}}] \${${CommandArgumentTemplates.kMangaTitle}} — Vol. \${${CommandArgumentTemplates.kVolumeNumber}} Ch. \${${CommandArgumentTemplates.kChapterNumber}}',
        mpvPath: null,
        downloaderConcurrency: 3,
      );

  factory AppSettings.fromJson(final Map<dynamic, dynamic> json) {
    final AppSettings d = AppSettings.defaultSettings();

    return AppSettings._(
      usagePolicy: json[AppSettingsKeys.kUsagePolicy.camelCase] as bool? ??
          d.usagePolicy,
      ignoreSSLCertificate:
          json[AppSettingsKeys.kIgnoreSSLCertificate.camelCase] as bool? ??
              d.ignoreSSLCertificate,
      animePreferredQuality:
          json[AppSettingsKeys.kAnimePreferredQuality.camelCase] as String? ??
              d.animePreferredQuality,
      animeFallbackQuality:
          json[AppSettingsKeys.kAnimeFallbackQuality.camelCase] as String? ??
              d.animeFallbackQuality,
      animeDownloadDestination:
          json[AppSettingsKeys.kAnimeDownloadDestination.camelCase]
                  as String? ??
              d.animeDownloadDestination,
      animeDownloadSubDestination:
          json[AppSettingsKeys.kAnimeDownloadSubDestination.camelCase]
                  as String? ??
              d.animeDownloadSubDestination,
      animeDownloadFilename:
          json[AppSettingsKeys.kAnimeDownloadFilename.camelCase] as String? ??
              d.animeDownloadFilename,
      mangaDownloadDestination:
          json[AppSettingsKeys.kMangaDownloadDestination.camelCase]
                  as String? ??
              d.mangaDownloadDestination,
      mangaDownloadSubDestination:
          json[AppSettingsKeys.kMangaDownloadSubDestination.camelCase]
                  as String? ??
              d.mangaDownloadSubDestination,
      mangaDownloadFilename:
          json[AppSettingsKeys.kMangaDownloadFilename.camelCase] as String? ??
              d.mangaDownloadFilename,
      mpvPath: json[AppSettingsKeys.kMpvPath.camelCase] as String? ?? d.mpvPath,
      downloaderConcurrency:
          json[AppSettingsKeys.kDownloaderConcurrency.camelCase] as int? ??
              d.downloaderConcurrency,
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
  int downloaderConcurrency;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        AppSettingsKeys.kUsagePolicy.camelCase: usagePolicy,
        AppSettingsKeys.kIgnoreSSLCertificate.camelCase: ignoreSSLCertificate,
        AppSettingsKeys.kAnimePreferredQuality.camelCase: animePreferredQuality,
        AppSettingsKeys.kAnimeFallbackQuality.camelCase: animeFallbackQuality,
        AppSettingsKeys.kAnimeDownloadDestination.camelCase:
            animeDownloadDestination,
        AppSettingsKeys.kAnimeDownloadSubDestination.camelCase:
            animeDownloadSubDestination,
        AppSettingsKeys.kAnimeDownloadFilename.camelCase: animeDownloadFilename,
        AppSettingsKeys.kMangaDownloadDestination.camelCase:
            mangaDownloadDestination,
        AppSettingsKeys.kMangaDownloadSubDestination.camelCase:
            mangaDownloadSubDestination,
        AppSettingsKeys.kMangaDownloadFilename.camelCase: mangaDownloadFilename,
        AppSettingsKeys.kMpvPath.camelCase: mpvPath,
        AppSettingsKeys.kDownloaderConcurrency.camelCase: downloaderConcurrency,
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
