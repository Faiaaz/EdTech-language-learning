import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:ez_trainz/models/leaderboard_entry.dart';

class LeaderboardException implements Exception {
  final String message;
  const LeaderboardException(this.message);
}

class LeaderboardService {
  static const _baseUrl =
      'https://bdmy1zi0va.execute-api.us-east-1.amazonaws.com';

  // ── Shared GET helper ────────────────────────────────────────────
  static Future<dynamic> _get(String path) async {
    final uri = Uri.parse('$_baseUrl$path');

    // ignore: avoid_print
    print('[LeaderboardService] GET $uri');

    final headers = <String, String>{'Content-Type': 'application/json'};

    late http.Response response;
    try {
      response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));
    } on SocketException catch (e) {
      throw LeaderboardException('No internet connection. ($e)');
    } on HandshakeException catch (e) {
      throw LeaderboardException('SSL error. ($e)');
    } catch (e) {
      throw LeaderboardException('Network error: $e');
    }

    // ignore: avoid_print
    print('[LeaderboardService] Status: ${response.statusCode}');

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
    throw LeaderboardException(apiMsg);
  }

  static List<LeaderboardEntry> _parseEntries(dynamic data) {
    if (data is List) {
      return data
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // ── GET /leaderboard/global ─────────────────────────────────────
  static Future<List<LeaderboardEntry>> fetchGlobal() async {
    final data = await _get('/leaderboard/global');
    return _parseEntries(data);
  }

  // ── GET /leaderboard/game/:gameId ───────────────────────────────
  static Future<List<LeaderboardEntry>> fetchByGame(String gameId) async {
    final data = await _get('/leaderboard/game/$gameId');
    return _parseEntries(data);
  }

  // ── GET /leaderboard/me/:cognitoId ──────────────────────────────
  // Response shape: { cognitoId, username, global: { rank, totalScore }, games }
  static Future<LeaderboardEntry?> fetchMyRank(String cognitoId) async {
    final data = await _get('/leaderboard/me/$cognitoId');
    if (data is Map<String, dynamic>) {
      final global = data['global'];
      final flat = <String, dynamic>{
        'cognitoId': data['cognitoId'],
        'username': data['username'] ?? data['userName'],
        'rank': global is Map ? global['rank'] : data['rank'],
        'totalScore': global is Map ? global['totalScore'] : data['totalScore'],
        'gamesPlayed': data['gamesPlayed'] ?? 0,
      };
      return LeaderboardEntry.fromJson(flat);
    }
    return null;
  }

  // ── GET /leaderboard/stream/global ──────────────────────────────
  static Future<List<LeaderboardEntry>> fetchStreamGlobal() async {
    final data = await _get('/leaderboard/stream/global');
    return _parseEntries(data);
  }

  // ── GET /leaderboard/stream/game/:gameId ────────────────────────
  static Future<List<LeaderboardEntry>> fetchStreamByGame(
      String gameId) async {
    final data = await _get('/leaderboard/stream/game/$gameId');
    return _parseEntries(data);
  }
}
