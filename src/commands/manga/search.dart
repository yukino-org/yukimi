import 'package:args/command_runner.dart';
import 'package:tenka/tenka.dart';
import '../../core/manager.dart';
import '../../utils/console.dart';
import '../../utils/custom_args.dart';

class MangaSearchCommand extends Command<void> {
  MangaSearchCommand() {
    TenkaModuleArgs.addOptions(argParser);
  }

  @override
  final String name = 'search';

  @override
  final List<String> aliases = <String>['s'];

  @override
  final String description = 'Search for an manga.';

  @override
  Future<void> run() async {
    final TenkaModuleArgs<MangaExtractor> mArgs =
        await TenkaModuleArgs.parse(argResults!, TenkaType.manga);

    final List<SearchInfo> results =
        await mArgs.extractor.search(mArgs.terms, mArgs.locale);

    if (AppManager.isJsonMode) {
      printJson(results.map((final SearchInfo x) => x.toJson()).toList());
      return;
    }

    printTitle('Manga Search');
    print(DyeUtils.dyeKeyValue('Terms', mArgs.terms));
    print(
      DyeUtils.dyeKeyValue(
        'Locale',
        mArgs.locale.toPrettyString(appendCode: true),
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
