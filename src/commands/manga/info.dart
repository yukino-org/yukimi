import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:tenka/tenka.dart';
import 'package:utilx/locale.dart';
import '../../config/paths.dart';
import '../../core/database/cache.dart';
import '../../core/database/settings.dart';
import '../../core/manager.dart';
import '../../utils/command_exception.dart';
import '../../utils/console.dart';
import '../../utils/content_range.dart';
import '../../utils/path.dart';
import '../../utils/tenka_module_args.dart';
import '_utils.dart';

class MangaInfoCommand extends Command<void> {
  MangaInfoCommand() {
    TenkaModuleArgs.addOptions(argParser);
    argParser
      ..addFlag('no-cache', negatable: false)
      ..addFlag('download', abbr: 'd')
      ..addFlag(
        'view',
        abbr: 'v',
        aliases: <String>['open'],
        negatable: false,
      )
      ..addMultiOption(
        'chapters',
        abbr: 'c',
        aliases: <String>['chapter', 'ch', 'chs'],
      )
      ..addOption(
        'destination',
        abbr: 'o',
        aliases: <String>['outDir'],
      );
  }

  @override
  final String name = 'info';

  @override
  final List<String> aliases = <String>['i'];

  @override
  final String description = 'Get information of an manga.';

  @override
  Future<void> run() async {
    final TenkaModuleArgs<MangaExtractor> moduleArgs =
        await TenkaModuleArgs.parse(argResults!, TenkaType.manga);

    final ContentRange? range = argResults!.wasParsed('chapters')
        ? ContentRange.parse(
            (argResults!['chapters'] as List<dynamic>).cast<String>(),
          )
        : null;

    final MangaInfo? cached = argResults!['no-cache'] == false
        ? Cache.cache.getManga(moduleArgs.metadata.id, moduleArgs.terms)
        : null;

    final MangaInfo info = cached ??
        await moduleArgs.extractor.getInfo(moduleArgs.terms, moduleArgs.locale);

    await Cache.cache.saveManga(moduleArgs.metadata.id, info);

    if (AppManager.isJsonMode) {
      printJson(info.toJson());
      return;
    }

    printTitle('Manga Information');
    print(DyeUtils.dyeKeyValue('Title', info.title));
    print(
      DyeUtils.dyeKeyValue(
        'URL',
        info.url,
        additionalValueStyles: 'underline',
      ),
    );
    print(
      DyeUtils.dyeKeyValue(
        'Locale',
        info.locale.toPrettyString(appendCode: true),
      ),
    );
    print(
      DyeUtils.dyeKeyValue(
        'Avaliable locales',
        info.availableLocales
            .map((final Locale x) => x.toPrettyString(appendCode: true))
            .join(', '),
      ),
    );
    println();
    printHeading('Chapters');

    final List<ChapterInfo> selectedChapters = <ChapterInfo>[];
    for (final ChapterInfo x in info.chapters) {
      final Dye i = Dye('${x.chapter}.');

      if (range?.contains(x.chapter) ?? false) {
        i.apply('lightGreen');
        selectedChapters.add(x);
      }

      print(
        '$i ${Dye.dye(x.url, 'cyan/underline')} ${Dye.dye('[${x.locale.toPrettyString(appendCode: true)}]', 'darkGray')}',
      );
    }

    final bool isDownload = argResults!['download'] as bool;
    final bool isView = argResults!['view'] as bool;

    if (isDownload || isView) {
      println();

      if (isDownload) printHeading('Downloads');

      if (selectedChapters.isEmpty) {
        throw CRTException.missingOption('chapters');
      }

      if (isView && selectedChapters.length != 1) {
        throw CRTException.invalidOption(
          'chapters (Only one chapter can be viewed at a time)',
        );
      }

      final String? dDestination = argResults!.wasParsed('destination')
          ? argResults!['destination'] as String
          : AppSettings.settings.mangaDestination;
      if (isDownload && dDestination == null) {
        throw CRTException.missingOption('destination');
      }

      final String fileNamePrefix =
          '[${moduleArgs.metadata.name}] ${info.title}';
      final String destination =
          dDestination ?? path.join(Paths.tmpDir, fileNamePrefix);

      for (final ChapterInfo x in selectedChapters) {
        print(
          '${Dye.dye('${x.chapter}.', 'lightGreen')} Chapter ${x.chapter} ${Dye.dye('[${x.locale.toPrettyString(appendCode: true)}]', 'darkGray')}',
        );

        final List<PageInfo> pages =
            await moduleArgs.extractor.getChapter(x.url, x.locale);

        final String leftSpace =
            List<String>.filled(x.chapter.length + 2, ' ').join();

        final String fDestination =
            path.join(destination, 'Chapter ${x.chapter}');

        await MangaDownloader.download(
          leftSpace: leftSpace,
          pages: pages,
          extractor: moduleArgs.extractor,
          getDestination: (final DLPageData res) {
            final String filePath = path.join(
              fDestination,
              '$fileNamePrefix - Chapter ${x.chapter} - Page ${res.index + 1}.${res.mimeType}',
            );

            return filePath;
          },
        );

        stdout.write('\r');
        print(
          leftSpace +
              Dye.dye('Output: ', 'darkGray').toString() +
              Dye.dye(fDestination, 'darkGray/underline').toString(),
        );

        if (isView) {
          final String fExecutable = getFileSystemExecutable();
          print(
            '${leftSpace}Opening ${Dye.dye('chapter ${x.chapter}', 'cyan')} in ${Dye.dye(fExecutable, 'cyan')}.',
          );
          await Process.start(
            fExecutable,
            <String>[fDestination],
            mode: ProcessStartMode.detached,
          );
        }
      }
    }
  }
}
