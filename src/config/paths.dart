import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:utilx/utils.dart';
import '../utils/others.dart';
import 'meta.dart';

abstract class Paths {
  static late final String rDataDir;
  static late final String oDataDir;
  static late final String tmpDir;

  static late final String uDownloadsDir;
  static late final String uDocumentsDir;
  static late final String uVideosDir;
  static late final String uPicturesDir;

  static Future<void> initialize() async {
    rDataDir = await _getBaseDataDir();
    oDataDir = await _getDataDir();
    tmpDir = await _getTmpDataDir();

    await _initializeUserDirs();
  }

  static String get settingsFilePath => path.join(rDataDir, 'settings.json');
  static String get cacheFilePath => path.join(rDataDir, 'cache.json');
  static String get tenkaModulesDir => path.join(rDataDir, 'tenka_modules');

  static Future<String> _getBaseDataDir() async {
    switch (getCurrentPlatform()) {
      case SupportedPlatforms.windows:
        return path.join(Platform.environment['APPDATA']!, AppMeta.id);

      default:
        return path.join(_uHomeDir, '.${AppMeta.id}');
    }
  }

  static Future<String> _getDataDir() async {
    final String dir = path.join(rDataDir, 'data');
    FSUtils.ensureDirectory(Directory(dir));
    return dir;
  }

  static Future<String> _getTmpDataDir() async {
    final String dir = path.join(Directory.systemTemp.path, AppMeta.id);
    FSUtils.ensureDirectory(Directory(dir));
    return dir;
  }

  static Future<void> _initializeUserDirs() async {
    switch (getCurrentPlatform()) {
      case SupportedPlatforms.windows:
        uDownloadsDir = path.join(_uProfileDir, 'Downloads');
        uDocumentsDir = path.join(_uProfileDir, 'Documents');
        uVideosDir = path.join(_uProfileDir, 'Videos');
        uPicturesDir = path.join(_uProfileDir, 'Pictures');
        break;

      default:
        uDownloadsDir = Platform.environment['XDG_DOWNLOADS_DIR'] ??
            await _onlyIfDirExists(path.join(_uHomeDir, 'Downloads')) ??
            _defaultMediaDir;
        uDocumentsDir = Platform.environment['XDG_DOCUMENTS_DIR'] ??
            await _onlyIfDirExists(path.join(_uHomeDir, 'Documents')) ??
            _defaultMediaDir;
        uVideosDir = Platform.environment['XDG_VIDEOS_DIR'] ??
            await _onlyIfDirExists(path.join(_uHomeDir, 'Videos')) ??
            _defaultMediaDir;
        uPicturesDir = Platform.environment['XDG_PICTURES_DIR'] ??
            await _onlyIfDirExists(path.join(_uHomeDir, 'Pictures')) ??
            _defaultMediaDir;
    }
  }

  static String get _defaultMediaDir => path.join(rDataDir, 'Media');

  static String get _uProfileDir => Platform.environment['USERPROFILE']!;
  static String get _uHomeDir => Platform.environment['HOME']!;
}

Future<String?> _onlyIfDirExists(final String path) async {
  if (await Directory(path).exists()) return path;
  return null;
}
