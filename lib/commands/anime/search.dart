import 'package:args/command_runner.dart';
import 'package:extensions/extensions.dart';
import 'package:extensions/metadata.dart';
import '../../core/manager.dart';
import '../../utils/console.dart';
import '../../utils/extractor_args.dart';

class AnimeSearchCommand extends Command<void> {
  AnimeSearchCommand() {
    ExtensionRestArg.addOptions(argParser);
  }

  @override
  final String name = 'search';

  @override
  final List<String> aliases = <String>['s'];

  @override
  final String description = 'Search for an anime.';

  @override
  Future<void> run() async {
    final ExtensionRestArg<AnimeExtractor> eRestArg =
        await ExtensionRestArg.parse(argResults!, EType.anime);

    final List<SearchInfo> results =
        await eRestArg.extractor.search(eRestArg.terms, eRestArg.locale);

    if (AppManager.isJsonMode) {
      printJson(results.map((final SearchInfo x) => x.toJson()).toList());
      return;
    }

    printTitle('Anime Search');
    print(DyeUtils.dyeKeyValue('Terms', eRestArg.terms));
    print(
      DyeUtils.dyeKeyValue(
        'Locale',
        eRestArg.locale.toPrettyString(appendCode: true),
      ),
    );
    println();
    printHeading('Results');

    int i = 1;
    for (final SearchInfo x in results) {
      print(
        '$i. ${Dye.dye(x.title, 'cyan')} ${Dye.dye('[${x.locale.toPrettyString(appendCode: true)}]', 'darkGray')}',
      );
      print('   ${Dye.dye(x.url, 'darkGray/underline')}');

      i++;
    }
  }
}
