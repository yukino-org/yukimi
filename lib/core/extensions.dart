import 'package:extensions/extensions.dart';
import 'package:extensions/metadata.dart';
import 'package:extensions/runtime.dart';
import 'package:utilx_desktop/utilities/webview/providers/puppeteer/provider.dart';
import './settings.dart';
import '../config/constants.dart';
import '../config/paths.dart';

Map<String, String>? _storeIdNameMap;

extension ExtensionsUtils on ERepository {
  Map<String, String> get storeNameIdMap =>
      _storeIdNameMap ??= store.extensions.map(
        (final String i, final EStoreMetadata x) => MapEntry<String, String>(
          x.metadata.name.toLowerCase(),
          x.metadata.id,
        ),
      );
}

abstract class ExtensionsManager {
  static late final ERepository repository;

  static Future<void> initialize() async {
    await AppSettings.initialize();

    await EInternals.initialize(
      runtime: ERuntimeOptions(
        http: HttpClientOptions(
          ignoreSSLCertificate: AppSettings.settings.ignoreSSLCertificate,
        ),
        webview: WebviewManagerInitializeOptions(
          PuppeteerProvider(),
          WebviewProviderOptions(localChromiumPath: Paths.chromiumDataDir),
        ),
      ),
    );

    repository = ERepository(
      urlResolver: const EStoreURLResolver(deployMode: Constants.storeRef),
      baseDir: Paths.extensionsDir,
    );

    await repository.initialize();
  }

  static Future<T> getExtractor<T>(final EStoreMetadata metadata) async {
    final ERuntimeInstance runtime = await ERuntimeManager.create();
    await runtime.loadScriptCode('', appendDefinitions: true);
    await runtime.loadByteCode((metadata.metadata.source as EBase64DS).data);
    return runtime.getExtractor<T>();
  }
}
