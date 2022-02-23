import 'dart:io';
import 'package:dl/dl.dart';
import 'package:utilx/utilities/utils.dart';
import '../../utils/progress_bar.dart';

class AnimeDownloader {
  static Future<void> download({
    required final String url,
    required final Map<String, String> headers,
    required final String destination,
  }) async {
    final Downloader<DLProvider> downloader =
        Downloader<DLProvider>(provider: getProvider(url));

    final File file = File(destination);
    await FSUtils.ensureFile(file);

    final FileDLResponse res = await downloader.downloadToFile(
      url: Uri.parse(url),
      headers: headers,
      file: file,
    );

    const ProgressBar bar = ProgressBar(25);
    res.progress.listen((final DLProgress progress) {
      bar.set(progress.percent);
    });

    await res.asFuture();
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
