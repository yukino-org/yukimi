import 'package:args/command_runner.dart';
import 'package:extensions/metadata.dart';
import './_utils.dart';
import '../../core/extensions.dart';
import '../../core/manager.dart';
import '../../utils/console.dart';

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

    final List<EStoreMetadata> uninstalled = <EStoreMetadata>[];

    for (final String x in restArgs) {
      final String? id = ExtensionsManager.repository.storeNameIdMap[x];
      if (id != null) {
        final EStoreMetadata storeMetadata =
            ExtensionsManager.repository.store.extensions[id]!;

        await ExtensionsManager.repository.uninstall(storeMetadata);

        uninstalled.add(storeMetadata);
      }
    }

    if (AppManager.isJsonMode) {
      printJson(<dynamic, dynamic>{
        'uninstalled':
            uninstalled.map((final EStoreMetadata x) => x.toJson()).toList(),
      });
      return;
    }

    printTitle('Uninstalled');

    int i = 1;
    for (final EStoreMetadata x in uninstalled) {
      print('$i. ${dyeStoreMetadata(x)}');
      i++;
    }
  }
}
