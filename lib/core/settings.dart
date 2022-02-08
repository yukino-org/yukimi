import 'dart:convert';
import 'dart:io';
import '../config/paths.dart';

class AppSettings {
  AppSettings({
    required this.ignoreSSLCertificate,
  });

  factory AppSettings.defaultSettings() =>
      AppSettings(ignoreSSLCertificate: false);

  factory AppSettings.fromJson(final Map<dynamic, dynamic> json) {
    final AppSettings d = AppSettings.defaultSettings();

    return AppSettings(
      ignoreSSLCertificate:
          json['ignoreSSLCertificate'] as bool? ?? d.ignoreSSLCertificate,
    );
  }

  bool ignoreSSLCertificate;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'ignoreSSLCertificate': ignoreSSLCertificate,
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
    await File(Paths.settingsFilePath)
        .writeAsString(json.encode(settings.toJson()));
  }
}
