import 'package:args/command_runner.dart';
import 'package:extensions/metadata.dart';
import '../../core/extensions.dart';
import '../../utils/console.dart';

class InstalledExtensionsCommand extends Command<void> {
  InstalledExtensionsCommand() {
    argParser.addFlag('json', negatable: false);
  }

  @override
  final String name = 'installed';

  @override
  final List<String> aliases = <String>['all'];

  @override
  final String description = 'Display all the installed extensions.';

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
  }
}
