import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:dl/dl.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart' as path;
import 'package:tenka/tenka.dart';
import 'package:utilx/utilities/locale.dart';
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
        'play',
        abbr: 'p',
        aliases: <String>['mpv'],
        negatable: false,
      )
      ..addMultiOption(
        'episodes',
        abbr: 'e',
        aliases: <String>['episode', 'ep', 'eps'],
      )
      ..addOption(
        'destination',
        abbr: 'o',
        aliases: <String>['outDir'],
      )
      ..addOption(
        'quality',
        abbr: 'q',
      )
      ..addOption(
        'fallbackQuality',
        aliases: <String>['fq'],
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

    final ContentRange? range = argResults!.wasParsed('episodes')
        ? ContentRange.parse(
            (argResults!['episodes'] as List<dynamic>).cast<String>(),
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
    for (final ChapterInfo x in info.sortedChapters) {
      final Dye i = Dye('${x.chapter}.');

      if (range?.contains(x.chapter) ?? false) {
        i.apply('lightGreen');
        selectedChapters.add(x);
      }

      print(
        '$i ${Dye.dye(x.url, 'cyan/underline')} ${Dye.dye('[${x.locale.toPrettyString(appendCode: true)}]', 'darkGray')}',
      );
    }

    // final bool isDownload = argResults!['download'] as bool;
    // final bool isPlay = argResults!['play'] as bool;

    // if (isDownload && isPlay) {
    //   throw CRTException('--download and --play are not supported together.');
    // }

    // if (isDownload || isPlay) {
    //   println();

    //   if (isDownload) printHeading('Downloads');

    //   if (selectedEpisodes.isEmpty) {
    //     throw CRTException.missingOption('episodes');
    //   }

    //   if (isPlay && selectedEpisodes.length != 1) {
    //     throw CRTException.invalidOption(
    //       'episodes (Only only episode can be played at a time)',
    //     );
    //   }

    //   final String? destination = argResults!.wasParsed('destination')
    //       ? argResults!['destination'] as String
    //       : AppSettings.settings.animeDestination;
    //   if (isDownload && destination == null) {
    //     throw CRTException.missingOption('destination');
    //   }

    //   final String? parsedPreferredQuality = argResults!.wasParsed('quality')
    //       ? argResults!['quality'] as String
    //       : AppSettings.settings.preferredVideoQuality;

    //   final String? parsedFallbackQuality =
    //       argResults!.wasParsed('fallbackQuality')
    //           ? argResults!['fallbackQuality'] as String
    //           : AppSettings.settings.fallbackVideoQuality;

    //   if (parsedPreferredQuality == null) {
    //     throw CRTException.missingOption('quality');
    //   }

    //   final Qualities? preferredQuality =
    //       resolveQuality(parsedPreferredQuality);

    //   final Qualities? fallbackQuality = parsedFallbackQuality != null
    //       ? resolveQuality(parsedFallbackQuality)
    //       : null;

    //   if (preferredQuality == null) {
    //     throw CRTException.invalidOption('quality ($parsedPreferredQuality)');
    //   }

    //   final String fileNamePrefix =
    //       '[${moduleArgs.metadata.name}] ${info.title}';

    //   for (final EpisodeInfo x in selectedEpisodes) {
    //     if (isDownload) {
    //       print(
    //         '${Dye.dye('${x.episode}.', 'lightGreen')} Episode ${x.episode} ${Dye.dye('[${x.locale.toPrettyString(appendCode: true)}]', 'darkGray')}',
    //       );
    //     }

    //     final List<EpisodeSource> episode =
    //         await moduleArgs.extractor.getSources(x);

    //     final EpisodeSource? source = episode.firstWhereOrNull(
    //           (final EpisodeSource x) => x.quality.quality == preferredQuality,
    //         ) ??
    //         episode.firstWhereOrNull(
    //           (final EpisodeSource x) => x.quality.quality == fallbackQuality,
    //         );

    //     if (source == null) {
    //       throw CRTException(
    //         'Unable to find appropriate source for episode ${x.episode}!',
    //       );
    //     }

    //     if (isPlay) {
    //       if (AppSettings.settings.mpvPath == null) {
    //         throw CRTException('No mpv path was set in settings');
    //       }

    //       print(
    //         'Opening ${Dye.dye('episode ${x.episode}', 'cyan')} in ${Dye.dye('mpv', 'cyan')}.',
    //       );

    //       await Process.start(
    //         AppSettings.settings.mpvPath!,
    //         <String>[
    //           if (source.headers.isNotEmpty)
    //             '--http-header-fields=${source.headers.entries.map((final MapEntry<String, String> x) => "${x.key}: '${x.value}'").join(',')}',
    //           '--title=$fileNamePrefix - Episode ${x.episode} (${source.quality.code})',
    //           source.url,
    //         ],
    //         mode: ProcessStartMode.detached,
    //       );
    //     }

    //     if (isDownload) {
    //       final String leftSpace =
    //           List<String>.filled(x.episode.length + 2, ' ').join();

    //       print(
    //         leftSpace +
    //             Dye.dye('Source: ', 'darkGray').toString() +
    //             Dye.dye(source.url, 'darkGray/underline').toString() +
    //             Dye.dye(' (${source.quality.code})', 'darkGray').toString(),
    //       );

    //       await MangaDownloader.download(
    //         leftSpace: leftSpace,
    //         url: source.url,
    //         headers: source.headers,
    //         getDestination: (final DLResponse res) {
    //           final String? fileExtension = getExtensionFromURL(source.url) ??
    //               (res.response.headers.contentType != null
    //                   ? extensionFromMime(
    //                       res.response.headers.contentType!.mimeType,
    //                     )
    //                   : null);

    //           if (fileExtension == null) {
    //             throw CRTException(
    //               'Unable to find source type for episode ${x.episode}!',
    //             );
    //           }

    //           final String filePath = path.join(
    //             destination!,
    //             fileNamePrefix,
    //             '$fileNamePrefix - Episode ${x.episode} (${source.quality.code}).$fileExtension',
    //           );

    //           print(
    //             leftSpace +
    //                 Dye.dye('Output: ', 'darkGray').toString() +
    //                 Dye.dye(filePath, 'darkGray/underline').toString(),
    //           );

    //           return filePath;
    //         },
    //       );

    //       stdout.write('\r');
    //     }
    //   }
    // }
  }
}
