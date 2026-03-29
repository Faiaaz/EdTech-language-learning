import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:ez_trainz/models/game_session.dart';

class GameSessionException implements Exception {
  final String message;
  const GameSessionException(this.message);
}

class GameSessionService {
  static const _baseUrl =
      'https://bdmy1zi0va.execute-api.us-east-1.amazonaws.com';

  // ── Shared POST helper ───────────────────────────────────────────
  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final uri = Uri.parse('$_baseUrl$path');

    // ignore: avoid_print
    print('[GameSessionService] POST $uri');

    final headers = <String, String>{'Content-Type': 'application/json'};

    late http.Response response;
    try {
      response = await http
          .post(uri, headers: headers, body: jsonEncode(payload))
          .timeout(const Duration(seconds: 20));
    } on SocketException catch (e) {
      throw GameSessionException('No internet connection. ($e)');
    } on HandshakeException catch (e) {
      throw GameSessionException('SSL error. ($e)');
    } catch (e) {
      throw GameSessionException('Network error: $e');
    }

    // ignore: avoid_print
    print('[GameSessionService] Status: ${response.statusCode}');

    Map<String, dynamic> data = {};
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {}

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final apiMsg = data['message'] as String? ??
        data['error'] as String? ??
        'Request failed (${response.statusCode}).';
    throw GameSessionException(apiMsg);
  }

  // ── Shared GET helper ────────────────────────────────────────────
  static Future<dynamic> _get(String path) async {
    final uri = Uri.parse('$_baseUrl$path');

    // ignore: avoid_print
    print('[GameSessionService] GET $uri');

    final headers = <String, String>{'Content-Type': 'application/json'};

    late http.Response response;
    try {
      response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));
    } on SocketException catch (e) {
      throw GameSessionException('No internet connection. ($e)');
    } on HandshakeException catch (e) {
      throw GameSessionException('SSL error. ($e)');
    } catch (e) {
      throw GameSessionException('Network error: $e');
    }

    // ignore: avoid_print
    print('[GameSessionService] Status: ${response.statusCode}');

    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {}

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final apiMsg = (data is Map)
        ? (data['message'] as String? ??
            data['error'] as String? ??
            'Request failed (${response.statusCode}).')
        : 'Request failed (${response.statusCode}).';
    throw GameSessionException(apiMsg);
  }

  // ── POST /game-sessions/submit ──────────────────────────────────
  static Future<Map<String, dynamic>> submitSession({
    required String cognitoId,
    required String gameId,
    required int score,
    required int totalQuestions,
    required int correctAnswers,
    required int durationSeconds,
  }) async {
    return _post('/game-sessions/submit', {
      'cognitoId': cognitoId,
      'gameId': gameId,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'durationSeconds': durationSeconds,
    });
  }

  // ── GET /game-sessions/history/:cognitoId ───────────────────────
  static Future<List<GameSession>> fetchHistory(String cognitoId) async {
    final data = await _get('/game-sessions/history/$cognitoId');
    if (data is List) {
      return data
          .map((s) => GameSession.fromJson(s as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // ── GET /game-sessions/history/:cognitoId/:gameId ───────────────
  static Future<List<GameSession>> fetchGameHistory(
    String cognitoId,
    String gameId,
  ) async {
    final data = await _get('/game-sessions/history/$cognitoId/$gameId');
    if (data is List) {
      return data
          .map((s) => GameSession.fromJson(s as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
