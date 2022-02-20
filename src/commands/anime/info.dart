import 'package:args/command_runner.dart';
import 'package:extensions/extensions.dart';
import 'package:extensions/metadata.dart';
import 'package:utilx/utilities/locale.dart';
import '../../core/database/settings.dart';
import '../../core/manager.dart';
import '../../utils/command_exception.dart';
import '../../utils/console.dart';
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

    final List<String>? range = argResults!.wasParsed('episodes')
        ? parseEpisodes(
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
        range!.remove(x.episode);
      }

      print(
        '$i ${Dye.dye(x.url, 'cyan/underline')} ${Dye.dye('[${x.locale.toPrettyString(appendCode: true)}]', 'darkGray')}',
      );
    }

    if (range?.isNotEmpty ?? false) {
      throw Exception('Invalid episodes: ${range!.join(', ')}');
    }

    if (downloadEpisodes.isNotEmpty) {
      println();
      printHeading('Downloads');

      final String? downloadDir = argResults!.wasParsed('downloadDir')
          ? argResults!['downloadDir'] as String
          : AppSettings.settings.downloadDir;
      if (downloadDir == null) {
        throw CRTException('Missing option: downloadDir');
      }
    }
  }
}
