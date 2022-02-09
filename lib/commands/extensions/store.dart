import 'package:args/command_runner.dart';
import 'package:extensions/metadata.dart';
import './_utils.dart';
import '../../core/extensions.dart';
import '../../core/manager.dart';
import '../../utils/console.dart';

class ExtensionsStoreCommand extends Command<void> {
  ExtensionsStoreCommand();

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
        ExtensionsManager.repository.store.extensions.map(
          (final String i, final EStoreMetadata x) =>
              MapEntry<String, Map<dynamic, dynamic>>(i, x.toJson()),
        ),
      );
      return;
    }

    printTitle('Available Extensions');

    int i = 1;
    for (final EStoreMetadata x
        in ExtensionsManager.repository.store.extensions.values) {
      print('$i. ${dyeStoreMetadata(x)}');

      i++;
    }
  }
}
