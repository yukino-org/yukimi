import 'package:args/command_runner.dart';
import 'package:tenka/tenka.dart';
import '../../core/manager.dart';
import '../../core/tenka.dart';
import '../../utils/console.dart';
import '_utils.dart';

class InstallModulesCommand extends Command<void> {
  InstallModulesCommand();

  @override
  final String name = 'install';

  @override
  final List<String> aliases = <String>['i', 'add'];

  @override
  final String description = 'Install one or more Tenka module.';

  @override
  Future<void> run() async {
    final List<String> restArgs =
        argResults!.rest.map((final String x) => x.toLowerCase()).toList();

    final List<TenkaMetadata> installed = <TenkaMetadata>[];

    for (final String x in restArgs) {
      final String? id = TenkaManager.repository.storeNameIdMap[x];
      if (id != null) {
        await TenkaManager.repository
            .install(TenkaManager.repository.store.modules[id]!);

        installed.add(TenkaManager.repository.installed[id]!);
      }
    }

    if (AppManager.isJsonMode) {
      printJson(<dynamic, dynamic>{
        'installed':
            installed.map((final TenkaMetadata x) => x.toJson()).toList(),
      });
      return;
    }

    printTitle('Installed');

    int i = 1;
    for (final TenkaMetadata x in installed) {
      print('$i. ${dyeTenkaMetadata(x)}');

      i++;
    }
  }
}
