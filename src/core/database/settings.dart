import 'dart:convert';
import 'dart:io';
import 'package:tenka/tenka.dart';
import '../../config/paths.dart';
import '../../utils/atomic_file.dart';

class AppSettings {
  AppSettings._({
    this.usagePolicy = false,
    this.ignoreSSLCertificate = false,
    this.animePreferredQuality = '',
    this.animeFallbackQuality = '',
    this.animeDestination = '',
    this.mangaDestination = '',
    this.mpvPath,
  });

  factory AppSettings.defaultSettings() => AppSettings._(
        animePreferredQuality: Quality.get(Qualities.q_720p).code,
        animeFallbackQuality: Quality.get(Qualities.unknown).code,
        animeDestination: Paths.uDownloadsDir,
        mangaDestination: Paths.uDownloadsDir,
      );

  factory AppSettings.fromJson(final Map<dynamic, dynamic> json) {
    final AppSettings d = AppSettings.defaultSettings();

    return AppSettings._(
      usagePolicy: json['usagePolicy'] as bool? ?? d.usagePolicy,
      ignoreSSLCertificate:
          json['ignoreSSLCertificate'] as bool? ?? d.ignoreSSLCertificate,
      animePreferredQuality:
          json['animePreferredQuality'] as String? ?? d.animePreferredQuality,
      animeFallbackQuality:
          json['animeFallbackQuality'] as String? ?? d.animeFallbackQuality,
      animeDestination:
          json['animeDestination'] as String? ?? d.animeDestination,
      mangaDestination:
          json['mangaDestination'] as String? ?? d.mangaDestination,
      mpvPath: json['mpvPath'] as String? ?? d.mpvPath,
    );
  }

  bool usagePolicy;
  bool ignoreSSLCertificate;
  String animePreferredQuality;
  String animeFallbackQuality;
  String animeDestination;
  String mangaDestination;
  String? mpvPath;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'usagePolicy': usagePolicy,
        'ignoreSSLCertificate': ignoreSSLCertificate,
        'animePreferredQuality': animePreferredQuality,
        'animeFallbackQuality': animeFallbackQuality,
        'animeDestination': animeDestination,
        'mangaDestination': mangaDestination,
        'mpvPath': mpvPath,
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
