import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:tenka/tenka.dart';
import 'package:utilx/locale.dart';
import 'package:utilx/utils.dart';
import '../../config/paths.dart';
import '../../core/commander.dart';
import '../../core/database/cache.dart';
import '../../core/database/settings.dart';
import '../../core/manager.dart';
import '../../utils/console.dart';
import '../../utils/content_range.dart';
import '../../utils/custom_args.dart';
import '../../utils/exceptions.dart';
import '../../utils/io.dart';
import '../../utils/others.dart';
import '_utils.dart';

enum _DownloadFormat {
  pdf,
  image,
}

class _Options extends CommandOptions {
  const _Options(final ArgResults results) : super(results);

  static const String kNoCache = 'no-cache';
  bool get noCache => get<bool>(kNoCache);

  static const String kDownload = 'download';
  static const String kDownloadAbbr = 'd';
  bool get download => get<bool>(kDownload);

  static const String kRead = 'read';
  static const String kReadAbbr = 'r';
  static const List<String> kReadAliases = <String>['open', 'view'];
  bool get read => get<bool>(kRead);

  static const String kChapters = 'chapters';
  static const String kChaptersAbbr = 'c';
  static const List<String> kChaptersAliases = <String>[
    'range',
    'chapter',
    'ch',
    'chs'
  ];
  List<String>? get chapters =>
      getNullable<List<dynamic>>(kChapters)?.cast<String>();

  static const String kDestination = 'destination';
  static const String kDestinationAbbr = 'o';
  static const List<String> kDestinationAliases = <String>['outDir', 'dest'];
  String? get destination => getNullable(kDestination);

  static const String kSubDestination = 'sub-destination';
  static const String kSubDestinationAbbr = 's';
  static const List<String> kSubDestinationAliases = <String>[
    'sub-outDir',
    's-outDir',
    's-dest'
  ];
  String? get subDestination => getNullable(kSubDestination);

  static const String kFilename = 'filename';
  static const String kFilenameAbbr = 'n';
  static const List<String> kFilenameAliases = <String>['file', 'name'];
  String? get filename => getNullable(kFilename);

  static const String kDownloadFormat = 'download-format';
  static const String kDownloadFormatAbbr = 'f';
  static const List<String> kDownloadFormatAliases = <String>['df'];
  static final List<String> kDownloadFormatAllowed =
      _DownloadFormat.values.map((final _DownloadFormat x) => x.name).toList();
  static final String kDownloadFormatDefaultsTo = _DownloadFormat.pdf.name;
  String get downloadFormat => get<String>(kDownloadFormat);

  static const String kSearch = 'search';
  bool get search => get<bool>(kSearch);

  static const String kIgnoreExistingFiles = 'ignore-existing-files';
  static const String kIgnoreExistingFilesAbbr = 'i';
  bool get ignoreExistingFiles => get<bool>(kIgnoreExistingFiles);

  static const String kDownloaderConcurrency = 'downloader-concurrency';
  static const List<String> kDownloaderConcurrencyAliases = <String>[
    'download-concurrency',
    'dlr-conc',
    'conc'
  ];
  int? get downloaderConcurrency => getNullable<int>(kDownloaderConcurrency);
}

class MangaInfoCommand extends Command<void> {
  MangaInfoCommand() {
    TenkaModuleArgs.addOptions(argParser);
    argParser
      ..addFlag(
        _Options.kNoCache,
        negatable: false,
      )
      ..addFlag(
        _Options.kDownload,
        abbr: _Options.kDownloadAbbr,
        negatable: false,
      )
      ..addFlag(
        _Options.kRead,
        abbr: _Options.kReadAbbr,
        aliases: _Options.kReadAliases,
        negatable: false,
      )
      ..addMultiOption(
        _Options.kChapters,
        abbr: _Options.kChaptersAbbr,
        aliases: _Options.kChaptersAliases,
      )
      ..addOption(
        _Options.kDestination,
        abbr: _Options.kDestinationAbbr,
        aliases: _Options.kDestinationAliases,
      )
      ..addOption(
        _Options.kSubDestination,
        abbr: _Options.kSubDestinationAbbr,
        aliases: _Options.kSubDestinationAliases,
      )
      ..addOption(
        _Options.kFilename,
        abbr: _Options.kFilenameAbbr,
        aliases: _Options.kFilenameAliases,
      )
      ..addOption(
        _Options.kDownloadFormat,
        abbr: _Options.kDownloadFormatAbbr,
        aliases: _Options.kDownloadFormatAliases,
        allowed: _Options.kDownloadFormatAllowed,
        defaultsTo: _Options.kDownloadFormatDefaultsTo,
      )
      ..addFlag(_Options.kSearch)
      ..addFlag(
        _Options.kIgnoreExistingFiles,
        abbr: _Options.kIgnoreExistingFilesAbbr,
      )
      ..addOption(
        _Options.kDownloaderConcurrency,
        aliases: _Options.kDownloaderConcurrencyAliases,
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
    final _Options options = _Options(argResults!);

    final TenkaModuleArgs<MangaExtractor> mArgs =
        await TenkaModuleArgs.parse(argResults!, TenkaType.manga);

    final String getInfoURL;
    final Locale getInfoLocale;
    if (options.search) {
      final List<SearchInfo> searches =
          await mArgs.extractor.search(mArgs.terms, mArgs.locale);

      if (searches.isEmpty) {
        throw CommandException('No results for "${mArgs.terms}".');
      }

      getInfoURL = searches.first.url;
      getInfoLocale = searches.first.locale;
    } else {
      getInfoURL = mArgs.terms;
      getInfoLocale = mArgs.locale;
    }

    final MangaInfo? cached = !options.noCache
        ? Cache.cache.getManga(mArgs.metadata.id, getInfoURL)
        : null;

    final MangaInfo info =
        cached ?? await mArgs.extractor.getInfo(getInfoURL, getInfoLocale);

    await Cache.cache.saveManga(mArgs.metadata.id, info);

    if (AppManager.isJsonMode) {
      printJson(info.toJson());
      return;
    }

    final ContentRange? range = options.chapters != null
        ? ContentRange.parse(
            options.chapters!,
            allowed: info.chapters
                .map((final ChapterInfo x) => double.parse(x.chapter))
                .toList(),
          )
        : null;

    printHeading('Manga Information');
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

      if (range?.contains(double.parse(x.chapter)) ?? false) {
        i.apply('lightGreen');
        selectedChapters.add(x);
      }

      print(
        '$i ${Dye.dye(x.url, 'lightCyan/underline')} ${Dye.dye('[${x.locale.toPrettyString(appendCode: true)}]', 'magenta')}',
      );
    }

    if (selectedChapters.isNotEmpty) {
      println();

      if (options.download) {
        printHeading('Downloads');
      } else if (options.read) {
      } else {
        printHeading('Source');
      }

      if (options.read && selectedChapters.length != 1) {
        throw CommandException.invalidOption(
          'chapters (Only one chapter can be viewed at a time)',
        );
      }

      final _DownloadFormat format =
          EnumUtils.find(_DownloadFormat.values, options.downloadFormat);

      final String destination = options.destination ??
          (options.download
              ? AppSettings.settings.mangaDownloadDestination
              : Paths.tmpDir);

      final String subDestination = options.subDestination ??
          AppSettings.settings.mangaDownloadSubDestination;

      final String filenameTemplate =
          options.filename ?? AppSettings.settings.mangaDownloadFilename;
      final String filename = format == _DownloadFormat.image
          ? path.join(
              filenameTemplate,
              '\${${CommandArgumentTemplates.kPageNumber}}',
            )
          : filenameTemplate;

      final int concurrency = options.download
          ? options.downloaderConcurrency ??
              AppSettings.settings.downloaderConcurrency
          : 1;

      final CommandArgumentTemplates globalArgTemplates =
          CommandArgumentTemplates.withDefaultTemplates(
        <String, String>{
          CommandArgumentTemplates.kMangaTitle: info.title,
          CommandArgumentTemplates.kMangaURL: info.url,
          CommandArgumentTemplates.kMangaLocale: info.locale.toPrettyString(),
          CommandArgumentTemplates.kMangaLocaleCode: info.locale.toCodeString(),
          CommandArgumentTemplates.kModuleName: mArgs.metadata.name,
          CommandArgumentTemplates.kModuleId: mArgs.metadata.id,
        },
      );

      final String folder = FSUtils.ensurePath(
        globalArgTemplates.replace(path.join(destination, subDestination)),
      );

      print(
        Dye.dye('Output: ', 'default').toString() +
            Dye.dye(folder, 'lightCyan/underline').toString(),
      );
      println();

      const String leftSpace = '   ';
      final Map<ChapterInfo, String> logs = <ChapterInfo, String>{};
      int prevLogLines = 0;

      void logFn() {
        final String line = logs.values.map(getPaddedPrintText).join('\n');
        print(AnsiCodes.moveCursorUp(prevLogLines));
        print(line);
        prevLogLines = countConsoleTextLines(line) + 1;
      }

      final Timer logTimer = Timer.periodic(
        const Duration(milliseconds: 100),
        (final Timer _) => logFn(),
      );

      final QueuedRunner<void> tasks = QueuedRunner<void>(
        selectedChapters
            .map(
              (final ChapterInfo x) => () async {
                final String prefix =
                    '${Dye.dye('${x.chapter}.', 'lightGreen')} Chapter ${x.chapter} ${Dye.dye('[${x.locale.toPrettyString(appendCode: true)}]', 'magenta')}';
                logs[x] =
                    '$prefix (Status: ${Dye.dye('processing', 'magenta')})';

                final CommandArgumentTemplates argTemplates =
                    globalArgTemplates.copyWith(
                  <String, String>{
                    CommandArgumentTemplates.kVolumeNumber: x.volume ?? '-',
                    CommandArgumentTemplates.kChapterNumber: x.chapter,
                    CommandArgumentTemplates.kChapterLocale:
                        x.locale.toPrettyString(),
                    CommandArgumentTemplates.kChapterLocaleCode:
                        x.locale.toCodeString(),
                  },
                );

                final List<PageInfo> pages =
                    await mArgs.extractor.getChapter(x.url, x.locale);
                String filePath;

                switch (format) {
                  case _DownloadFormat.pdf:
                    argTemplates
                            .variables[CommandArgumentTemplates.kPageNumber] =
                        pages.length.toString();

                    filePath =
                        argTemplates.replace(path.join(folder, filename));

                    await MangaDownloader.downloadAsPdf(
                      pages: pages,
                      extractor: mArgs.extractor,
                      ignoreIfFileExists: options.ignoreExistingFiles,
                      onProgress: ({
                        required final double percent,
                        final int? current,
                        final int? total,
                      }) {
                        final String bar = buildGenericProgressBar(
                          percent,
                          current: current,
                          total: total,
                          width: stdout.terminalColumns - leftSpace.length,
                        );
                        logs[x] = '$prefix\n$leftSpace$bar';
                      },
                      getDestination: ({
                        required final String mimeType,
                      }) =>
                          filePath = FSUtils.ensurePath(
                        argTemplates.replace('$filePath.$mimeType'),
                      ),
                    );
                    break;

                  case _DownloadFormat.image:
                    filePath = FSUtils.ensurePath(argTemplates.replace(folder));
                    if (options.ignoreExistingFiles &&
                        await Directory(filePath).exists()) {
                      break;
                    }

                    await MangaDownloader.downloadAsImages(
                      pages: pages,
                      extractor: mArgs.extractor,
                      onProgress: ({
                        required final double percent,
                        final int? current,
                        final int? total,
                      }) {
                        final String bar = buildGenericProgressBar(
                          percent,
                          current: current,
                          total: total,
                          width: stdout.terminalColumns - leftSpace.length,
                        );
                        logs[x] = '$prefix\n$leftSpace$bar';
                      },
                      getDestination: ({
                        required final String mimeType,
                        required final int pageNumber,
                      }) {
                        argTemplates.variables[CommandArgumentTemplates
                            .kPageNumber] = pageNumber.toString();
                        return FSUtils.ensurePath(
                          argTemplates.replace(
                            path.join(filePath, '$filename.$mimeType'),
                          ),
                        );
                      },
                    );
                    break;
                }

                logs[x] =
                    '$prefix\n${leftSpace}Output: ${Dye.dye(filePath, 'lightCyan/underline')}';

                if (options.read) {
                  final String fExecutable = getFileSystemExecutable();
                  logs[x] =
                      '${logs[x]}\n${leftSpace}Opening using ${Dye.dye(fExecutable, 'lightCyan')}.';
                  await Process.start(
                    fExecutable,
                    <String>[filePath],
                    mode: ProcessStartMode.detached,
                  );
                }
              },
            )
            .toList(),
        concurrency: concurrency,
      );

      await tasks.asFuture();
      logTimer.cancel();
      logFn();
    }
  }
}
