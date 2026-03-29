import 'package:get/get.dart';

import 'package:ez_trainz/models/game_session.dart';
import 'package:ez_trainz/services/game_session_service.dart';

class GameSessionController extends GetxController {
  static GameSessionController get to => Get.find();

  // ── Observable state ─────────────────────────────────────────────
  final sessions = <GameSession>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  // ── Submit a game session ────────────────────────────────────────
  Future<bool> submitSession({
    required String cognitoId,
    required String gameId,
    required int score,
    required int totalQuestions,
    required int correctAnswers,
    required int durationSeconds,
  }) async {
    isLoading.value = true;
    error.value = '';
    try {
      await GameSessionService.submitSession(
        cognitoId: cognitoId,
        gameId: gameId,
        score: score,
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswers,
        durationSeconds: durationSeconds,
      );
      return true;
    } on GameSessionException catch (e) {
      error.value = e.message;
      return false;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Load full history for a user ─────────────────────────────────
  Future<void> loadHistory(String cognitoId) async {
    isLoading.value = true;
    error.value = '';
    try {
      sessions.value = await GameSessionService.fetchHistory(cognitoId);
    } on GameSessionException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Load history for a specific game ─────────────────────────────
  Future<void> loadGameHistory(String cognitoId, String gameId) async {
    isLoading.value = true;
    error.value = '';
    try {
      sessions.value =
          await GameSessionService.fetchGameHistory(cognitoId, gameId);
    } on GameSessionException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
