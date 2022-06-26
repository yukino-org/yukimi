import 'dart:io';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import '../core/commander.dart';
import '../core/database/settings.dart';
import '../core/manager.dart';
import '../utils/console.dart';
import '../utils/exceptions.dart';

class _Options extends CommandOptions {
  const _Options(final ArgResults results) : super(results);

  static const String kYes = 'yes';
  static const String kYesAbbr = 'y';
  bool get yes => get<bool>(kYes);
}

const String kAgreeToUsagePolicyCommand = 'agree-to-usage-policy';

class AgreeToUsagePolicyCommand extends Command<void> {
  AgreeToUsagePolicyCommand() {
    argParser.addFlag(
      _Options.kYes,
      abbr: _Options.kYesAbbr,
      negatable: false,
    );
  }

  @override
  final String name = kAgreeToUsagePolicyCommand;

  @override
  final List<String> aliases = <String>[];

  @override
  final String description = "Agree the app's usage policy.";

  @override
  bool get hidden => AppSettings.ready && AppSettings.settings.usagePolicy;

  @override
  Future<void> run() async {
    if (AppSettings.settings.usagePolicy) {
      return;
    }

    final _Options options = _Options(argResults!);

    final Map<String, String> policies = <String, String>{
      'Tenka Usage Policy':
          'https://yukino-org.github.io/wiki/tenka/disclaimer/',
    };

    if (AppManager.isJsonMode) {
      if (!options.yes) {
        throw CommandException.missingOption(_Options.kYes);
      }

      printJson(<dynamic, dynamic>{
        'success': true,
        'policies': policies,
      });
      return;
    }

    printHeading('Usage Policy');
    print('By using this application, you agree to the below usage policies.');
    policies.forEach(
      (final String k, final String v) => print(
        <String>[
          Dye.dye('*', 'dark').toString(),
          Dye.dye(k, 'lightCyan').toString(),
          Dye.dye('(', 'dark').toString() +
              Dye.dye(v, 'dark/underline').toString() +
              Dye.dye(')', 'dark').toString(),
        ].join(' '),
      ),
    );
    print(' ');

    if (!options.yes) {
      stdout.write('I agree to the above policies [Y/n]: ');

      final String input = stdin.readLineSync()?.trim().toLowerCase() ?? '';
      if (!<String>['y', 'yes'].contains(input)) {
        print('You did not agree to the usage policy. Exiting...');
        return;
      }
    }

    AppSettings.settings.usagePolicy = true;
    await AppSettings.save();

    print(
      'Welcome dear weeb! You can get started by running the ${Dye.dye('help', 'lightCyan')} command. For more information, check out our guides!',
    );
  }
}
