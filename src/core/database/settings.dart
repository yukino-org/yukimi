import 'dart:convert';
import 'dart:io';
import '../../config/paths.dart';
import '../../utils/atomic_file.dart';

class AppSettings {
  AppSettings._({
    this.ignoreSSLCertificate = false,
    this.preferredVideoQuality,
    this.fallbackVideoQuality,
    this.animeDestination,
    this.mangaDestination,
    this.mpvPath,
  });

  factory AppSettings.defaultSettings() => AppSettings._();

  factory AppSettings.fromJson(final Map<dynamic, dynamic> json) {
    final AppSettings d = AppSettings.defaultSettings();

    return AppSettings._(
      ignoreSSLCertificate:
          json['ignoreSSLCertificate'] as bool? ?? d.ignoreSSLCertificate,
      preferredVideoQuality:
          json['preferredVideoQuality'] as String? ?? d.preferredVideoQuality,
      fallbackVideoQuality:
          json['fallbackVideoQuality'] as String? ?? d.fallbackVideoQuality,
      animeDestination:
          json['animeDestination'] as String? ?? d.animeDestination,
      mangaDestination:
          json['mangaDestination'] as String? ?? d.mangaDestination,
      mpvPath: json['mpvPath'] as String? ?? d.mpvPath,
    );
  }

  bool ignoreSSLCertificate;
  String? preferredVideoQuality;
  String? fallbackVideoQuality;
  String? animeDestination;
  String? mangaDestination;
  String? mpvPath;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'ignoreSSLCertificate': ignoreSSLCertificate,
        'preferredVideoQuality': preferredVideoQuality,
        'fallbackVideoQuality': fallbackVideoQuality,
        'animeDestination': animeDestination,
        'mangaDestination': mangaDestination,
        'mpvPath': mpvPath,
      };

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
  }

  static Future<void> save() async {
    await AtomicFS.writeFileAtomically(
      File(Paths.settingsFilePath),
      utf8.encode(json.encode(settings.toJson())),
    );
  }
}
