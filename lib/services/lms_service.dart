import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class LmsException implements Exception {
  final String message;
  const LmsException(this.message);
}

/// LMS Service wrapper (courses, enrollments, lesson progress).
///
/// Base URL from `jlc-endpoints.html`:
/// `https://whvvdypnx0.execute-api.us-east-1.amazonaws.com/dev`
class LmsService {
  static const _baseUrl =
      'https://whvvdypnx0.execute-api.us-east-1.amazonaws.com/dev';

  static Map<String, String> _headers(String bearerToken) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearerToken',
      };

  static String _messageFromBody(dynamic data, int status) {
    if (data is Map) {
      return data['message'] as String? ??
          data['error'] as String? ??
          'Request failed ($status).';
    }
    return 'Request failed ($status).';
  }

  static Future<dynamic> _sendJson(
    Future<http.Response> Function() fn,
  ) async {
    late http.Response response;
    try {
      response = await fn().timeout(const Duration(seconds: 25));
    } on SocketException catch (e) {
      throw LmsException('No internet connection. ($e)');
    } on HandshakeException catch (e) {
      throw LmsException('SSL error. ($e)');
    } catch (e) {
      throw LmsException('Network error: $e');
    }

    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {}

    if (response.statusCode >= 200 && response.statusCode < 300) return data;
    throw LmsException(_messageFromBody(data, response.statusCode));
  }

  // ── GET /courses ────────────────────────────────────────────────
  static Future<dynamic> fetchCourses({required String bearerToken}) async {
    final uri = Uri.parse('$_baseUrl/courses');
    return _sendJson(() => http.get(uri, headers: _headers(bearerToken)));
  }

  // ── GET /courses/my ─────────────────────────────────────────────
  static Future<dynamic> fetchMyCourses({required String bearerToken}) async {
    final uri = Uri.parse('$_baseUrl/courses/my');
    return _sendJson(() => http.get(uri, headers: _headers(bearerToken)));
  }

  // ── POST /courses/:courseId/enroll ──────────────────────────────
  static Future<dynamic> enroll({
    required String bearerToken,
    required String courseId,
  }) async {
    final uri = Uri.parse('$_baseUrl/courses/$courseId/enroll');
    return _sendJson(() => http.post(uri, headers: _headers(bearerToken)));
  }

  // ── DELETE /courses/:courseId/enroll ────────────────────────────
  static Future<void> unenroll({
    required String bearerToken,
    required String courseId,
  }) async {
    final uri = Uri.parse('$_baseUrl/courses/$courseId/enroll');
    await _sendJson(() => http.delete(uri, headers: _headers(bearerToken)));
  }

  // ── PATCH /lessons/:lessonId/progress ───────────────────────────
  static Future<dynamic> updateLessonProgress({
    required String bearerToken,
    required String lessonId,
    required bool completed,
    required double progressPct,
  }) async {
    final uri = Uri.parse('$_baseUrl/lessons/$lessonId/progress');
    return _sendJson(
      () => http.patch(
        uri,
        headers: _headers(bearerToken),
        body: jsonEncode({
          'completed': completed,
          'progressPct': progressPct,
        }),
      ),
    );
  }
}

