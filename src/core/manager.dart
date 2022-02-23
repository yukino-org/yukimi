import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import '../config/paths.dart';
import '../utils/command_exception.dart';
import '../utils/console.dart';
import 'commander.dart';
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
  static StreamSubscription<ProcessSignal>? sigintSubscription;
  static final List<Future<void>> pendingCriticals = <Future<void>>[];

  static Future<void> initialize() async {
    if (initialized) return;
    initialized = true;

    await Paths.initialize();
    await AppSettings.initialize();
    await ExtensionsManager.initialize();

    runner = AppCommander.get();

    sigintSubscription =
        ProcessSignal.sigint.watch().listen((final ProcessSignal _) {
      pendingCriticals.add(quit());
    });
  }

  static Future<int> execute(final List<String> args) async {
    try {
      globalArgResults = runner.parse(args);
      await runner.runCommand(globalArgResults!);

      return 0;
    } on UsageException catch (err) {
      printError(err.message);
      print(err.usage);
    } catch (err, stack) {
      if (AppManager.isJsonMode) {
        printErrorJson(err);
      } else if (err is CRTException) {
        printError(err);
      } else {
        printError(err, stack);
      }
    }

    return 1;
  }

  static Future<void> dispose() async {
    if (disposed) return;
    disposed = true;

    print('dispose start');
    await ExtensionsManager.dispose();
    print('dispose end');
  }

  static Future<void> quit() async {
    await AppManager.dispose();
    await sigintSubscription?.cancel();
    sigintSubscription = null;
    await waitForCriticals();
    exit(exitCode);
  }

  static bool get isJsonMode => globalArgResults!['json'] as bool;

  static AppMode get mode {
    if (isJsonMode) {
      return AppMode.json;
    }

    return AppMode.normal;
  }

  static Future<void> waitForCriticals() async {
    await Future.wait(pendingCriticals);
  }
}
