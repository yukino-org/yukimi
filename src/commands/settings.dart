import 'package:args/command_runner.dart';
import '../core/database/settings.dart';
import '../core/manager.dart';
import '../utils/console.dart';

class SettingsCommand extends Command<void> {
  SettingsCommand() {
    argParser
      ..addFlag('default', aliases: <String>['reset'])
      ..addFlag('ignoreSSLCertificate', defaultsTo: null)
      ..addOption(
        'animeDestination',
        aliases: <String>['animeDir'],
      )
      ..addOption(
        'mangaDestination',
        aliases: <String>['mangaDir'],
      );
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

    int changes = 0;

    if (argResults!['default'] as bool) {
      AppSettings.settings = AppSettings.defaultSettings();
      changes++;
    }

    if (argResults!['ignoreSSLCertificate'] is bool) {
      AppSettings.settings.ignoreSSLCertificate =
          argResults!['ignoreSSLCertificate'] as bool;
      changes++;
    }

    if (argResults!['animeDestination'] is String) {
      AppSettings.settings.animeDestination =
          argResults!['animeDestination'] as String;
      changes++;
    }

    if (argResults!['mangaDestination'] is String) {
      AppSettings.settings.mangaDestination =
          argResults!['mangaDestination'] as String;
      changes++;
    }

    if (changes > 0) {
      await AppSettings.save();
    }

    printTitle('Settings');

    final Map<String, String> mapped = <String, String>{
      'Ignore SSL Certificate':
          AppSettings.settings.ignoreSSLCertificate.toString(),
      'Anime Download Destination':
          AppSettings.settings.animeDestination ?? '-',
      'Manga Download Destination':
          AppSettings.settings.mangaDestination ?? '-',
    };

    mapped.forEach(
      (final String k, final String v) => print(DyeUtils.dyeKeyValue(k, v)),
    );
  }
}
