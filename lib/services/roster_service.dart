import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class RosterException implements Exception {
  final String message;
  const RosterException(this.message);
}

/// Roster & Meetings service wrapper.
///
/// Base URL from `jlc-endpoints.html`:
/// `https://u6vokpvxmf.execute-api.us-east-1.amazonaws.com`
///
/// All endpoints require Authorization: Bearer <JWT>.
class RosterService {
  static const _baseUrl =
      'https://u6vokpvxmf.execute-api.us-east-1.amazonaws.com';

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
      throw RosterException('No internet connection. ($e)');
    } on HandshakeException catch (e) {
      throw RosterException('SSL error. ($e)');
    } catch (e) {
      throw RosterException('Network error: $e');
    }

    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {}

    if (response.statusCode >= 200 && response.statusCode < 300) return data;
    throw RosterException(_messageFromBody(data, response.statusCode));
  }

  // ── Rosters ─────────────────────────────────────────────────────

  static Future<dynamic> listRosters({
    required String bearerToken,
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('$_baseUrl/roster').replace(queryParameters: query);
    return _sendJson(() => http.get(uri, headers: _headers(bearerToken)));
  }

  static Future<dynamic> createRoster({
    required String bearerToken,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri.parse('$_baseUrl/roster');
    return _sendJson(() => http.post(
          uri,
          headers: _headers(bearerToken),
          body: jsonEncode(payload),
        ));
  }

  static Future<dynamic> getRoster({
    required String bearerToken,
    required String id,
  }) async {
    final uri = Uri.parse('$_baseUrl/roster/$id');
    return _sendJson(() => http.get(uri, headers: _headers(bearerToken)));
  }

  static Future<void> deleteRoster({
    required String bearerToken,
    required String id,
  }) async {
    final uri = Uri.parse('$_baseUrl/roster/$id');
    await _sendJson(() => http.delete(uri, headers: _headers(bearerToken)));
  }

  // ── Instructor roster / meetings ────────────────────────────────

  static Future<dynamic> listInstructorRoster({
    required String bearerToken,
  }) async {
    final uri = Uri.parse('$_baseUrl/instructor-roster');
    return _sendJson(() => http.get(uri, headers: _headers(bearerToken)));
  }

  static Future<dynamic> listMyInstructorSlots({
    required String bearerToken,
  }) async {
    final uri = Uri.parse('$_baseUrl/instructor-roster/mine');
    return _sendJson(() => http.get(uri, headers: _headers(bearerToken)));
  }

  static Future<dynamic> listMeetingsForPost({
    required String bearerToken,
    required String postId,
  }) async {
    final uri = Uri.parse('$_baseUrl/instructor-roster/post/$postId');
    return _sendJson(() => http.get(uri, headers: _headers(bearerToken)));
  }

  static Future<dynamic> createMeetingSlot({
    required String bearerToken,
    required String postId,
    required String date,
    required String timeSlot,
  }) async {
    final uri = Uri.parse('$_baseUrl/instructor-roster');
    return _sendJson(() => http.post(
          uri,
          headers: _headers(bearerToken),
          body: jsonEncode({'postId': postId, 'date': date, 'timeSlot': timeSlot}),
        ));
  }

  static Future<dynamic> joinMeetingSlot({
    required String bearerToken,
    required String id,
  }) async {
    final uri = Uri.parse('$_baseUrl/instructor-roster/$id/join');
    return _sendJson(() => http.post(uri, headers: _headers(bearerToken)));
  }

  static Future<dynamic> leaveMeetingSlot({
    required String bearerToken,
    required String id,
  }) async {
    final uri = Uri.parse('$_baseUrl/instructor-roster/$id/leave');
    return _sendJson(() => http.post(uri, headers: _headers(bearerToken)));
  }

  static Future<void> deleteMeetingSlot({
    required String bearerToken,
    required String id,
  }) async {
    final uri = Uri.parse('$_baseUrl/instructor-roster/$id');
    await _sendJson(() => http.delete(uri, headers: _headers(bearerToken)));
  }
}

