import 'dart:io';
import 'package:path/path.dart' as path;
import 'constants.dart';

abstract class Paths {
  static late final String baseDataDir;
  static late final String dataDir;

  static Future<void> initialize() async {
    baseDataDir = await _getBaseAppDataDir();

    dataDir = path.join(baseDataDir, 'data');

    final Directory _dataDir = Directory(dataDir);
    if (!(await _dataDir.exists())) {
      await _dataDir.create(recursive: true);
    }
  }

  static String get chromiumDataDir => path.join(dataDir, 'chromium');

  static String get settingsFilePath => path.join(baseDataDir, 'settings.json');

  static String get extensionsDir => path.join(baseDataDir, 'extensions');

  static Future<String> _getBaseAppDataDir() async {
    if (Platform.isWindows) {
      return path.join(Platform.environment['APPDATA']!, Constants.appId);
    }

    if (Platform.isLinux || Platform.isMacOS) {
      return path.join(Platform.environment['HOME']!, '.${Constants.appId}');
    }

    throw Exception('Unknown platform');
  }
}
