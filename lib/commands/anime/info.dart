import 'package:args/command_runner.dart';
import 'package:extensions/extensions.dart';
import 'package:extensions/metadata.dart';
import 'package:utilx/utilities/locale.dart';
import '../../core/manager.dart';
import '../../utils/console.dart';
import '../../utils/extractor_args.dart';

class AnimeInfoCommand extends Command<void> {
  AnimeInfoCommand() {
    ExtensionRestArg.addOptions(argParser);
  }

  @override
  final String name = 'info';

  @override
  final List<String> aliases = <String>['i'];

  @override
  final String description = 'Get information of an anime.';

  @override
  Future<void> run() async {
    final ExtensionRestArg<AnimeExtractor> eRestArg =
        await ExtensionRestArg.parse(argResults!, EType.anime);

    final AnimeInfo result =
        await eRestArg.extractor.getInfo(eRestArg.terms, eRestArg.locale);

    if (AppManager.isJsonMode) {
      printJson(result.toJson());
      return;
    }

    printTitle('Anime Information');
    print(DyeUtils.dyeKeyValue('Title', result.title));
    print(
      DyeUtils.dyeKeyValue(
        'URL',
        result.url,
        additionalValueStyles: 'underline',
      ),
    );
    print(
      DyeUtils.dyeKeyValue(
        'Locale',
        result.locale.toPrettyString(appendCode: true),
      ),
    );
    print(
      DyeUtils.dyeKeyValue(
        'Avaliable locales',
        result.availableLocales
            .map((final Locale x) => x.toPrettyString(appendCode: true))
            .join(', '),
      ),
    );
    println();
    printHeading('Episodes');

    for (final EpisodeInfo x in result.sortedEpisodes) {
      print(
        '${x.episode}. ${Dye.dye(x.url, 'cyan/underline')} ${Dye.dye('[${x.locale.toPrettyString(appendCode: true)}]', 'darkGray')}',
      );
    }
  }
}
