import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:ez_trainz/models/avatar_config.dart';
import 'package:ez_trainz/models/xp_event.dart';

/// Local persistence for avatar config + XP event log.
///
/// Uses `shared_preferences` (already in the project) so behavior is
/// consistent across web / mobile. The secure storage service is
/// reserved for auth tokens per its own doc note.
///
/// When the backend ships real XP endpoints, the controller can call
/// those and this class becomes a cache in front of them.
class AvatarStorageService {
  static const _kAvatarKey = 'journey_avatar_config_v1';
  static const _kXpEventsKey = 'journey_xp_events_v1';

  static Future<AvatarConfig?> loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return AvatarConfig.tryDecode(prefs.getString(_kAvatarKey));
  }

  static Future<void> saveAvatar(AvatarConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAvatarKey, config.encode());
  }

  static Future<void> clearAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAvatarKey);
  }

  static Future<List<XpEvent>> loadXpEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kXpEventsKey) ?? const [];
    return raw
        .map((s) {
          try {
            final decoded = jsonDecode(s);
            if (decoded is Map<String, dynamic>) return XpEvent.fromJson(decoded);
          } catch (_) {}
          return null;
        })
        .whereType<XpEvent>()
        .toList();
  }

  static Future<void> saveXpEvents(List<XpEvent> events) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kXpEventsKey,
      events.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  static Future<void> clearXpEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kXpEventsKey);
  }
}
