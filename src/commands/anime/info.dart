import 'dart:io';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:tenka/tenka.dart';
import 'package:utilx/locale.dart';
import '../../core/commander.dart';
import '../../core/database/cache.dart';
import '../../core/database/settings.dart';
import '../../core/manager.dart';
import '../../utils/console.dart';
import '../../utils/content_range.dart';
import '../../utils/custom_args.dart';
import '../../utils/exceptions.dart';
import '../../utils/others.dart';
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

  static const String kQuality = 'quality';
  static const String kQualityAbbr = 'q';
  static final List<String> kQualityAllowed = QualityArgs.allQualityCodes;
  String? get quality => getNullable(kQuality);

  static const String kFallbackQuality = 'fallbackQuality';
  static const List<String> kFallbackQualityAliases = <String>['fq'];
  static final List<String> kFallbackQualityAllowed = kQualityAllowed;
  String? get fallbackQuality => getNullable(kFallbackQuality);

  static const String kSearch = 'search';
  bool get search => get<bool>(kSearch);

  static const String kIgnoreExistingFiles = 'ignore-existing-files';
  static const String kIgnoreExistingFilesAbbr = 'i';
  bool get ignoreExistingFiles => get<bool>(kIgnoreExistingFiles);
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
        _Options.kQuality,
        abbr: _Options.kQualityAbbr,
        allowed: _Options.kQualityAllowed,
      )
      ..addOption(
        _Options.kFallbackQuality,
        aliases: _Options.kFallbackQualityAliases,
        allowed: _Options.kFallbackQualityAllowed,
      )
      ..addFlag(_Options.kSearch)
      ..addFlag(
        _Options.kIgnoreExistingFiles,
        abbr: _Options.kIgnoreExistingFilesAbbr,
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

    final AnimeInfo? cached = !options.noCache
        ? Cache.cache.getAnime(mArgs.metadata.id, getInfoURL)
        : null;

    final AnimeInfo info =
        cached ?? await mArgs.extractor.getInfo(getInfoURL, getInfoLocale);

    await Cache.cache.saveAnime(mArgs.metadata.id, info);

    if (AppManager.isJsonMode) {
      printJson(info.toJson());
      return;
    }

    final ContentRange? range = options.episodes != null
        ? ContentRange.parse(
            options.episodes!,
            allowed:
                info.episodes.map((final EpisodeInfo x) => x.episode).toList(),
          )
        : null;

    printHeading('Anime Information');
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
        '$i ${Dye.dye(x.url, 'lightCyan/underline')} ${Dye.dye('[${x.locale.toPrettyString(appendCode: true)}]', 'dark')}',
      );
    }

    if (options.download && options.play) {
      throw const CommandException(
        '--${_Options.kDownload} and --${_Options.kPlay} are not supported together.',
      );
    }

    if (selectedEpisodes.isNotEmpty) {
      println();

      if (options.download) {
        printHeading('Downloads');
      } else if (options.play) {
      } else {
        printHeading('Sources');
      }

      if (options.play && selectedEpisodes.length != 1) {
        throw CommandException.invalidOption(
          'episodes (Only one episode can be played at a time)',
        );
      }

      final String destination =
          options.destination ?? AppSettings.settings.animeDownloadDestination;

      final String subDestination = options.subDestination ??
          AppSettings.settings.animeDownloadSubDestination;

      final String filename =
          options.filename ?? AppSettings.settings.animeDownloadFilename;

      final String _preferredQuality =
          options.quality ?? AppSettings.settings.animePreferredQuality;
      final Quality preferredQuality = QualityArgs.parse(_preferredQuality);

      final String _fallbackQuality =
          options.fallbackQuality ?? AppSettings.settings.animeFallbackQuality;
      final Quality fallbackQuality = QualityArgs.parse(_fallbackQuality);

      for (final EpisodeInfo x in selectedEpisodes) {
        print(
          '${Dye.dye('${x.episode}.', 'lightGreen')} Episode ${x.episode} ${Dye.dye('[${x.locale.toPrettyString(appendCode: true)}]', 'dark')}',
        );

        final List<EpisodeSource> sources =
            await mArgs.extractor.getSources(x.url, x.locale);

        final EpisodeSource? source = resolveEpisodeSource(
          sources: sources,
          preferredQuality: preferredQuality,
          fallbackQuality: fallbackQuality,
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
        final String rSubDestination = argTemplates.replace(subDestination);
        final String rFilename = argTemplates.replace(filename);

        final String leftSpace = ' ' * (x.episode.length + 2);

        print(
          leftSpace +
              Dye.dye('Quality: ', 'dark').toString() +
              Dye.dye(source.quality.code, 'dark').toString(),
        );
        print(leftSpace + Dye.dye('Source: ', 'dark').toString());
        print(
          leftSpace +
              Dye.dye('  URL: ', 'dark').toString() +
              Dye.dye(source.url, 'dark/underline').toString(),
        );
        if (source.headers.isNotEmpty) {
          print(leftSpace + Dye.dye('  Headers: ', 'dark').toString());
          source.headers.forEach((final String k, final String v) {
            print(leftSpace + Dye.dye('    $k: $v', 'dark').toString());
          });
        }

        if (options.play) {
          final String? mpvPath =
              AppSettings.settings.mpvPath ?? await getMpvPath();
          if (mpvPath == null) {
            throw const CommandException('No mpv path was set in settings');
          }

          println();
          print(
            'Opening ${Dye.dye('episode ${x.episode}', 'lightCyan')} in ${Dye.dye('mpv', 'lightCyan')}.',
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
          await AnimeDownloader.download(
            leftSpace: leftSpace,
            url: source.url,
            headers: source.headers,
            ignoreIfFileExists: options.ignoreExistingFiles,
            getDestination: ({
              required final String mimeType,
            }) {
              final String filePath = path.join(
                rDestination,
                rSubDestination,
                '$rFilename.$mimeType',
              );

              print(
                leftSpace +
                    Dye.dye('Output: ', 'default').toString() +
                    Dye.dye(filePath, 'lightCyan/underline').toString(),
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
