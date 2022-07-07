import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import '../commands/agree_to_usage.dart';
import '../commands/anime.dart';
import '../commands/manga.dart';
import '../commands/settings.dart';
import '../commands/tenka.dart';
import '../commands/terminal.dart';
import '../commands/version.dart';
import '../config/meta.dart';

abstract class CommandOptions {
  const CommandOptions(this.results);

  final ArgResults results;

  bool wasParsed(final String name) => results.wasParsed(name);

  T? getNullable<T>(final String key) =>
      results.wasParsed(key) ? results[key] as T : null;

  T get<T>(final String key) => results[key] as T;
}

abstract class AppCommander {
  static CommandRunner<void> get() {
    final CommandRunner<void> runner =
        CommandRunner<void>(AppMeta.id, AppMeta.description);

    runner.argParser
      ..addFlag('json', negatable: false)
      ..addFlag('color', defaultsTo: true)
      ..addFlag('debug');

    runner
      ..addCommand(AgreeToUsagePolicyCommand())
      ..addCommand(AnimeCommand())
      ..addCommand(MangaCommand())
      ..addCommand(TenkaCommand())
      ..addCommand(SettingsCommand())
      ..addCommand(TerminalCommand())
      ..addCommand(VersionCommand());

    return runner;
  }
}
