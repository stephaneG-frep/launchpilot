import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/hosting.dart';

/// Réglages web par projet, dans les préférences (aucun secret).
class WebConfigRepository {
  WebConfigRepository(this._prefs);

  final SharedPreferences _prefs;

  static String key(int projectId) => 'lp.web.$projectId';

  WebProjectConfig load(int projectId) {
    final raw = _prefs.getString(key(projectId));
    if (raw == null) return const WebProjectConfig();
    try {
      return WebProjectConfig.fromJson((jsonDecode(raw) as Map).cast());
    } on Object {
      return const WebProjectConfig();
    }
  }

  Future<void> save(int projectId, WebProjectConfig config) =>
      _prefs.setString(key(projectId), jsonEncode(config.toJson()));

  Future<void> delete(int projectId) => _prefs.remove(key(projectId));

  Future<void> deleteAll() async {
    for (final k in _prefs.getKeys().where((k) => k.startsWith('lp.web.'))) {
      await _prefs.remove(k);
    }
  }
}
