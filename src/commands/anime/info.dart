import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:extensions/extensions.dart';
import 'package:extensions/metadata.dart';
import 'package:utilx/utilities/locale.dart';
import 'package:utilx/utilities/utils.dart';
import '../../core/database/settings.dart';
import '../../core/manager.dart';
import '../../utils/command_exception.dart';
import '../../utils/console.dart';
import '../../utils/content_range.dart';
import '../../utils/extractor_args.dart';
import '_utils.dart';

class AnimeInfoCommand extends Command<void> {
  AnimeInfoCommand() {
    ExtensionRestArg.addOptions(argParser);
    argParser.addMultiOption(
      'episodes',
      aliases: <String>['episode', 'ep', 'eps'],
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
    final ExtensionRestArg<AnimeExtractor> eRestArg =
        await ExtensionRestArg.parse(argResults!, EType.anime);

    final ContentRange? range = argResults!.wasParsed('episodes')
        ? ContentRange.parse(
            (argResults!['episodes'] as List<dynamic>).cast<String>(),
          )
        : null;

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

    final List<EpisodeInfo> downloadEpisodes = <EpisodeInfo>[];
    for (final EpisodeInfo x in result.sortedEpisodes) {
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
        throw CRTException('Missing option: destination');
      }

      final String? parsedPreferredQuality = argResults!.wasParsed('quality')
          ? argResults!['quality'] as String
          : AppSettings.settings.preferredVideoQuality;

      final String? parsedFallbackQuality =
          argResults!.wasParsed('fallbackQuality')
              ? argResults!['fallbackQuality'] as String
              : AppSettings.settings.fallbackVideoQuality;

      if (parsedPreferredQuality == null) {
        throw CRTException('Missing option: quality');
      }

      final Qualities? preferredQuality =
          EnumUtils.findOrNull(Qualities.values, parsedPreferredQuality);

      final Qualities? fallbackQuality =
          EnumUtils.findOrNull(Qualities.values, parsedFallbackQuality);

      if (preferredQuality == null) {
        throw CRTException('Invalid option: quality ($parsedPreferredQuality)');
      }

      for (final EpisodeInfo x in downloadEpisodes) {
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

        await AnimeDownloader.download(
          url: source.url,
          headers: source.headers,
          destination: destination,
        );
      }
    }
  }
}
