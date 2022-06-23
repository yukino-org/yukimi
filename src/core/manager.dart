import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import '../config/meta.dart';
import '../config/paths.dart';
import '../utils/command_exception.dart';
import '../utils/console.dart';
import 'commander.dart';
import 'database/cache.dart';
import 'database/settings.dart';
import 'tenka.dart';

enum AppMode {
  json,
  normal,
}

abstract class AppManager {
  static bool initialized = false;
  static bool disposed = false;
  static bool checkedForUpdates = false;

  static late CommandRunner<void> runner;
  static ArgResults? globalArgResults;
  static StreamSubscription<ProcessSignal>? sigintSubscription;
  static final List<Future<void>> pendingCriticals = <Future<void>>[];

  static Future<void> initialize() async {
    if (initialized) return;
    initialized = true;

    await Paths.initialize();
    await Cache.initialize();
    await AppSettings.initialize();
    await TenkaManager.initialize();

    runner = AppCommander.get();

    sigintSubscription =
        ProcessSignal.sigint.watch().listen((final ProcessSignal _) {
      pendingCriticals.add(quit());
    });
  }

  static Future<int> execute(final List<String> args) async {
    try {
      globalArgResults = runner.parse(args);

      await checkForUpdates();
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

    await TenkaManager.dispose();
  }

  static Future<void> quit() async {
    await AppManager.dispose();
    await sigintSubscription?.cancel();
    sigintSubscription = null;
    await waitForCriticals();
    exit(exitCode);
  }

  static Future<void> waitForCriticals() async {
    await Future.wait(pendingCriticals);
  }

  static Future<void> checkForUpdates() async {
    if (isJsonMode || checkedForUpdates) return;

    try {
      final http.Response resp =
          await http.get(Uri.parse(AppMeta.lastestVersionEndpoint));

      final String latestVersion = resp.body;
      if (GeneratedAppMeta.version != latestVersion) {
        print(
          'New version available! ${Dye.dye(GeneratedAppMeta.version, 'cyan')} -> ${Dye.dye(latestVersion, 'cyan')}\n',
        );
      }
    } catch (_) {
      printWarning('Failed to check for updates.\n');
    }

    checkedForUpdates = true;
  }

  static bool get isJsonMode => globalArgResults!['json'] as bool;

  static AppMode get mode {
    if (isJsonMode) {
      return AppMode.json;
    }

    return AppMode.normal;
  }
}