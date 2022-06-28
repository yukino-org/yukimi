export 'meta.g.dart';

abstract class AppMeta {
  static const String name = 'Yukimi';
  static const String id = 'yukimi';
  static const String description =
      'Anime/Manga command-line interface backed up by Tenka.';

  static const String _github = 'yukino-org/yukimi';
  static const String github = 'https://github.com/$_github';
  static const String patreon = 'https://www.patreon.com/yukino_org';

  static const String latestReleaseEndpoint =
      'https://api.github.com/repos/$_github/releases/latest';
}
