import 'dart:io';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:tenka/tenka.dart';
import 'package:utilx/locale.dart';
import '../../core/commander.dart';
import '../../core/database/cache.dart';
import '../../core/database/settings.dart';
import '../../core/manager.dart';
import '../../utils/console.dart';
import '../../utils/content_range.dart';
import '../../utils/exceptions.dart';
import '../../utils/others.dart';
import '../../utils/tenka_module_args.dart';
import '_utils.dart';

class _Options extends CommandOptions {
  const _Options(final ArgResults results) : super(results);

  static const String kNoCache = 'no-cache';
  bool get noCache => get<bool>(kNoCache);

  static const String kDownload = 'download';
  static const String kDownloadAbbr = 'd';
  bool get download => get<bool>(kDownload);

  static const String kPlay = 'play';
  static const String kPlayAbbr = 'p';
  static const List<String> kPlayAliases = <String>['stream'];
  bool get play => get<bool>(kPlay);

  static const String kEpisodes = 'episodes';
  static const String kEpisodesAbbr = 'e';
  static const List<String> kEpisodesAliases = <String>[
    'range',
    'episode',
    'ep',
    'eps'
  ];
  List<String>? get episodes =>
      getNullable<List<dynamic>>(kEpisodes)?.cast<String>();

  static const String kDestination = 'destination';
  static const String kDestinationAbbr = 'o';
  static const List<String> kDestinationAliases = <String>['outDir'];
  String? get destination => getNullable(kDestination);

  static const String kQuality = 'quality';
  static const String kQualityAbbr = 'q';
  String? get quality => getNullable(kQuality);

  static const String kFallbackQuality = 'fallbackQuality';
  static const List<String> kFallbackQualityAliases = <String>['fq'];
  String? get fallbackQuality => getNullable(kFallbackQuality);

  static const String kFilename = 'filename';
  static const String kFilenameAbbr = 'n';
  static const List<String> kFilenameAliases = <String>['file', 'name'];
  String? get filename => getNullable(kFilename);
}

class AnimeInfoCommand extends Command<void> {
  AnimeInfoCommand() {
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
        _Options.kPlay,
        abbr: _Options.kPlayAbbr,
        aliases: _Options.kPlayAliases,
        negatable: false,
      )
      ..addMultiOption(
        _Options.kEpisodes,
        abbr: _Options.kEpisodesAbbr,
        aliases: _Options.kEpisodesAliases,
      )
      ..addOption(
        _Options.kDestination,
        abbr: _Options.kDestinationAbbr,
        aliases: _Options.kDestinationAliases,
      )
      ..addOption(
        _Options.kQuality,
        abbr: _Options.kQualityAbbr,
      )
      ..addOption(
        _Options.kFallbackQuality,
        aliases: _Options.kFallbackQualityAliases,
      )
      ..addOption(
        _Options.kFilename,
        abbr: _Options.kFilenameAbbr,
        aliases: _Options.kFilenameAliases,
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
    final _Options options = _Options(argResults!);

    final TenkaModuleArgs<AnimeExtractor> mArgs =
        await TenkaModuleArgs.parse(argResults!, TenkaType.anime);

    final ContentRange? range =
        options.episodes != null ? ContentRange.parse(options.episodes!) : null;

    final AnimeInfo? cached = !options.noCache
        ? Cache.cache.getAnime(mArgs.metadata.id, mArgs.terms)
        : null;

    final AnimeInfo info =
        cached ?? await mArgs.extractor.getInfo(mArgs.terms, mArgs.locale);

    await Cache.cache.saveAnime(mArgs.metadata.id, info);

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

    final List<EpisodeInfo> selectedEpisodes = <EpisodeInfo>[];
    for (final EpisodeInfo x in info.episodes) {
      final Dye i = Dye('${x.episode}.');

      if (range?.contains(x.episode) ?? false) {
        i.apply('lightGreen');
        selectedEpisodes.add(x);
      }

      print(
        '$i ${Dye.dye(x.url, 'cyan/underline')} ${Dye.dye('[${x.locale.toPrettyString(appendCode: true)}]', 'darkGray')}',
      );
    }

    if (options.download && options.play) {
      throw const CommandException(
        '--${_Options.kDownload} and --${_Options.kPlay} are not supported together.',
      );
    }

    if (options.download || options.play) {
      println();

      if (options.download) printHeading('Downloads');

      if (selectedEpisodes.isEmpty) {
        throw CommandException.missingOption('episodes');
      }

      if (options.play && selectedEpisodes.length != 1) {
        throw CommandException.invalidOption(
          'episodes (Only one episode can be played at a time)',
        );
      }

      final String destination = options.destination ??
          path.join(
            '\$${CommandArgumentTemplates.kSettingsAnimeDir}}',
            '[\${${CommandArgumentTemplates.kModuleName}}] \${${CommandArgumentTemplates.kAnimeTitle}} (\${${CommandArgumentTemplates.kEpisodeLocaleCode}})',
          );

      final String _preferredQuality =
          options.quality ?? AppSettings.settings.animePreferredQuality;
      final Qualities? preferredQuality = resolveQuality(_preferredQuality);

      final String _fallbackQuality =
          options.fallbackQuality ?? AppSettings.settings.animeFallbackQuality;
      final Qualities? fallbackQuality = resolveQuality(_fallbackQuality);

      if (preferredQuality == null) {
        throw CommandException.invalidOption(
          '${_Options.kQuality} ($_preferredQuality)',
        );
      }

      if (fallbackQuality == null) {
        throw CommandException.invalidOption(
          '${_Options.kFallbackQuality} ($_fallbackQuality)',
        );
      }

      final String filename = options.filename ??
          '[\${${CommandArgumentTemplates.kModuleName}}] \${${CommandArgumentTemplates.kAnimeTitle}} — Ep. \${${CommandArgumentTemplates.kEpisodeNumber}} (\${${CommandArgumentTemplates.kEpisodeQuality}})';

      for (final EpisodeInfo x in selectedEpisodes) {
        if (options.download) {
          print(
            '${Dye.dye('${x.episode}.', 'lightGreen')} Episode ${x.episode} ${Dye.dye('[${x.locale.toPrettyString(appendCode: true)}]', 'darkGray')}',
          );
        }

        final List<EpisodeSource> episode =
            await mArgs.extractor.getSources(x.url, x.locale);

        final EpisodeSource? source = episode.firstWhereOrNull(
              (final EpisodeSource x) => x.quality.quality == preferredQuality,
            ) ??
            episode.firstWhereOrNull(
              (final EpisodeSource x) => x.quality.quality == fallbackQuality,
            );

        if (source == null) {
          throw CommandException(
            'Unable to find appropriate source for episode ${x.episode}!',
          );
        }

        final CommandArgumentTemplates argTemplates =
            CommandArgumentTemplates.withDefaultTemplates(
          <String, String>{
            CommandArgumentTemplates.kAnimeTitle: info.title,
            CommandArgumentTemplates.kAnimeURL: info.url,
            CommandArgumentTemplates.kAnimeLocale: info.locale.toPrettyString(),
            CommandArgumentTemplates.kAnimeLocaleCode:
                info.locale.toCodeString(),
            CommandArgumentTemplates.kEpisodeNumber: x.episode,
            CommandArgumentTemplates.kEpisodeQuality: source.quality.code,
            CommandArgumentTemplates.kEpisodeLocale:
                source.locale.toPrettyString(),
            CommandArgumentTemplates.kEpisodeLocaleCode:
                source.locale.toCodeString(),
            CommandArgumentTemplates.kModuleName: mArgs.metadata.name,
            CommandArgumentTemplates.kModuleId: mArgs.metadata.id,
          },
        );

        final String rDestination = argTemplates.replace(destination);
        final String rFilename = argTemplates.replace(filename);

        if (options.play) {
          final String? mpvPath =
              AppSettings.settings.mpvPath ?? await getMpvPath();
          if (mpvPath == null) {
            throw const CommandException('No mpv path was set in settings');
          }

          print(
            'Opening ${Dye.dye('episode ${x.episode}', 'cyan')} in ${Dye.dye('mpv', 'cyan')}.',
          );

          await Process.start(
            mpvPath,
            <String>[
              ...source.headers.entries.map(
                (final MapEntry<String, String> x) =>
                    '--http-header-fields-append=${x.key}:${x.value}',
              ),
              '--title=$rFilename',
              source.url,
            ],
            mode: ProcessStartMode.detached,
          );
        }

        if (options.download) {
          final String leftSpace =
              List<String>.filled(x.episode.length + 2, ' ').join();

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
            getDestination: ({
              required final String mimeType,
            }) {
              final String filePath =
                  path.join(rDestination, '$rFilename.$mimeType');

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
}
