import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:utilx/utils.dart';

abstract class AtomicFS {
  static Future<void> writeFileAtomically(
    final File target,
    final List<int> data,
  ) async {
    final String tmpPath = path.join(
      path.dirname(target.path),
      'tmp-${path.basename(target.path)}',
    );
    await FSUtils.ensureDirectory(Directory(path.dirname(tmpPath)));
    final File tmpTarget = File(tmpPath);
    await tmpTarget.writeAsBytes(data);
    await tmpTarget.rename(target.path);
  }
}
