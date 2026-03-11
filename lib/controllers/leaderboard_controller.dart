import 'package:get/get.dart';

import 'package:ez_trainz/models/leaderboard_entry.dart';
import 'package:ez_trainz/services/leaderboard_service.dart';

class LeaderboardController extends GetxController {
  static LeaderboardController get to => Get.find();

  // ── Observable state ─────────────────────────────────────────────
  final entries = <LeaderboardEntry>[].obs;
  final myEntry = Rxn<LeaderboardEntry>();
  final isLoading = false.obs;
  final error = ''.obs;

  // ── Which view is active ─────────────────────────────────────────
  final selectedGameId = Rxn<String>();

  // ── Load global leaderboard ──────────────────────────────────────
  Future<void> loadGlobal() async {
    isLoading.value = true;
    error.value = '';
    selectedGameId.value = null;
    try {
      entries.value = await LeaderboardService.fetchGlobal();
    } on LeaderboardException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Load leaderboard for a specific game ─────────────────────────
  Future<void> loadByGame(String gameId) async {
    isLoading.value = true;
    error.value = '';
    selectedGameId.value = gameId;
    try {
      entries.value = await LeaderboardService.fetchByGame(gameId);
    } on LeaderboardException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Load my rank ─────────────────────────────────────────────────
  Future<void> loadMyRank(String cognitoId) async {
    try {
      myEntry.value = await LeaderboardService.fetchMyRank(cognitoId);
    } on LeaderboardException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    }
  }

  // ── Load stream global leaderboard ───────────────────────────────
  Future<void> loadStreamGlobal() async {
    isLoading.value = true;
    error.value = '';
    try {
      entries.value = await LeaderboardService.fetchStreamGlobal();
    } on LeaderboardException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Load stream leaderboard for a specific game ──────────────────
  Future<void> loadStreamByGame(String gameId) async {
    isLoading.value = true;
    error.value = '';
    try {
      entries.value = await LeaderboardService.fetchStreamByGame(gameId);
    } on LeaderboardException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
