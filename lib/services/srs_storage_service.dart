import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SrsStorageService {
  static const _kSm2Cards = 'sm2_srs_cards_v1';

  static Future<List<Map<String, dynamic>>> loadSm2Cards() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSm2Cards);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final jsonVal = jsonDecode(raw);
      if (jsonVal is! List) return const [];
      return jsonVal
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<void> saveSm2Cards(List<Map<String, dynamic>> cards) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSm2Cards, jsonEncode(cards));
  }
}

