import 'dart:io';

final List<String> knownFileExtensions =
    'mp4,mp3,mpeg,ts,3gp,mov,mkv,webm,flv,avi'.split(',');

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
