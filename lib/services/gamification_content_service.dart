import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class GamificationContentException implements Exception {
  final String message;
  const GamificationContentException(this.message);
}

/// Gamification service wrappers for quiz + drills.
///
/// Base URL from `jlc-endpoints.html`:
/// `https://bdmy1zi0va.execute-api.us-east-1.amazonaws.com`
///
/// These endpoints are public in the spec (no Authorization header).
/// Submissions require `cognitoId` passed in body (JWT `sub`).
class GamificationContentService {
  static const _baseUrl =
      'https://bdmy1zi0va.execute-api.us-east-1.amazonaws.com';

  static const _headers = <String, String>{'Content-Type': 'application/json'};

  static String _messageFromBody(dynamic data, int status) {
    if (data is Map) {
      return data['message'] as String? ??
          data['error'] as String? ??
          'Request failed ($status).';
    }
    return 'Request failed ($status).';
  }

  static Future<dynamic> _sendJson(Future<http.Response> Function() fn) async {
    late http.Response response;
    try {
      response = await fn().timeout(const Duration(seconds: 25));
    } on SocketException catch (e) {
      throw GamificationContentException('No internet connection. ($e)');
    } on HandshakeException catch (e) {
      throw GamificationContentException('SSL error. ($e)');
    } catch (e) {
      throw GamificationContentException('Network error: $e');
    }

    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {}

    if (response.statusCode >= 200 && response.statusCode < 300) return data;
    throw GamificationContentException(_messageFromBody(data, response.statusCode));
  }

  // ── GET /quiz ───────────────────────────────────────────────────
  static Future<dynamic> fetchAllQuizzes() async {
    final uri = Uri.parse('$_baseUrl/quiz');
    return _sendJson(() => http.get(uri, headers: _headers));
  }

  // ── GET /quiz/lesson/:lessonId ──────────────────────────────────
  static Future<dynamic> fetchQuizForLesson(String lessonId) async {
    final uri = Uri.parse('$_baseUrl/quiz/lesson/$lessonId');
    return _sendJson(() => http.get(uri, headers: _headers));
  }

  // ── POST /quiz/submit ───────────────────────────────────────────
  static Future<dynamic> submitQuiz({
    required String cognitoId,
    required String quizId,
    required List<Map<String, dynamic>> answers,
  }) async {
    final uri = Uri.parse('$_baseUrl/quiz/submit');
    return _sendJson(
      () => http.post(
        uri,
        headers: _headers,
        body: jsonEncode({
          'cognitoId': cognitoId,
          'quizId': quizId,
          'answers': answers,
        }),
      ),
    );
  }

  // ── GET /grammar/lesson/:lessonId ───────────────────────────────
  static Future<dynamic> fetchGrammarForLesson(String lessonId) async {
    final uri = Uri.parse('$_baseUrl/grammar/lesson/$lessonId');
    return _sendJson(() => http.get(uri, headers: _headers));
  }

  // ── GET /fill-gaps/lesson/:lessonId ─────────────────────────────
  static Future<dynamic> fetchFillGapsForLesson(String lessonId) async {
    final uri = Uri.parse('$_baseUrl/fill-gaps/lesson/$lessonId');
    return _sendJson(() => http.get(uri, headers: _headers));
  }

  // ── GET /matching/lesson/:lessonId ──────────────────────────────
  static Future<dynamic> fetchMatchingForLesson(String lessonId) async {
    final uri = Uri.parse('$_baseUrl/matching/lesson/$lessonId');
    return _sendJson(() => http.get(uri, headers: _headers));
  }
}

