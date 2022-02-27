import 'dart:convert';
import 'dart:io';
import 'package:tenka/tenka.dart';
import 'package:utilx/utilities/utils.dart';
import '../../config/paths.dart';

typedef CacheItem = Map<String, Map<dynamic, dynamic>>;

class Cache {
  Cache._({
    final CacheItem? animeInfo,
    final CacheItem? mangaInfo,
  })  : animeInfo = animeInfo ?? <String, Map<dynamic, dynamic>>{},
        mangaInfo = mangaInfo ?? <String, Map<dynamic, dynamic>>{};

  factory Cache._fromJson(final Map<dynamic, dynamic> json) => Cache._(
        animeInfo: (json['animeInfo'] as Map<dynamic, dynamic>?)
            ?.cast<String, Map<dynamic, dynamic>>(),
        mangaInfo: (json['mangaInfo'] as Map<dynamic, dynamic>?)
            ?.cast<String, Map<dynamic, dynamic>>(),
      );

  final Map<String, Map<dynamic, dynamic>> animeInfo;
  final Map<String, Map<dynamic, dynamic>> mangaInfo;

  AnimeInfo? getAnime(final String moduleId, final String url) {
    final Map<dynamic, dynamic>? json = animeInfo['${moduleId}_$url'];

    if (json != null) {
      try {
        return AnimeInfo.fromJson(json);
      } catch (_) {}
    }

    return null;
  }

  MangaInfo? getManga(final String moduleId, final String url) {
    final Map<dynamic, dynamic>? json = mangaInfo['${moduleId}_$url'];

    if (json != null) {
      try {
        return MangaInfo.fromJson(json);
      } catch (_) {}
    }

    return null;
  }

  Future<void> saveAnime(final String moduleId, final AnimeInfo info) async {
    _updateCache(animeInfo, '${moduleId}_${info.url}', info.toJson());
    await _save();
  }

  Future<void> saveManga(final String moduleId, final MangaInfo info) async {
    _updateCache(mangaInfo, '${moduleId}_${info.url}', info.toJson());
    await _save();
  }

  void _updateCache(
    final Map<dynamic, dynamic> parent,
    final String key,
    final Map<dynamic, dynamic> value,
  ) {
    parent.remove(key);
    if (parent.length > _limit) {
      parent.keys
          .cast<String>()
          .toList()
          .sublist(0, parent.length - _limit)
          .forEach(parent.remove);
    }
    parent[key] = value;
  }

  Future<void> _save() async {
    final File file = File(Paths.cacheFilePath);
    await FSUtils.ensureFile(file);
    await file.writeAsString(json.encode(_toJson()));
  }

  Map<dynamic, dynamic> _toJson() => <dynamic, dynamic>{
        'animeInfo': animeInfo,
        'mangaInfo': mangaInfo,
      };

  static late final Cache cache;

  static const int _limit = 10;

  static Future<void> initialize() async {
    final File file = File(Paths.cacheFilePath);

    if (await file.exists()) {
      cache = Cache._fromJson(
        json.decode(await file.readAsString()) as Map<dynamic, dynamic>,
      );
    } else {
      cache = Cache._();
    }
  }
}
