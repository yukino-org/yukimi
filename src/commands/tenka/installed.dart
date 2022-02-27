import 'package:args/command_runner.dart';
import 'package:tenka/tenka.dart';
import '../../core/manager.dart';
import '../../core/tenka.dart';
import '../../utils/console.dart';
import '_utils.dart';

class InstalledModulesCommand extends Command<void> {
  InstalledModulesCommand();

  @override
  final String name = 'installed';

  @override
  final List<String> aliases = <String>['list'];

  @override
  final String description = 'Display all the installed Tenka modules.';

  @override
  Future<void> run() async {
    if (AppManager.isJsonMode) {
      printJson(
        TenkaManager.repository.installed.values
            .map((final TenkaMetadata x) => x.toJson())
            .toList(),
      );
      return;
    }

    printTitle('Installed Tenka Modules');

    int i = 1;
    for (final TenkaMetadata x in TenkaManager.repository.installed.values) {
      print('$i. ${dyeTenkaMetadata(x)}');

      i++;
    }
  }
}
