import 'package:args/command_runner.dart';
import 'package:tenka/tenka.dart';
import '../../core/manager.dart';
import '../../core/tenka.dart';
import '../../utils/console.dart';
import '_utils.dart';

class UninstallModulesCommand extends Command<void> {
  UninstallModulesCommand();

  @override
  final String name = 'uninstall';

  @override
  final List<String> aliases = <String>['remove', 'd', 'rm'];

  @override
  final String description = 'Uninstall one or more Tenka modules.';

  @override
  Future<void> run() async {
    final List<String> restArgs =
        argResults!.rest.map((final String x) => x.toLowerCase()).toList();

    final List<TenkaMetadata> uninstalled = <TenkaMetadata>[];

    for (final String x in restArgs) {
      final String? id = TenkaManager.repository.storeNameIdMap[x];
      if (id != null) {
        final TenkaMetadata metadata =
            TenkaManager.repository.store.modules[id]!;

        await TenkaManager.repository.uninstall(metadata);
        uninstalled.add(metadata);
      }
    }

    if (AppManager.isJsonMode) {
      printJson(<dynamic, dynamic>{
        'uninstalled':
            uninstalled.map((final TenkaMetadata x) => x.toJson()).toList(),
      });
      return;
    }

    printTitle('Uninstalled');

    int i = 1;
    for (final TenkaMetadata x in uninstalled) {
      print('$i. ${dyeTenkaMetadata(x)}');
      i++;
    }
  }
}
