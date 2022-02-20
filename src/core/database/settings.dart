import 'dart:convert';
import 'dart:io';
import '../../config/paths.dart';
import '../../utils/atomic_file.dart';

class AppSettings {
  AppSettings({
    required this.ignoreSSLCertificate,
    required this.downloadDir,
  });

  factory AppSettings.defaultSettings() => AppSettings(
        ignoreSSLCertificate: false,
        downloadDir: null,
      );

  factory AppSettings.fromJson(final Map<dynamic, dynamic> json) {
    final AppSettings d = AppSettings.defaultSettings();

    return AppSettings(
      ignoreSSLCertificate:
          json['ignoreSSLCertificate'] as bool? ?? d.ignoreSSLCertificate,
      downloadDir: json['downloadDir'] as String? ?? d.downloadDir,
    );
  }

  bool ignoreSSLCertificate;
  String? downloadDir;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'ignoreSSLCertificate': ignoreSSLCertificate,
        'downloadDir': downloadDir,
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
