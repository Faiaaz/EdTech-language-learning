import 'package:get/get.dart';

import 'package:ez_trainz/models/daily_streak.dart';
import 'package:ez_trainz/services/daily_streak_service.dart';

class StreakController extends GetxController {
  static StreakController get to => Get.find();

  final goal = const DailyGoal(minutesTarget: 5).obs;
  final state = DailyStreakState.defaults.obs;

  /// 0.0–1.0 progress for “today”.
  /// MVP: session-based (complete 1 session/day).
  final todayProgress = 0.0.obs;

  String get todayKey => _dateKey(DateTime.now());

  bool get isTodayComplete => todayProgress.value >= 1.0;

  @override
  void onInit() {
    super.onInit();
    // ignore: discarded_futures
    _hydrate();
  }

  Future<void> _hydrate() async {
    goal.value = await DailyStreakService.loadGoal();
    state.value = await DailyStreakService.loadState();
    _recomputeTodayProgress();
  }

  Future<void> setMinutesTarget(int minutes) async {
    final next = DailyGoal(minutesTarget: minutes.clamp(1, 60));
    goal.value = next;
    await DailyStreakService.saveGoal(next);
  }

  /// Call this when the daily session completes.
  Future<void> markTodayCompleted() async {
    // Idempotent: if already complete today, no streak changes.
    if (isTodayComplete) return;

    final now = DateTime.now();
    final today = _dateKey(now);
    final last = state.value.lastCompletedDate;

    int nextStreak = state.value.streakCount;
    if (last == null) {
      nextStreak = 1;
    } else if (last == today) {
      nextStreak = state.value.streakCount;
    } else {
      final yesterday = _dateKey(now.subtract(const Duration(days: 1)));
      nextStreak = (last == yesterday) ? (state.value.streakCount + 1) : 1;
    }

    final nextState = DailyStreakState(
      lastCompletedDate: today,
      streakCount: nextStreak,
      streakFreezes: state.value.streakFreezes,
    );

    state.value = nextState;
    todayProgress.value = 1.0;
    await DailyStreakService.saveState(nextState);
  }

  /// MVP: no partial progress; we still show a ring so future steps can increment it.
  void _recomputeTodayProgress() {
    final last = state.value.lastCompletedDate;
    todayProgress.value = (last != null && last == todayKey) ? 1.0 : 0.0;
  }

  static String _dateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

