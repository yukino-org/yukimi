import 'package:args/command_runner.dart';
import 'package:tenka/tenka.dart';
import '../../core/manager.dart';
import '../../core/tenka.dart';
import '../../utils/console.dart';
import '_utils.dart';

class TenkaStoreCommand extends Command<void> {
  TenkaStoreCommand();

  @override
  final String name = 'store';

  @override
  final List<String> aliases = <String>['all'];

  @override
  final String description =
      'Display all the available extensions on the store.';

  @override
  Future<void> run() async {
    if (AppManager.isJsonMode) {
      printJson(
        TenkaManager.repository.store.modules.map(
          (final String i, final TenkaMetadata x) =>
              MapEntry<String, Map<dynamic, dynamic>>(i, x.toJson()),
        ),
      );
      return;
    }

    printHeading('Available Tenka Modules');

    int i = 1;
    for (final TenkaMetadata x
        in TenkaManager.repository.store.modules.values) {
      print('$i. ${dyeTenkaMetadata(x)}');

      i++;
    }
  }
}
