import 'package:args/command_runner.dart';
import '../config/meta.g.dart';
import '../utils/console.dart';

class VersionCommand extends Command<void> {
  VersionCommand() {
    argParser.addFlag('json', negatable: false);
  }

  @override
  final String name = 'version';

  @override
  final List<String> aliases = <String>['-v', '--version'];

  @override
  final String description = 'Display the app information.';

  @override
  Future<void> run() async {
    if (argResults!['json'] as bool) {
      printJson(<dynamic, dynamic>{
        'version': GeneratedAppMeta.version,
      });
      return;
    }

    print('v${GeneratedAppMeta.version}');
  }
}
