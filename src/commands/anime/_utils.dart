import 'dart:io';
import 'package:dl/dl.dart';
import 'package:utilx/utilities/utils.dart';
import '../../utils/command_exception.dart';
import '../../utils/progress_bar.dart';

List<String> parseEpisodes(final List<String> args) {
  final List<String> result = <String>[];

  for (final String x in args) {
    final List<String> splitted = x.split(RegExp(r'-|\.{2,3}'));
    switch (splitted.length) {
      case 1:
        result.addAll(splitted);
        break;

      case 2:
        final int a = int.parse(splitted[0]);
        final int b = int.parse(splitted[1]);
        final int range = b - a + 1;
        if (range < 1) throw CRTException('Invalid range: $x (Bad Range)');
        result.addAll(
          List<String>.generate(range, (final int i) => (a + i).toString()),
        );
        break;

      default:
        throw CRTException('Invalid range: $x');
    }
  }

  return result;
}

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
