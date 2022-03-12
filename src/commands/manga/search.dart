import 'package:args/command_runner.dart';
import 'package:tenka/tenka.dart';
import '../../core/manager.dart';
import '../../utils/console.dart';
import '../../utils/tenka_module_args.dart';

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
    final TenkaModuleArgs<MangaExtractor> moduleArgs =
        await TenkaModuleArgs.parse(argResults!, TenkaType.manga);

    final List<SearchInfo> results =
        await moduleArgs.extractor.search(moduleArgs.terms, moduleArgs.locale);

    if (AppManager.isJsonMode) {
      printJson(results.map((final SearchInfo x) => x.toJson()).toList());
      return;
    }

    printTitle('Manga Search');
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
    for (final SearchInfo x in results) {
      print(
        '$i. ${Dye.dye(x.title, 'cyan')} ${Dye.dye('[${x.locale.toPrettyString(appendCode: true)}]', 'darkGray')}',
      );
      print('   ${Dye.dye(x.url, 'darkGray/underline')}');

      i++;
    }
  }
}
