import 'package:args/command_runner.dart';
import '../core/manager.dart';
import '../core/settings.dart';
import '../utils/console.dart';

class SettingsCommand extends Command<void> {
  SettingsCommand() {
    argParser.addFlag('ignoreSSLCertificate', defaultsTo: null);
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

    if (argResults!['ignoreSSLCertificate'] is bool) {
      AppSettings.settings.ignoreSSLCertificate =
          argResults!['ignoreSSLCertificate'] as bool;
    }

    await AppSettings.save();

    printTitle('Settings');
    print(
      'Ignore SSL Certificate: ${AppSettings.settings.ignoreSSLCertificate}',
    );
  }
}
