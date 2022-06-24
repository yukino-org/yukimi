import 'dart:io';
import 'package:dl/dl.dart';
import 'package:tenka/tenka.dart';
import '../../utils/others.dart';
import '../../utils/progress_bar.dart';

typedef GetDestinationFn = String Function({
  required String mimeType,
});

class AnimeDownloader {
  static Future<void> download({
    required final String url,
    required final Map<String, String> headers,
    required final GetDestinationFn getDestination,
    required final String leftSpace,
  }) async {
    final Downloader<DLProvider> downloader =
        Downloader<DLProvider>(provider: getProvider(url));

    final DLResponse dRes = await downloader.download(
      url: Uri.parse(url),
      headers: headers,
    );

    final File file = File(
      getDestination(mimeType: getFileExtensionFromDLResponse(dRes)!),
    );
    if (await file.exists()) {
      await file.delete(recursive: true);
    }

    final FileDLResponse fRes =
        await downloader.downloadToFileFromDLResponse(dRes, file);

    const ProgressBar bar = ProgressBar();
    fRes.progress.listen((final DLProgress progress) {
      bar.set(
        progress.percent,
        current: onlyIfAboveZero(progress.current),
        total: onlyIfAboveZero(progress.total),
        prefix: leftSpace,
      );
    });

    await fRes.asFuture();
    bar.end();
  }

  static DLProvider getProvider(final String url) {
    if (url.contains('.m3u8')) {
      return const M3U8DLProvider(
        outputFileExtension: M3U8OutputFileExtensions.mpeg,
      );
    }

    return const RawDLProvider();
  }
}

Qualities? resolveQuality(final String value) {
  try {
    return Quality.parse(value).quality;
  } catch (_) {}

  return null;
}
