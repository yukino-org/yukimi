import 'dart:io';
import 'package:dl/dl.dart';
import 'package:mime_type/mime_type.dart';

final List<String> knownFileExtensions =
    'mp4,mp3,mpeg,ts,3gp,mov,mkv,webm,flv,avi,png,jpg,jpeg,gif,svg,bmp'
        .split(',');

String? getExtensionFromURL(final String url) {
  try {
    final String ext =
        url.split('/').last.split(RegExp('[?#]')).first.split('.').last;

    if (knownFileExtensions.contains(ext)) {
      return ext;
    }
  } catch (_) {}

  return null;
}

String? extensionFromDLResponse(final DLResponse res) {
  final String? fromURL = getExtensionFromURL(res.request.uri.toString());
  if (fromURL != null) return fromURL;

  if (res.response.headers.contentType != null) {
    return extensionFromMime(res.response.headers.contentType!.mimeType);
  }

  return null;
}

Future<String?> getEnvPath(final String executable) async {
  ProcessResult? res;

  if (Platform.isWindows) {
    res = await Process.run('where', <String>[executable]);
  }

  if (Platform.isLinux || Platform.isMacOS) {
    res = await Process.run('which', <String>[executable]);
  }

  return res?.exitCode == 0 ? res!.stdout.toString().trim() : null;
}

Future<String?> getMpvPath() => getEnvPath('mpv');

String getFileSystemExecutable() {
  if (Platform.isWindows) return 'explorer.exe';
  if (Platform.isLinux) return 'xdg-open';
  if (Platform.isMacOS) return 'open';

  throw Exception('Unknown platform');
}
