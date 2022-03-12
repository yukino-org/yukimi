import 'package:args/command_runner.dart';
import 'manga/chapter.dart';
import 'manga/info.dart';
import 'manga/search.dart';

class MangaCommand extends Command<void> {
  MangaCommand() {
    addSubcommand(MangaInfoCommand());
    addSubcommand(MangaSearchCommand());
    addSubcommand(MangaEpisodeCommand());
  }

  @override
  final String name = 'manga';

  @override
  final List<String> aliases = <String>['m'];

  @override
  final String description = 'Manga related commands.';
}
