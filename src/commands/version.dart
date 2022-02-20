import 'package:args/command_runner.dart';
import '../config/meta.dart';
import '../core/manager.dart';
import '../utils/console.dart';

class VersionCommand extends Command<void> {
  VersionCommand();

  @override
  final String name = 'version';

  @override
  final List<String> aliases = <String>['-v', '--version'];

  @override
  final String description = 'Display the app information.';

  @override
  Future<void> run() async {
    if (AppManager.isJsonMode) {
      printJson(<dynamic, dynamic>{
        'version': 'v${GeneratedAppMeta.version}',
        'patreon': AppMeta.patreon,
        'github': AppMeta.github,
      });
      return;
    }

    printTitle('Information');
    print(DyeUtils.dyeKeyValue('Version', 'v${GeneratedAppMeta.version}'));
    print(
      DyeUtils.dyeKeyValue(
        'Patreon',
        AppMeta.patreon,
        additionalValueStyles: 'underline',
      ),
    );
    print(
      DyeUtils.dyeKeyValue(
        'GitHub',
        AppMeta.github,
        additionalValueStyles: 'underline',
      ),
    );
  }
}
