import 'package:args/command_runner.dart';
import 'package:tenka/tenka.dart';
import '../../core/manager.dart';
import '../../utils/console.dart';
import '../../utils/tenka_module_args.dart';

class MangaEpisodeCommand extends Command<void> {
  MangaEpisodeCommand() {
    TenkaModuleArgs.addOptions(argParser);
  }

  @override
  final String name = 'episode';

  @override
  final List<String> aliases = <String>['ep', 'sources', 'source'];

  @override
  final String description = 'Display information of an episode.';

  @override
  Future<void> run() async {
    final TenkaModuleArgs<AnimeExtractor> moduleArgs =
        await TenkaModuleArgs.parse(argResults!, TenkaType.anime);

    final List<EpisodeSource> results = await moduleArgs.extractor
        .getSources(moduleArgs.terms, moduleArgs.locale);

    if (AppManager.isJsonMode) {
      printJson(results.map((final EpisodeSource x) => x.toJson()).toList());
      return;
    }

    printTitle('Episode Sources');
    print(DyeUtils.dyeKeyValue('Terms', moduleArgs.terms));
    print(
      DyeUtils.dyeKeyValue(
        'Locale',
        moduleArgs.locale.toPrettyString(appendCode: true),
      ),
    );
    println();
    printHeading('Results');

    int i = 1;
    for (final EpisodeSource x in results) {
      print(
        '$i. ${DyeUtils.dyeKeyValue('URL', x.url, additionalValueStyles: 'underline')}',
      );
      print('   ${DyeUtils.dyeKeyValue('Headers', '')}');
      x.headers.forEach((final String key, final String value) {
        print(
          '      ${Dye.dye('-', 'darkGray')} ${DyeUtils.dyeKeyValue(key, value)}',
        );
      });
      print('   ${DyeUtils.dyeKeyValue('Quality', x.quality.code)}');
      print(
        '   ${DyeUtils.dyeKeyValue('Locale', x.locale.toPrettyString(appendCode: true))}',
      );

      i++;
    }
  }
}
