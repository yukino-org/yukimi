import 'dart:io';
import 'package:path/path.dart' as path;
import './utils.dart';

final String pubspecPath = path.join(Paths.rootDir, 'pubspec.yaml');
final String metaPath = path.join(Paths.libDir, 'config/meta.g.dart');

Future<void> main() async {
  final String pubspec = await File(pubspecPath).readAsString();

  final String version =
      RegExp(r'version: ([\w-.]+)').firstMatch(pubspec)!.group(1)!;

  final String content = '''
abstract class GeneratedAppMeta {
  static const String version = '$version';
}'''
      .trim();

  print(
    '''
```
$content
```
  '''
        .trim(),
  );

  await File(metaPath).writeAsString(content);

  print('\nGenerated $metaPath');
}
