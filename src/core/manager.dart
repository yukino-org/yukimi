import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import '../commands/anime.dart';
import '../commands/extensions.dart';
import '../commands/settings.dart';
import '../commands/version.dart';
import '../config/constants.dart';
import '../config/paths.dart';
import 'database/settings.dart';
import 'extensions.dart';

enum AppMode {
  json,
  normal,
}

abstract class AppManager {
  static bool initialized = false;
  static bool disposed = false;

  static late CommandRunner<void> runner;
  static ArgResults? globalArgResults;

  static Future<void> initialize() async {
    if (initialized) return;
    initialized = true;

    await Paths.initialize();
    await AppSettings.initialize();
    await ExtensionsManager.initialize();

    runner = CommandRunner<void>(Constants.appId, Constants.description);
    runner.argParser
      ..addFlag('json', negatable: false)
      ..addFlag('color', defaultsTo: true);
    runner
      ..addCommand(AnimeCommand())
      ..addCommand(ExtensionsCommand())
      ..addCommand(SettingsCommand())
      ..addCommand(VersionCommand());

    ProcessSignal.sigint.watch().listen((final ProcessSignal _) async {
      await quit();
    });
  }

  static Future<void> execute(final List<String> args) async {
    globalArgResults = runner.parse(args);
    await runner.runCommand(globalArgResults!);
  }

  static Future<void> dispose() async {
    if (disposed) return;
    disposed = true;

    await ExtensionsManager.dispose();
  }

  static Future<void> quit() async {
    await AppManager.dispose();
    exit(exitCode);
  }

  static bool get isJsonMode => globalArgResults!['json'] as bool;

  static AppMode get mode {
    if (isJsonMode) {
      return AppMode.json;
    }

    return AppMode.normal;
  }
}
