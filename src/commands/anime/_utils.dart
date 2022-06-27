import 'dart:io';
import 'package:collection/collection.dart';
import 'package:dl/dl.dart';
import 'package:tenka/tenka.dart';
import 'package:utilx/utils.dart';
import '../../utils/custom_args.dart';
import '../../utils/others.dart';
import '../../utils/progress_bar.dart';

typedef GetDestinationFn = String Function({
  required String mimeType,
});

class AnimeDownloader {
  static Future<bool> download({
    required final String url,
    required final Map<String, String> headers,
    required final String leftSpace,
    required final bool ignoreIfFileExists,
    required final GetDestinationFn getDestination,
  }) async {
    final Downloader<DLProvider> downloader =
        Downloader<DLProvider>(provider: getProvider(url));

    final DLResponse dRes = await downloader.download(
      url: Uri.parse(url),
      headers: headers,
    );

    final File file = File(
      getDestination(mimeType: resolveFileExtensionFromDLResponse(dRes)!),
    );
    if (await file.exists()) {
      if (ignoreIfFileExists) {
        return false;
      }

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
    return true;
  }

  static DLProvider getProvider(final String url) {
    if (url.contains('.m3u8')) {
      return const M3U8DLProvider(
        outputFileExtension: M3U8OutputFileExtensions.mpeg,
      );
    }

    return const RawDLProvider();
  }

  static String? resolveFileExtensionFromDLResponse(final DLResponse res) {
    final String? value = getFileExtensionFromDLResponse(res);
    return value == 'm3u8' ? 'mpeg' : value;
  }
}

EpisodeSource? _resolveEpisodeSourceIfCustomQuality(
  final List<EpisodeSource> sources,
  final Quality quality,
) {
  if (QualityArgs.customQualityCodes.contains(quality.code)) {
    final CustomQualities customQuality =
        EnumUtils.find(CustomQualities.values, quality.code);

    switch (customQuality) {
      case CustomQualities.best:
        final EpisodeSource? picked = sources.firstOrNull;
        return picked != null &&
                _getWeightageFromQualityCode(picked.quality) != 0
            ? picked
            : null;

      case CustomQualities.worst:
        return sources.lastOrNull;
    }
  }

  return null;
}

int _getWeightageFromQualityCode(final Quality quality) =>
    int.tryParse(quality.code.substring(0, quality.code.length - 1)) ?? 0;

EpisodeSource? resolveEpisodeSource({
  required final List<EpisodeSource> sources,
  required final Quality preferredQuality,
  required final Quality fallbackQuality,
}) {
  final List<EpisodeSource> sorted = (<EpisodeSource>[...sources]..sort(
          (final EpisodeSource a, final EpisodeSource b) =>
              _getWeightageFromQualityCode(a.quality)
                  .compareTo(_getWeightageFromQualityCode(b.quality)),
        ))
      .reversed
      .toList();

  return _resolveEpisodeSourceIfCustomQuality(sorted, preferredQuality) ??
      sorted.firstWhereOrNull(
        (final EpisodeSource x) =>
            x.quality.quality == preferredQuality.quality,
      ) ??
      _resolveEpisodeSourceIfCustomQuality(sorted, fallbackQuality) ??
      sorted.firstWhereOrNull(
        (final EpisodeSource x) => x.quality.quality == fallbackQuality.quality,
      );
}
