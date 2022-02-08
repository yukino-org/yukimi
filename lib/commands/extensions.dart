import 'package:args/command_runner.dart';
import './extensions/available.dart';
import './extensions/installed.dart';

class ExtensionsCommand extends Command<void> {
  ExtensionsCommand() {
    addSubcommand(AvailableExtensionsCommand());
    addSubcommand(InstalledExtensionsCommand());
  }

  @override
  final String name = 'extensions';

  @override
  final List<String> aliases = <String>['ext'];

  @override
  final String description = 'Extensions utility command.';
}
