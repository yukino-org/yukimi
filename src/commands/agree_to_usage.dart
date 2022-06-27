import 'dart:io';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import '../config/constants.dart';
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
          Dye.dye('*', 'magenta').toString(),
          Dye.dye(k, 'lightCyan').toString(),
          Dye.dye('(', 'magenta').toString() +
              Dye.dye(v, 'magenta/underline').toString() +
              Dye.dye(')', 'magenta').toString(),
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

    final Map<String, String> guides = <String, String>{
      'Basic Guide': URLs.basicUsageGuide,
      'Advanced Guide': URLs.advancedUsageGuide,
    };

    println();
    print(
      '''
Welcome dear weeb! You can get started by running the ${Dye.dye('help', 'lightCyan')} command.
For more information, check out the below guides!
${guides.entries.map((final MapEntry<String, String> x) => '${Dye.dye('*', 'magenta')} ${x.key}: ${Dye.dye(x.value, 'lightCyan/underline')}').join('\n')}
'''
          .trim(),
    );
  }
}
