import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:utilx/utils.dart';
import '../src/core/commander.dart';

final String outputPath = path.join(Directory.current.path, 'dist/docs.md');

class CommandDoc {
  const CommandDoc(
    this.command, {
    required this.fullCommand,
    required this.level,
  });

  final Command<void> command;
  final String fullCommand;
  final int level;

  @override
  String toString() => basic(
        level: level,
        fullCommand: fullCommand,
        usage: command.usage,
      );

  static String basic({
    required final int level,
    required final String fullCommand,
    required final String usage,
  }) =>
      '''
${List<String>.filled(level, '#').join()} $fullCommand

```
$usage
```
''';
}

final Map<String, CommandDoc> commands = <String, CommandDoc>{};

Future<void> main() async {
  final CommandRunner<void> runner = AppCommander.get();
  final String fullCommand = runner.executableName;

  for (final Command<void> x in runner.commands.values) {
    final String xFullCommand = '$fullCommand ${x.name}';

    if (!commands.containsKey(xFullCommand)) {
      handleCommand(x, level: 2, fullCommand: xFullCommand);
    }
  }

  final String docs = <String>[
    CommandDoc.basic(
      level: 1,
      fullCommand: fullCommand,
      usage: runner.usage,
    ),
    ...commands.values.map((final CommandDoc value) => value.toString()),
  ].join('\n');

  final File outputFile = File(outputPath);
  await FSUtils.ensureFile(outputFile);
  await outputFile.writeAsString(docs);
}

void handleCommand(
  final Command<void> command, {
  required final int level,
  required final String fullCommand,
}) {
  commands[fullCommand] = CommandDoc(
    command,
    level: level,
    fullCommand: fullCommand,
  );

  for (final Command<void> x in command.subcommands.values) {
    final String xFullCommand = '$fullCommand ${x.name}';

    if (!commands.containsKey(xFullCommand)) {
      handleSubCommand(
        x,
        level: level + 1,
        fullCommand: xFullCommand,
      );
    }
  }
}

void handleSubCommand(
  final Command<void> subcommand, {
  required final int level,
  required final String fullCommand,
}) {
  commands[fullCommand] = CommandDoc(
    subcommand,
    level: level,
    fullCommand: fullCommand,
  );

  for (final Command<void> x in subcommand.subcommands.values) {
    final String xFullCommand = '$fullCommand ${x.name}';

    if (!commands.containsKey(xFullCommand)) {
      handleSubCommand(
        x,
        level: level + 1,
        fullCommand: xFullCommand,
      );
    }
  }
}
