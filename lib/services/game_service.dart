import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:ez_trainz/models/game.dart';

class GameException implements Exception {
  final String message;
  const GameException(this.message);
}

class GameService {
  static const _baseUrl =
      'https://bdmy1zi0va.execute-api.us-east-1.amazonaws.com';

  /// Extracts Cognito `sub` from a JWT (used by gamification endpoints).
  ///
  /// Returns null if token is missing/invalid or payload can't be decoded.
  static String? extractSubFromToken(String? jwt) {
    if (jwt == null || jwt.isEmpty) return null;
    final parts = jwt.split('.');
    if (parts.length < 2) return null;
    try {
      final payloadSeg = parts[1];
      final normalized = base64Url.normalize(payloadSeg);
      final bytes = base64Url.decode(normalized);
      final jsonStr = utf8.decode(Uint8List.fromList(bytes));
      final payload = jsonDecode(jsonStr);
      if (payload is Map<String, dynamic>) {
        final sub = payload['sub'];
        return sub is String ? sub : null;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── Shared GET helper ────────────────────────────────────────────
  static Future<dynamic> _get(String path) async {
    final uri = Uri.parse('$_baseUrl$path');

    // ignore: avoid_print
    print('[GameService] GET $uri');

    final headers = <String, String>{'Content-Type': 'application/json'};

    late http.Response response;
    try {
      response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));
    } on SocketException catch (e) {
      throw GameException('No internet connection. ($e)');
    } on HandshakeException catch (e) {
      throw GameException('SSL error. ($e)');
    } catch (e) {
      throw GameException('Network error: $e');
    }

    // ignore: avoid_print
    print('[GameService] Status: ${response.statusCode}');

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
    throw GameException(apiMsg);
  }

  // ── Shared DELETE helper ─────────────────────────────────────────
  static Future<dynamic> _delete(String path) async {
    final uri = Uri.parse('$_baseUrl$path');

    // ignore: avoid_print
    print('[GameService] DELETE $uri');

    final headers = <String, String>{'Content-Type': 'application/json'};

    late http.Response response;
    try {
      response = await http
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: 20));
    } on SocketException catch (e) {
      throw GameException('No internet connection. ($e)');
    } on HandshakeException catch (e) {
      throw GameException('SSL error. ($e)');
    } catch (e) {
      throw GameException('Network error: $e');
    }

    // ignore: avoid_print
    print('[GameService] Status: ${response.statusCode}');

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
    throw GameException(apiMsg);
  }

  // ── GET /games ───────────────────────────────────────────────────
  static Future<List<Game>> fetchGames() async {
    final data = await _get('/games');
    if (data is List) {
      return data
          .map((g) => Game.fromJson(g as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // ── GET /games/:id ──────────────────────────────────────────────
  static Future<Game> fetchGame(String id) async {
    final data = await _get('/games/$id');
    return Game.fromJson(data as Map<String, dynamic>);
  }

  // ── GET /games/lesson/:lessonId ─────────────────────────────────
  static Future<List<Game>> fetchGamesByLesson(String lessonId) async {
    final data = await _get('/games/lesson/$lessonId');
    if (data is List) {
      return data
          .map((g) => Game.fromJson(g as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // ── DELETE /games/:id ───────────────────────────────────────────
  static Future<void> deleteGame(String id) async {
    await _delete('/games/$id');
  }
}
