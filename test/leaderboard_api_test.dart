import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

/// Live integration tests for the Leaderboard REST API.
///
/// Run with: flutter test test/leaderboard_api_test.dart
///
/// Current API status (as of 2026-03-15):
///   ✅ GET /leaderboard/global         → 200
///   ✅ GET /leaderboard/game/:gameId   → 200
///   ✅ GET /leaderboard/me/:cognitoId  → 200 (note: rank/score nested under "global" key)
///   ❌ GET /leaderboard/stream/global        → 500 Internal Server Error
///   ❌ GET /leaderboard/stream/game/:gameId  → 500 Internal Server Error
void main() {
  const baseUrl = 'https://bdmy1zi0va.execute-api.us-east-1.amazonaws.com';
  const headers = {'Content-Type': 'application/json'};

  group('Leaderboard API', () {
    // ── GET /leaderboard/global ─────────────────────────────────────────────
    test('GET /leaderboard/global returns 200 with a list of ranked entries',
        () async {
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard/global'),
        headers: headers,
      );

      expect(response.statusCode, 200,
          reason: 'Global leaderboard should return 200 OK');

      final data = jsonDecode(response.body);
      expect(data, isA<List>(), reason: 'Response body should be a JSON array');

      if ((data as List).isNotEmpty) {
        final entry = data.first as Map<String, dynamic>;
        expect(entry.containsKey('cognitoId'), isTrue,
            reason: 'Entry should have cognitoId');
        expect(entry.containsKey('username'), isTrue,
            reason: 'Entry should have username');
        expect(entry.containsKey('totalScore'), isTrue,
            reason: 'Entry should have totalScore');
        expect(entry.containsKey('rank'), isTrue,
            reason: 'Entry should have rank');
        expect(entry['rank'], isA<int>(),
            reason: 'rank should be an integer');
        expect(entry['totalScore'], isA<int>(),
            reason: 'totalScore should be an integer');
      }
    });

    // ── GET /leaderboard/game/:gameId ───────────────────────────────────────
    test('GET /leaderboard/game/:gameId returns 200 with a list', () async {
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard/game/game1'),
        headers: headers,
      );

      expect(response.statusCode, 200,
          reason: 'Game leaderboard should return 200 OK');

      final data = jsonDecode(response.body);
      expect(data, isA<List>(),
          reason: 'Response body should be a JSON array (may be empty)');
    });

    // ── GET /leaderboard/me/:cognitoId ──────────────────────────────────────
    test(
        'GET /leaderboard/me/:cognitoId returns 200 with user rank (rank nested under "global")',
        () async {
      const testCognitoId = 'user123';
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard/me/$testCognitoId'),
        headers: headers,
      );

      expect(response.statusCode, 200,
          reason: 'My-rank endpoint should return 200 OK');

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      expect(data['cognitoId'], equals(testCognitoId),
          reason: 'Response should echo back the cognitoId');
      expect(data.containsKey('username'), isTrue,
          reason: 'Response should include username');

      // NOTE: rank and totalScore are nested under the "global" key, NOT at the
      // top level. LeaderboardService.fetchMyRank() must handle this structure.
      expect(data.containsKey('global'), isTrue,
          reason: 'Response should have a "global" object with rank/score');
      final globalStats = data['global'] as Map<String, dynamic>;
      expect(globalStats.containsKey('rank'), isTrue,
          reason: '"global" should contain rank');
      expect(globalStats.containsKey('totalScore'), isTrue,
          reason: '"global" should contain totalScore');
    });

    // ── GET /leaderboard/stream/global ─────────────────────────────────────
    test('GET /leaderboard/stream/global returns 200 with a list', () async {
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard/stream/global'),
        headers: headers,
      );

      // ❌ Currently returns 500 - backend issue needs to be fixed.
      expect(response.statusCode, 200,
          reason:
              'Stream global endpoint should return 200 OK. '
              'Currently returning ${response.statusCode}: ${response.body}');

      final data = jsonDecode(response.body);
      expect(data, isA<List>());
    });

    // ── GET /leaderboard/stream/game/:gameId ────────────────────────────────
    test('GET /leaderboard/stream/game/:gameId returns 200 with a list',
        () async {
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard/stream/game/game1'),
        headers: headers,
      );

      // ❌ Currently returns 500 - backend issue needs to be fixed.
      expect(response.statusCode, 200,
          reason:
              'Stream game endpoint should return 200 OK. '
              'Currently returning ${response.statusCode}: ${response.body}');

      final data = jsonDecode(response.body);
      expect(data, isA<List>());
    });
  });
}
