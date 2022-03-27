import 'dart:io';
import 'package:tenka/tenka.dart';
import 'package:utilx_desktop/webview/puppeteer/provider.dart';
import '../config/constants.dart';
import '../config/paths.dart';
import 'database/settings.dart';

Map<String, String>? _storeIdNameMap;

extension TenkaRepositoryUtils on TenkaRepository {
  Map<String, String> get storeNameIdMap =>
      _storeIdNameMap ??= store.modules.map(
        (final String i, final TenkaMetadata x) => MapEntry<String, String>(
          x.name.toLowerCase(),
          x.id,
        ),
      );
}

abstract class TenkaManager {
  static late final TenkaRepository repository;

  static Future<void> initialize() async {
    await TenkaInternals.initialize(
      runtime: TenkaRuntimeOptions(
        http: TenkaRuntimeHttpClientOptions(
          ignoreSSLCertificate: AppSettings.settings.ignoreSSLCertificate,
        ),
        webview: WebviewManagerInitializeOptions(
          PuppeteerProvider(),
          WebviewProviderOptions(
            localChromiumPath: Paths.chromiumDataDir,
            devMode: Platform.environment['YUKIMI_DEV_MODE'] == 'true',
          ),
        ),
      ),
    );

    repository = TenkaRepository(
      resolver: const TenkaStoreURLResolver(deployMode: Constants.storeRef),
      baseDir: Paths.tenkaModulesDir,
    );

    await repository.initialize();
  }

  static Future<T> getExtractor<T>(final TenkaMetadata metadata) async {
    final TenkaRuntimeInstance runtime = await TenkaRuntimeManager.create();
    await runtime.loadScriptCode('', appendDefinitions: true);
    await runtime.loadByteCode((metadata.source as TenkaBase64DS).data);
    return runtime.getExtractor<T>();
  }

  static Future<void> dispose() async {
    await TenkaInternals.dispose();
  }
}
