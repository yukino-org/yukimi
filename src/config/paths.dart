import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:utilx/utils.dart';
import 'constants.dart';

abstract class Paths {
  static late final String rDataDir;
  static late final String oDataDir;
  static late final String tmpDir;

  static Future<void> initialize() async {
    rDataDir = await _getBaseDataDir();
    oDataDir = await _getDataDir();
    tmpDir = await _getTmpDataDir();
  }

  static String get chromiumDataDir => path.join(oDataDir, 'chromium');
  static String get settingsFilePath => path.join(rDataDir, 'settings.json');
  static String get cacheFilePath => path.join(rDataDir, 'cache.json');
  static String get tenkaModulesDir => path.join(rDataDir, 'tenka_modules');

  static Future<String> _getBaseDataDir() async {
    if (Platform.isWindows) {
      return path.join(Platform.environment['APPDATA']!, Constants.appId);
    }

    if (Platform.isLinux || Platform.isMacOS) {
      return path.join(Platform.environment['HOME']!, '.${Constants.appId}');
    }

    throw Exception('Unknown platform');
  }

  static Future<String> _getDataDir() async {
    final String dir = path.join(rDataDir, 'data');
    FSUtils.ensureDirectory(Directory(dir));
    return dir;
  }

  static Future<String> _getTmpDataDir() async {
    final String dir = path.join(Directory.systemTemp.path, Constants.appId);
    FSUtils.ensureDirectory(Directory(dir));
    return dir;
  }
}
