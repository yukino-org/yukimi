import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:shlex/shlex.dart' as shlex;
import '../core/manager.dart';
import '../utils/console.dart';

class TerminalCommand extends Command<void> {
  TerminalCommand();

  @override
  final String name = 'terminal';

  @override
  final List<String> aliases = <String>['-t'];

  @override
  final String description = 'Opens the app in a sub-terminal.';

  @override
  Future<void> run() async {
    print(Dye.dye('Type $exitCommand to exit the terminal', 'dark'));

    bool proceed = true;
    while (proceed) {
      stdout.write(Dye.dye('> ', 'dark'));
      final String? line = stdin.readLineSync();

      if (line == exitCommand) {
        proceed = false;
        break;
      }

      if (line?.isNotEmpty ?? false) {
        await AppManager.execute(shlex.split(line!));
      }

      if (line == null) stdout.writeln();
    }
  }

  static const String exitCommand = '.exit';
}
