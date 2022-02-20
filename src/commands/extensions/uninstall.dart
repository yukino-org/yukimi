import 'package:args/command_runner.dart';
import 'package:extensions/metadata.dart';
import '../../core/extensions.dart';
import '../../core/manager.dart';
import '../../utils/console.dart';
import '_utils.dart';

class UninstallExtensionsCommand extends Command<void> {
  UninstallExtensionsCommand();

  @override
  final String name = 'uninstall';

  @override
  final List<String> aliases = <String>['remove', 'd', 'rm'];

  @override
  final String description = 'Uninstall one or more extensions.';

  @override
  Future<void> run() async {
    final List<String> restArgs =
        argResults!.rest.map((final String x) => x.toLowerCase()).toList();

    final List<EMetadata> uninstalled = <EMetadata>[];

    for (final String x in restArgs) {
      final String? id = ExtensionsManager.repository.storeNameIdMap[x];
      if (id != null) {
        final EMetadata storeMetadata =
            ExtensionsManager.repository.store.extensions[id]!;

        await ExtensionsManager.repository.uninstall(storeMetadata);

        uninstalled.add(storeMetadata);
      }
    }

    if (AppManager.isJsonMode) {
      printJson(<dynamic, dynamic>{
        'uninstalled':
            uninstalled.map((final EMetadata x) => x.toJson()).toList(),
      });
      return;
    }

    printTitle('Uninstalled');

    int i = 1;
    for (final EMetadata x in uninstalled) {
      print('$i. ${dyeStoreMetadata(x)}');
      i++;
    }
  }
}
