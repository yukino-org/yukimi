import 'dart:io';
import 'package:args/command_runner.dart';
import './core/manager.dart';

Future<void> main(final List<String> args) async {
  await AppManager.initialize();

  try {
    await AppManager.execute(args);
    exitCode = 0;
  } on UsageException catch (err) {
    print(err);
    exitCode = 1;
  } catch (err) {
    exitCode = 1;
    rethrow;
  }

  exit(exitCode);
}
