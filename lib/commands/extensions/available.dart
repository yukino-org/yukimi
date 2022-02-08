import 'package:args/command_runner.dart';
import 'package:extensions/metadata.dart';
import '../../core/extensions.dart';
import '../../utils/console.dart';

class AvailableExtensionsCommand extends Command<void> {
  AvailableExtensionsCommand() {
    argParser.addFlag('json', negatable: false);
  }

  @override
  final String name = 'available';

  @override
  final List<String> aliases = <String>['store'];

  @override
  final String description =
      'Display all the available extensions on the store.';

  @override
  Future<void> run() async {
    if (argResults!['json'] as bool) {
      printJson(
        ExtensionsManager.repository.store.extensions
            .map((final EStoreMetadata x) => x.toJson())
            .toList(),
      );
      return;
    }

    printTitle('Available Extensions');

    int i = 1;
    for (final EStoreMetadata x
        in ExtensionsManager.repository.store.extensions) {
      print(
        '$i. ${Dye.dye(x.metadata.name, 'cyan')} ${Dye.dye('v${x.version}', 'darkGrey')}',
      );

      i++;
    }
  }
}
