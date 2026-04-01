import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:ez_trainz/models/forum_comment.dart';
import 'package:ez_trainz/models/forum_post.dart';

class ForumException implements Exception {
  final String message;
  const ForumException(this.message);
}

/// Forum API — base URL from API Gateway.
class ForumService {
  static const _baseUrl =
      'https://u6vokpvxmf.execute-api.us-east-1.amazonaws.com';

  static Map<String, String> _headers(String? bearerToken) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (bearerToken != null && bearerToken.isNotEmpty) {
      h['Authorization'] = 'Bearer $bearerToken';
    }
    return h;
  }

  static void _logJwtSummary(String? bearerToken) {
    if (bearerToken == null || bearerToken.isEmpty) return;
    final parts = bearerToken.split('.');
    if (parts.length < 2) {
      // ignore: avoid_print
      print('[ForumService] Auth token is not a JWT (no dots).');
      return;
    }
    try {
      final payloadSeg = parts[1];
      final normalized = base64Url.normalize(payloadSeg);
      final jsonStr = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(jsonStr);
      if (payload is Map) {
        final tokenUse = payload['token_use'];
        final sub = payload['sub'];
        final iss = payload['iss'];
        final aud = payload['aud'] ?? payload['client_id'];
        // ignore: avoid_print
        print('[ForumService] JWT token_use=$tokenUse sub=$sub aud=$aud iss=$iss');
      }
    } catch (e) {
      // ignore: avoid_print
      print('[ForumService] Failed to decode JWT payload: $e');
    }
  }

  static String _messageFromBody(dynamic data, int status) {
    if (data is Map) {
      return data['message'] as String? ??
          data['error'] as String? ??
          'Request failed ($status).';
    }
    return 'Request failed ($status).';
  }

  static String _truncate(String s, {int max = 500}) {
    if (s.length <= max) return s;
    return '${s.substring(0, max)}…';
  }

  static Future<dynamic> _get(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    late http.Response response;
    try {
      response = await http
          .get(uri, headers: _headers(null))
          .timeout(const Duration(seconds: 25));
    } on SocketException catch (e) {
      throw ForumException('No internet connection. ($e)');
    } on HandshakeException catch (e) {
      throw ForumException('SSL error. ($e)');
    } catch (e) {
      throw ForumException('Network error: $e');
    }

    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {}

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    throw ForumException(_messageFromBody(data, response.statusCode));
  }

  static Future<Map<String, dynamic>> _parseJsonResponse(
    http.Response response,
  ) async {
    Map<String, dynamic> map = {};
    dynamic data;
    try {
      data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) map = data;
    } catch (_) {}

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }

    // Try to surface meaningful backend errors even when body isn't JSON.
    final baseMsg = _messageFromBody(data, response.statusCode);
    final raw = response.body.trim();
    final withBody = raw.isEmpty ? baseMsg : '$baseMsg\n\n${_truncate(raw)}';
    throw ForumException(withBody);
  }

  static Future<http.Response> _send(
    Future<http.Response> Function() fn,
  ) async {
    try {
      return await fn().timeout(const Duration(seconds: 25));
    } on SocketException catch (e) {
      throw ForumException('No internet connection. ($e)');
    } on HandshakeException catch (e) {
      throw ForumException('SSL error. ($e)');
    } catch (e) {
      throw ForumException('Network error: $e');
    }
  }

  static List<ForumPost> _parsePostList(dynamic data) {
    if (data is List) {
      return data
          .map((e) => ForumPost.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map && data['items'] is List) {
      return (data['items'] as List)
          .map((e) => ForumPost.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // ── Posts ───────────────────────────────────────────────────────

  static Future<List<ForumPost>> fetchThreads() async {
    final data = await _get('/forum/posts/threads');
    return _parsePostList(data);
  }

  static Future<List<ForumPost>> fetchAllPosts() async {
    final data = await _get('/forum/posts');
    return _parsePostList(data);
  }

  static Future<ForumPost> fetchPost(String id) async {
    final data = await _get('/forum/posts/$id');
    if (data is Map<String, dynamic>) {
      return ForumPost.fromJson(data);
    }
    throw const ForumException('Invalid post response.');
  }

  static Future<ForumPost> createPost({
    required String bearerToken,
    required String title,
    required String content,
  }) async {
    final uri = Uri.parse('$_baseUrl/forum/posts');
    _logJwtSummary(bearerToken);
    final response = await _send(() => http.post(
          uri,
          headers: _headers(bearerToken),
          body: jsonEncode({'title': title, 'content': content}),
        ));
    // ignore: avoid_print
    print('[ForumService] POST $uri → ${response.statusCode}');
    // ignore: avoid_print
    print('[ForumService] Body: ${_truncate(response.body)}');
    final map = await _parseJsonResponse(response);
    return ForumPost.fromJson(map);
  }

  static Future<ForumPost> updatePost({
    required String bearerToken,
    required String id,
    String? title,
    String? content,
  }) async {
    final uri = Uri.parse('$_baseUrl/forum/posts/$id');
    _logJwtSummary(bearerToken);
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (content != null) body['content'] = content;
    final response = await _send(() => http.patch(
          uri,
          headers: _headers(bearerToken),
          body: jsonEncode(body),
        ));
    // ignore: avoid_print
    print('[ForumService] PATCH $uri → ${response.statusCode}');
    // ignore: avoid_print
    print('[ForumService] Body: ${_truncate(response.body)}');
    final map = await _parseJsonResponse(response);
    return ForumPost.fromJson(map);
  }

  static Future<void> deletePost({
    required String bearerToken,
    required String id,
  }) async {
    final uri = Uri.parse('$_baseUrl/forum/posts/$id');
    _logJwtSummary(bearerToken);
    final response = await _send(() => http.delete(
          uri,
          headers: _headers(bearerToken),
        ));
    // ignore: avoid_print
    print('[ForumService] DELETE $uri → ${response.statusCode}');
    // ignore: avoid_print
    print('[ForumService] Body: ${_truncate(response.body)}');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {}
      throw ForumException(_messageFromBody(data, response.statusCode));
    }
  }

  // ── Comments ────────────────────────────────────────────────────

  static Future<List<ForumComment>> fetchComments(String postId) async {
    final data = await _get('/forum/posts/$postId/comments');
    if (data is List) {
      return data
          .map((e) => ForumComment.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static Future<ForumComment> addComment({
    required String bearerToken,
    required String postId,
    required String content,
    String? authorId,
    String? authorName,
    String? parentCommentId,
  }) async {
    final uri = Uri.parse('$_baseUrl/forum/posts/$postId/comments');
    _logJwtSummary(bearerToken);
    final payload = <String, dynamic>{
      'body': content,
      if (authorId != null && authorId.isNotEmpty) 'authorId': authorId,
      if (authorName != null && authorName.isNotEmpty) 'authorName': authorName,
      if (parentCommentId != null && parentCommentId.isNotEmpty)
        'parentCommentId': parentCommentId,
    };
    final response = await _send(() => http.post(
          uri,
          headers: _headers(bearerToken),
          body: jsonEncode(payload),
        ));
    // ignore: avoid_print
    print('[ForumService] POST $uri → ${response.statusCode}');
    // ignore: avoid_print
    print('[ForumService] Body: ${_truncate(response.body)}');
    final map = await _parseJsonResponse(response);
    return ForumComment.fromJson(map);
  }

  static Future<ForumComment> updateComment({
    required String bearerToken,
    required String id,
    required String content,
  }) async {
    final uri = Uri.parse('$_baseUrl/forum/comments/$id');
    _logJwtSummary(bearerToken);
    final response = await _send(() => http.patch(
          uri,
          headers: _headers(bearerToken),
          body: jsonEncode({'body': content}),
        ));
    // ignore: avoid_print
    print('[ForumService] PATCH $uri → ${response.statusCode}');
    // ignore: avoid_print
    print('[ForumService] Body: ${_truncate(response.body)}');
    final map = await _parseJsonResponse(response);
    return ForumComment.fromJson(map);
  }

  static Future<void> deleteComment({
    required String bearerToken,
    required String id,
  }) async {
    final uri = Uri.parse('$_baseUrl/forum/comments/$id');
    _logJwtSummary(bearerToken);
    final response = await _send(() => http.delete(
          uri,
          headers: _headers(bearerToken),
        ));
    // ignore: avoid_print
    print('[ForumService] DELETE $uri → ${response.statusCode}');
    // ignore: avoid_print
    print('[ForumService] Body: ${_truncate(response.body)}');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {}
      throw ForumException(_messageFromBody(data, response.statusCode));
    }
  }
}
