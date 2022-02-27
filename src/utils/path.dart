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
