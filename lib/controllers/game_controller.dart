import 'package:get/get.dart';

import 'package:ez_trainz/models/game.dart';
import 'package:ez_trainz/services/game_service.dart';

class GameController extends GetxController {
  static GameController get to => Get.find();

  // ── Observable state ─────────────────────────────────────────────
  final games = <Game>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  final _selectedGame = Rxn<Game>();
  Game? get selectedGame => _selectedGame.value;

  // ── Load all games ───────────────────────────────────────────────
  Future<void> loadGames() async {
    isLoading.value = true;
    error.value = '';
    try {
      games.value = await GameService.fetchGames();
    } on GameException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Load games for a specific lesson ────────────────────────────
  Future<void> loadGamesByLesson(String lessonId) async {
    isLoading.value = true;
    error.value = '';
    try {
      games.value = await GameService.fetchGamesByLesson(lessonId);
    } on GameException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Select a game ────────────────────────────────────────────────
  void selectGame(Game game) {
    _selectedGame.value = game;
  }

  // ── Fetch single game detail ─────────────────────────────────────
  Future<void> loadGame(String id) async {
    isLoading.value = true;
    error.value = '';
    try {
      _selectedGame.value = await GameService.fetchGame(id);
    } on GameException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Delete a game ────────────────────────────────────────────────
  Future<void> deleteGame(String id) async {
    try {
      await GameService.deleteGame(id);
      games.removeWhere((g) => g.id == id);
    } on GameException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    }
  }
}
