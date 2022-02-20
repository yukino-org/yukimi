import 'dart:io';
import 'package:args/command_runner.dart';
import 'core/manager.dart';
import 'utils/command_exception.dart';
import 'utils/console.dart';

Future<void> main(final List<String> args) async {
  await AppManager.initialize();

  try {
    await AppManager.execute(args);
    exitCode = 0;
  } on UsageException catch (err) {
    exitCode = 1;
    printError(err.message);
    print(err.usage);
  } catch (err, stack) {
    exitCode = 1;
    if (AppManager.isJsonMode) {
      printErrorJson(err);
    } else if (err is CRTException) {
      printError(err);
    } else {
      printError(err, stack);
    }
  }

  await AppManager.quit();
}
