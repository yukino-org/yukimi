import 'dart:io';
import 'core/manager.dart';

Future<void> main(final List<String> args) async {
  await AppManager.initialize();
  exitCode = await AppManager.execute(args);
  await AppManager.quit();
}
