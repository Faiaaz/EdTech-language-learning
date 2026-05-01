import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollectiblesController extends GetxController {
  static CollectiblesController get to => Get.find();

  static const _kLeavesKey = 'collectibles_leaves_v1';
  static const _kLesson1LeafKey = 'collectibles_leaf_lesson1_awarded_v1';

  final leaves = <DateTime>[].obs;

  @override
  void onInit() {
    super.onInit();
    // ignore: discarded_futures
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLeavesKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = (jsonDecode(raw) as List).cast<String>();
      final parsed = <DateTime>[];
      for (final s in list) {
        final dt = DateTime.tryParse(s);
        if (dt != null) parsed.add(dt);
      }
      leaves.assignAll(parsed);
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final list = leaves.map((d) => d.toIso8601String()).toList(growable: false);
    await prefs.setString(_kLeavesKey, jsonEncode(list));
  }

  /// Awards the Lesson 1 completion leaf exactly once.
  /// Returns `true` if a new leaf was added.
  Future<bool> awardLesson1LeafIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final already = prefs.getBool(_kLesson1LeafKey) ?? false;
    if (already) return false;
    await prefs.setBool(_kLesson1LeafKey, true);
    leaves.add(DateTime.now());
    await _persist();
    return true;
  }
}

