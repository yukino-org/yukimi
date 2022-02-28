import 'package:args/command_runner.dart';
import 'anime/episode.dart';
import 'anime/info.dart';
import 'anime/search.dart';

class AnimeCommand extends Command<void> {
  AnimeCommand() {
    addSubcommand(AnimeInfoCommand());
    addSubcommand(AnimeSearchCommand());
    addSubcommand(AnimeEpisodeCommand());
  }

  @override
  final String name = 'anime';

  @override
  final List<String> aliases = <String>['a'];

  @override
  final String description = 'Anime related commands.';
}
