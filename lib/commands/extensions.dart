import 'package:args/command_runner.dart';
import './extensions/install.dart';
import './extensions/installed.dart';
import './extensions/store.dart';
import './extensions/uninstall.dart';

class ExtensionsCommand extends Command<void> {
  ExtensionsCommand() {
    addSubcommand(ExtensionsStoreCommand());
    addSubcommand(InstallExtensionsCommand());
    addSubcommand(InstalledExtensionsCommand());
    addSubcommand(UninstallExtensionsCommand());
  }

  @override
  final String name = 'extensions';

  @override
  final List<String> aliases = <String>['ext'];

  @override
  final String description = 'Extensions utility command.';
}
