import 'dart:io';
import 'package:dl/dl.dart';
import 'package:mime_type/mime_type.dart';
import 'exceptions.dart';

enum SupportedPlatforms {
  windows,
  linux,
  mac,
}

final List<String> knownFileExtensions =
    'mp4,mp3,mpeg,ts,3gp,mov,mkv,webm,flv,avi,png,jpg,jpeg,gif,svg,bmp,m3u8'
        .split(',');

SupportedPlatforms getCurrentPlatform() {
  if (Platform.isWindows) return SupportedPlatforms.windows;
  if (Platform.isLinux) return SupportedPlatforms.linux;
  if (Platform.isMacOS) return SupportedPlatforms.mac;

  throw const UnsupportedPlatformException();
}

String? getFileExtensionFromURL(final String url) {
  try {
    final String ext =
        url.split('/').last.split(RegExp('[?#]')).first.split('.').last;

    if (knownFileExtensions.contains(ext)) {
      return ext;
    }
  } catch (_) {}

  return null;
}

String? getFileExtensionFromDLResponse(final DLResponse res) {
  final String? fromURL = getFileExtensionFromURL(res.request.uri.toString());
  if (fromURL != null) return fromURL;

  if (res.response.headers.contentType != null) {
    return extensionFromMime(res.response.headers.contentType!.mimeType);
  }

  return null;
}

Future<String?> getExecutablePathFromEnv(final String executable) async {
  ProcessResult? res;

  if (Platform.isWindows) {
    res = await Process.run('where', <String>[executable]);
  }

  if (Platform.isLinux || Platform.isMacOS) {
    res = await Process.run('which', <String>[executable]);
  }

  return res?.exitCode == 0 ? res!.stdout.toString().trim() : null;
}

Future<String?> getMpvPath() => getExecutablePathFromEnv('mpv');

String getFileSystemExecutable() => <SupportedPlatforms, String>{
      SupportedPlatforms.windows: 'explorer.exe',
      SupportedPlatforms.linux: 'xdg-open',
      SupportedPlatforms.mac: 'open',
    }[getCurrentPlatform()]!;

int? onlyIfAboveZero(final int value) => value >= 0 ? value : null;
