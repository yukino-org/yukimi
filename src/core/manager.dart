import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import '../commands/agree_to_usage.dart';
import '../config/meta.dart';
import '../config/paths.dart';
import '../utils/console.dart';
import '../utils/exceptions.dart';
import 'commander.dart';
import 'database/cache.dart';
import 'database/settings.dart';
import 'tenka.dart';

enum AppMode {
  json,
  normal,
}

const int kSuccessExitCode = 0;
const int kFailureExitCode = 1;

abstract class AppManager {
  static bool initialized = false;
  static bool disposed = false;
  static bool greeted = false;

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

      final bool isAgreeToUsagePolicyCommand =
          globalArgResults!.arguments.isNotEmpty &&
              globalArgResults!.arguments.first == kAgreeToUsagePolicyCommand;

      if (!AppSettings.settings.usagePolicy && !isAgreeToUsagePolicyCommand) {
        print(
          'You must agree to the usage policy to use this application.',
        );
        print(
          'Run the ${Dye.dye(kAgreeToUsagePolicyCommand, 'lightCyan')} command to agree to the usage policy.',
        );

        return kFailureExitCode;
      }

      await greet();
      await runner.runCommand(globalArgResults!);

      return kSuccessExitCode;
    } on UsageException catch (err) {
      printError(err.message);
      print(err.usage);
    } catch (err, stack) {
      if (AppManager.isJsonMode) {
        printErrorJson(err);
      } else if (err is CommandException) {
        printError(err);
      } else {
        printError(err, stack);
      }
    }

    return kFailureExitCode;
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

  static Future<void> greet() async {
    if (isJsonMode || greeted) return;

    printAligned(
      Dye.dye('${AppMeta.name} v${GeneratedAppMeta.version}', 'lightCyan')
          .toString(),
    );
    printAligned(Dye.dye(AppMeta.github, 'dark/underline').toString());
    println();

    await checkForUpdates();
    greeted = true;
  }

  static Future<void> checkForUpdates() async {
    try {
      final http.Response resp =
          await http.get(Uri.parse(AppMeta.lastestVersionEndpoint));

      final String latestVersion = resp.body;
      if (GeneratedAppMeta.version != latestVersion) {
        print(
          'New version available! (${Dye.dye(GeneratedAppMeta.version, 'lightCyan')} -> ${Dye.dye(latestVersion, 'lightCyan')})',
        );
        println();
      }
    } catch (_) {
      printWarning('Failed to check for updates.');
      println();
    }
  }

  static bool get isJsonMode => globalArgResults!['json'] as bool;

  static AppMode get mode {
    if (isJsonMode) {
      return AppMode.json;
    }

    return AppMode.normal;
  }
}
