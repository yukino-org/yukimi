import 'package:args/command_runner.dart';
import 'tenka/install.dart';
import 'tenka/installed.dart';
import 'tenka/store.dart';
import 'tenka/uninstall.dart';

class TenkaCommand extends Command<void> {
  TenkaCommand() {
    addSubcommand(TenkaStoreCommand());
    addSubcommand(InstallModulesCommand());
    addSubcommand(InstalledModulesCommand());
    addSubcommand(UninstallModulesCommand());
  }

  @override
  final String name = 'tenka';

  @override
  final List<String> aliases = <String>['extensions', 'ext'];

  @override
  final String description = 'Tenka modules utility command.';
}
