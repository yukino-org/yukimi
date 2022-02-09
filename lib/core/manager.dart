import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import './extensions.dart';
import './settings.dart';
import '../commands/anime.dart';
import '../commands/extensions.dart';
import '../commands/settings.dart';
import '../commands/version.dart';
import '../config/constants.dart';
import '../config/paths.dart';

abstract class AppManager {
  static late CommandRunner<void> runner;
  static ArgResults? globalArgResults;

  static Future<void> initialize() async {
    await Paths.initialize();
    await AppSettings.initialize();
    await ExtensionsManager.initialize();

    runner = CommandRunner<void>(Constants.appId, Constants.description);
    runner.argParser.addFlag('json', negatable: false);
    runner
      ..addCommand(AnimeCommand())
      ..addCommand(ExtensionsCommand())
      ..addCommand(SettingsCommand())
      ..addCommand(VersionCommand());
  }

  static Future<void> execute(final List<String> args) async {
    globalArgResults = runner.parse(args);
    await runner.runCommand(globalArgResults!);
  }

  static bool get isJsonMode => globalArgResults!['json'] as bool;
}
