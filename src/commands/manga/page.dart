import 'package:args/command_runner.dart';
import 'package:tenka/tenka.dart';
import '../../core/manager.dart';
import '../../utils/console.dart';
import '../../utils/custom_args.dart';

class MangaPageCommand extends Command<void> {
  MangaPageCommand() {
    TenkaModuleArgs.addOptions(argParser);
  }

  @override
  final String name = 'page';

  @override
  final List<String> aliases = <String>['pages', 'pg', 'pgs'];

  @override
  final String description = 'Display information of a chapter page.';

  @override
  Future<void> run() async {
    final TenkaModuleArgs<MangaExtractor> mArgs =
        await TenkaModuleArgs.parse(argResults!, TenkaType.manga);

    final ImageDescriber result =
        await mArgs.extractor.getPage(mArgs.terms, mArgs.locale);

    if (AppManager.isJsonMode) {
      printJson(result.toJson());
      return;
    }

    printHeading('Chapter Page');
    print(DyeUtils.dyeKeyValue('URL', mArgs.terms));
    print(
      DyeUtils.dyeKeyValue(
        'Locale',
        mArgs.locale.toPrettyString(appendCode: true),
      ),
    );
    println();
    printHeading('Result');
    print(
      DyeUtils.dyeKeyValue(
        'URL',
        result.url,
        additionalValueStyles: 'underline',
      ),
    );
    print(DyeUtils.dyeKeyValue('Headers', ''));
    result.headers.forEach((final String key, final String value) {
      print(
        '  ${Dye.dye('-', 'magenta')} ${DyeUtils.dyeKeyValue(key, value)}',
      );
    });
  }
}
