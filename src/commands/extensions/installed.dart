import 'package:args/command_runner.dart';
import 'package:extensions/metadata.dart';
import '../../core/extensions.dart';
import '../../core/manager.dart';
import '../../utils/console.dart';
import '_utils.dart';

class InstalledExtensionsCommand extends Command<void> {
  InstalledExtensionsCommand();

  @override
  final String name = 'installed';

  @override
  final List<String> aliases = <String>['list'];

  @override
  final String description = 'Display all the installed extensions.';

  @override
  Future<void> run() async {
    if (AppManager.isJsonMode) {
      printJson(
        ExtensionsManager.repository.installed.values
            .map((final EMetadata x) => x.toJson())
            .toList(),
      );
      return;
    }

    printTitle('Installed Extensions');

    int i = 1;
    for (final EMetadata x in ExtensionsManager.repository.installed.values) {
      print('$i. ${dyeStoreMetadata(x)}');

      i++;
    }
  }
}
