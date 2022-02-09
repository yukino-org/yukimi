import 'package:args/command_runner.dart';
import 'package:extensions/metadata.dart';
import './_utils.dart';
import '../../core/extensions.dart';
import '../../core/manager.dart';
import '../../utils/console.dart';

class InstallExtensionsCommand extends Command<void> {
  InstallExtensionsCommand();

  @override
  final String name = 'install';

  @override
  final List<String> aliases = <String>['i', 'add'];

  @override
  final String description = 'Install one or more extensions.';

  @override
  Future<void> run() async {
    final List<String> restArgs =
        argResults!.rest.map((final String x) => x.toLowerCase()).toList();

    final List<EStoreMetadata> installed = <EStoreMetadata>[];

    for (final String x in restArgs) {
      final String? id = ExtensionsManager.repository.storeNameIdMap[x];
      if (id != null) {
        await ExtensionsManager.repository
            .install(ExtensionsManager.repository.store.extensions[id]!);

        installed.add(ExtensionsManager.repository.extensions[id]!);
      }
    }

    if (AppManager.isJsonMode) {
      printJson(<dynamic, dynamic>{
        'installed':
            installed.map((final EStoreMetadata x) => x.toJson()).toList(),
      });
      return;
    }

    printTitle('Installed');

    int i = 1;
    for (final EStoreMetadata x in installed) {
      print('$i. ${dyeStoreMetadata(x)}');

      i++;
    }
  }
}
