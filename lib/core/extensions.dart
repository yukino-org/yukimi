import 'package:extensions/extensions.dart';
import 'package:extensions/metadata.dart';
import 'package:extensions/runtime.dart';
import 'package:utilx_desktop/utilities/webview/providers/puppeteer/provider.dart';
import './settings.dart';
import '../config/constants.dart';
import '../config/paths.dart';

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
}
