import 'dart:io';
import 'package:args/command_runner.dart';
import '../commands/anime.dart';
import '../commands/manga.dart';
import '../commands/settings.dart';
import '../commands/tenka.dart';
import '../commands/terminal.dart';
import '../commands/version.dart';
import '../config/constants.dart';
import '../utils/command_exception.dart';
import 'database/settings.dart';

abstract class AppCommander {
  static Map<String, String Function()> argVariables =
      <String, String Function()>{
    'animeDir': () =>
        AppSettings.settings.animeDestination ?? Directory.current.toString(),
    'mangaDir': () =>
        AppSettings.settings.mangaDestination ?? Directory.current.toString(),
  };

  static String replaceArgVariables(final String value) =>
      value.replaceAllMapped(
        RegExp(r'\${([^}]+)}'),
        (final Match x) {
          final String key = x.group(1)!;
          if (!argVariables.containsKey(key)) {
            throw CRTException.unknownArgumentVariable(key);
          }

          return argVariables[key]!();
        },
      );

  static CommandRunner<void> get() {
    final CommandRunner<void> runner =
        CommandRunner<void>(Constants.appId, Constants.description);

    runner.argParser
      ..addFlag('json', negatable: false)
      ..addFlag('color', defaultsTo: true);

    runner
      ..addCommand(AnimeCommand())
      ..addCommand(MangaCommand())
      ..addCommand(TenkaCommand())
      ..addCommand(SettingsCommand())
      ..addCommand(TerminalCommand())
      ..addCommand(VersionCommand());

    return runner;
  }
}
