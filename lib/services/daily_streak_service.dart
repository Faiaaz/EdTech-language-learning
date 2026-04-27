import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:ez_trainz/models/daily_streak.dart';

class DailyStreakService {
  static const _kGoal = 'daily_goal_v1';
  static const _kStreak = 'daily_streak_state_v1';

  static Future<DailyGoal> loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kGoal);
    if (raw == null || raw.isEmpty) return const DailyGoal();
    try {
      final jsonVal = jsonDecode(raw);
      if (jsonVal is Map<String, dynamic>) return DailyGoal.fromJson(jsonVal);
      if (jsonVal is Map) return DailyGoal.fromJson(Map<String, dynamic>.from(jsonVal));
      return const DailyGoal();
    } catch (_) {
      return const DailyGoal();
    }
  }

  static Future<void> saveGoal(DailyGoal goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kGoal, jsonEncode(goal.toJson()));
  }

  static Future<DailyStreakState> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStreak);
    if (raw == null || raw.isEmpty) return DailyStreakState.defaults;
    try {
      final jsonVal = jsonDecode(raw);
      if (jsonVal is Map<String, dynamic>) return DailyStreakState.fromJson(jsonVal);
      if (jsonVal is Map) return DailyStreakState.fromJson(Map<String, dynamic>.from(jsonVal));
      return DailyStreakState.defaults;
    } catch (_) {
      return DailyStreakState.defaults;
    }
  }

  static Future<void> saveState(DailyStreakState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kStreak, jsonEncode(state.toJson()));
  }
}

