import 'dart:io';
import 'package:dl/dl.dart';
import 'package:tenka/tenka.dart';
import 'package:utilx/utils.dart';
import '../../utils/others.dart';
import '../../utils/path.dart';
import '../../utils/progress_bar.dart';

typedef GetDestinationFn = String Function(DLPageData);

class DLPageData {
  const DLPageData({
    required this.page,
    required this.index,
    required this.mimeType,
    required this.data,
  });

  final PageInfo page;
  final int index;
  final String mimeType;
  final List<int> data;
}

class MangaDownloader {
  static const Downloader<RawDLProvider> downloader =
      Downloader<RawDLProvider>(provider: RawDLProvider());

  static Future<void> download({
    required final List<PageInfo> pages,
    required final MangaExtractor extractor,
    required final GetDestinationFn getDestination,
    required final String leftSpace,
  }) async {
    const ProgressBar bar = ProgressBar();

    int current = 0;
    final int total = pages.length;
    void incrementBar() {
      current++;
      bar.set(
        (current / total) * 100,
        current: onlyIfAboveZero(current),
        total: onlyIfAboveZero(total),
        prefix: leftSpace,
      );
    }

    await Future.wait<void>(
      pages.asMap().keys.map((final int i) async {
        final PageInfo x = pages[i];
        final ImageDescriber image = await extractor.getPage(x.url, x.locale);
        final DLResponse res = await downloader.download(
          url: Uri.parse(image.url),
          headers: image.headers,
        );

        final DLPageData data = DLPageData(
          page: x,
          index: i,
          mimeType: extensionFromDLResponse(res)!,
          data: await res.data.fold<List<int>>(
            <int>[],
            (final List<int> p, final List<int> x) => p..addAll(x),
          ),
        );

        final File file = File(getDestination(data));
        await FSUtils.ensureFile(file);
        await file.writeAsBytes(data.data);

        incrementBar();
      }),
    );

    bar.end();
  }
}
