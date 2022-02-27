import 'package:args/command_runner.dart';
import '../commands/anime.dart';
import '../commands/settings.dart';
import '../commands/tenka.dart';
import '../commands/terminal.dart';
import '../commands/version.dart';
import '../config/constants.dart';

abstract class AppCommander {
  static CommandRunner<void> get() {
    final CommandRunner<void> runner =
        CommandRunner<void>(Constants.appId, Constants.description);

    runner.argParser
      ..addFlag('json', negatable: false)
      ..addFlag('color', defaultsTo: true);

    runner
      ..addCommand(AnimeCommand())
      ..addCommand(TenkaCommand())
      ..addCommand(SettingsCommand())
      ..addCommand(TerminalCommand())
      ..addCommand(VersionCommand());

    return runner;
  }
}
