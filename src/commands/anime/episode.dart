import 'package:args/command_runner.dart';
import 'package:tenka/tenka.dart';
import '../../core/manager.dart';
import '../../utils/console.dart';
import '../../utils/custom_args.dart';

class AnimeEpisodeCommand extends Command<void> {
  AnimeEpisodeCommand() {
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
    final TenkaModuleArgs<AnimeExtractor> mArgs =
        await TenkaModuleArgs.parse(argResults!, TenkaType.anime);

    final List<EpisodeSource> results =
        await mArgs.extractor.getSources(mArgs.terms, mArgs.locale);

    if (AppManager.isJsonMode) {
      printJson(results.map((final EpisodeSource x) => x.toJson()).toList());
      return;
    }

    printHeading('Episode Sources');
    print(DyeUtils.dyeKeyValue('URL', mArgs.terms));
    print(
      DyeUtils.dyeKeyValue(
        'Locale',
        mArgs.locale.toPrettyString(appendCode: true),
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
          '      ${Dye.dye('-', 'dark')} ${DyeUtils.dyeKeyValue(key, value)}',
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
