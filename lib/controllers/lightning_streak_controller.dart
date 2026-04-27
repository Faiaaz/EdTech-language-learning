import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Duolingo-style "Lightning Streak" for in-lesson combos.
/// Persists across app restarts.
class LightningStreakController extends GetxController {
  static LightningStreakController get to => Get.find();

  static const _kStreak = 'lightning_streak_v1';
  static const _kBest = 'lightning_best_v1';

  final streak = 0.obs;
  final best = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // ignore: discarded_futures
    _hydrate();
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    streak.value = prefs.getInt(_kStreak) ?? 0;
    best.value = prefs.getInt(_kBest) ?? 0;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kStreak, streak.value);
    await prefs.setInt(_kBest, best.value);
  }

  Future<void> correct() async {
    streak.value = streak.value + 1;
    if (streak.value > best.value) best.value = streak.value;
    await _persist();
  }

  Future<void> wrong() async {
    streak.value = 0;
    await _persist();
  }

  Future<void> reset() async {
    streak.value = 0;
    best.value = 0;
    await _persist();
  }
}

