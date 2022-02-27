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

class AnimeInfoCommand extends Command<void> {
  AnimeInfoCommand() {
    TenkaModuleArgs.addOptions(argParser);
    argParser
      ..addFlag('no-cache', negatable: false)
      ..addMultiOption(
        'episodes',
        abbr: 'e',
        aliases: <String>['episode', 'ep', 'eps'],
      )
      ..addOption(
        'destination',
        abbr: 'd',
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
  final String description = 'Get information of an anime.';

  @override
  Future<void> run() async {
    final TenkaModuleArgs<AnimeExtractor> eRestArg =
        await TenkaModuleArgs.parse(argResults!, TenkaType.anime);

    final ContentRange? range = argResults!.wasParsed('episodes')
        ? ContentRange.parse(
            (argResults!['episodes'] as List<dynamic>).cast<String>(),
          )
        : null;

    final AnimeInfo? cached = argResults!['no-cache'] == false
        ? Cache.cache.getAnime(eRestArg.metadata.id, eRestArg.terms)
        : null;

    final AnimeInfo info = cached ??
        await eRestArg.extractor.getInfo(eRestArg.terms, eRestArg.locale);

    await Cache.cache.saveAnime(eRestArg.metadata.id, info);

    if (AppManager.isJsonMode) {
      printJson(info.toJson());
      return;
    }

    printTitle('Anime Information');
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
    printHeading('Episodes');

    final List<EpisodeInfo> downloadEpisodes = <EpisodeInfo>[];
    for (final EpisodeInfo x in info.sortedEpisodes) {
      final Dye i = Dye('${x.episode}.');

      if (range?.contains(x.episode) ?? false) {
        i.apply('lightGreen');
        downloadEpisodes.add(x);
      }

      print(
        '$i ${Dye.dye(x.url, 'cyan/underline')} ${Dye.dye('[${x.locale.toPrettyString(appendCode: true)}]', 'darkGray')}',
      );
    }

    if (downloadEpisodes.isNotEmpty) {
      println();
      printHeading('Downloads');

      final String? destination = argResults!.wasParsed('destination')
          ? argResults!['destination'] as String
          : AppSettings.settings.animeDestination;
      if (destination == null) {
        throw CRTException.missingOption('destination');
      }

      final String? parsedPreferredQuality = argResults!.wasParsed('quality')
          ? argResults!['quality'] as String
          : AppSettings.settings.preferredVideoQuality;

      final String? parsedFallbackQuality =
          argResults!.wasParsed('fallbackQuality')
              ? argResults!['fallbackQuality'] as String
              : AppSettings.settings.fallbackVideoQuality;

      if (parsedPreferredQuality == null) {
        throw CRTException.missingOption('quality');
      }

      final Qualities? preferredQuality =
          resolveQuality(parsedPreferredQuality);

      final Qualities? fallbackQuality = parsedFallbackQuality != null
          ? resolveQuality(parsedFallbackQuality)
          : null;

      if (preferredQuality == null) {
        throw CRTException.invalidOption('quality ($parsedPreferredQuality)');
      }

      final String fileNamePrefix = '[${eRestArg.metadata.name}] ${info.title}';

      for (final EpisodeInfo x in downloadEpisodes) {
        print(
          '${Dye.dye('${x.episode}.', 'lightGreen')} Episode ${x.episode} ${Dye.dye('[${x.locale.toPrettyString(appendCode: true)}]', 'darkGray')}',
        );

        final String leftSpace =
            List<String>.filled(x.episode.length + 2, ' ').join();

        final List<EpisodeSource> episode =
            await eRestArg.extractor.getSources(x);

        final EpisodeSource? source = episode.firstWhereOrNull(
              (final EpisodeSource x) => x.quality.quality == preferredQuality,
            ) ??
            episode.firstWhereOrNull(
              (final EpisodeSource x) => x.quality.quality == fallbackQuality,
            );

        if (source == null) {
          throw CRTException(
            'Unable to find appropriate source for episode ${x.episode}!',
          );
        }

        print(
          leftSpace +
              Dye.dye('Source: ', 'darkGray').toString() +
              Dye.dye(source.url, 'darkGray/underline').toString() +
              Dye.dye(' (${source.quality.code})', 'darkGray').toString(),
        );

        await AnimeDownloader.download(
          leftSpace: leftSpace,
          url: source.url,
          headers: source.headers,
          getDestination: (final DLResponse res) {
            final String? fileExtension = getExtensionFromURL(source.url) ??
                (res.response.headers.contentType != null
                    ? extensionFromMime(
                        res.response.headers.contentType!.mimeType,
                      )
                    : null);

            if (fileExtension == null) {
              throw CRTException(
                'Unable to find source type for episode ${x.episode}!',
              );
            }

            final String filePath = path.join(
              destination,
              fileNamePrefix,
              '$fileNamePrefix - Episode ${x.episode} (${source.quality.code}).$fileExtension',
            );

            print(
              leftSpace +
                  Dye.dye('Output: ', 'darkGray').toString() +
                  Dye.dye(filePath, 'darkGray/underline').toString(),
            );

            return filePath;
          },
        );

        stdout.write('\r');
      }
    }
  }
}
