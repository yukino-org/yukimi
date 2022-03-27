import 'package:args/command_runner.dart';
import 'package:tenka/tenka.dart';
import '../../core/manager.dart';
import '../../utils/console.dart';
import '../../utils/tenka_module_args.dart';

class MangaChapterCommand extends Command<void> {
  MangaChapterCommand() {
    TenkaModuleArgs.addOptions(argParser);
  }

  @override
  final String name = 'chapter';

  @override
  final List<String> aliases = <String>['chapters', 'ch', 'chs'];

  @override
  final String description = 'Display information of a chapter.';

  @override
  Future<void> run() async {
    final TenkaModuleArgs<MangaExtractor> moduleArgs =
        await TenkaModuleArgs.parse(argResults!, TenkaType.manga);

    final List<PageInfo> results = await moduleArgs.extractor
        .getChapter(moduleArgs.terms, moduleArgs.locale);

    if (AppManager.isJsonMode) {
      printJson(results.map((final PageInfo x) => x.toJson()).toList());
      return;
    }

    printTitle('Chapter Pages');
    print(DyeUtils.dyeKeyValue('URL', moduleArgs.terms));
    print(
      DyeUtils.dyeKeyValue(
        'Locale',
        moduleArgs.locale.toPrettyString(appendCode: true),
      ),
    );
    println();
    printHeading('Results');

    int i = 1;
    for (final PageInfo x in results) {
      print(
        '$i. ${DyeUtils.dyeKeyValue('URL', x.url, additionalValueStyles: 'underline')}',
      );
      print(
        '    ${DyeUtils.dyeKeyValue('Locale', x.locale.toPrettyString(appendCode: true))}',
      );

      i++;
    }
  }
}
