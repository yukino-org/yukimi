import 'constants.dart';

export 'meta.g.dart';

abstract class AppMeta {
  static const String _githubUser = 'yukino-org';
  static const String _githubRepo = Constants.appId;
  static const String github = 'https://github.com/$_githubUser/$_githubRepo';
  static const String patreon = 'https://www.patreon.com/yukino_org';

  static const String lastestVersionEndpoint =
      'https://raw.githubusercontent.com/$_githubUser/$_githubRepo/dist-data/version.txt';
}
