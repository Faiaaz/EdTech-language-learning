import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:ez_trainz/models/forum_comment.dart';
import 'package:ez_trainz/models/forum_post.dart';

class ForumException implements Exception {
  final String message;
  const ForumException(this.message);
}

/// Forum API — base `https://u6vokpvxmf.execute-api.us-east-1.amazonaws.com`
class ForumService {
  static const _baseUrl =
      'https://u6vokpvxmf.execute-api.us-east-1.amazonaws.com';

  static Map<String, String> _headers({String? accessToken}) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (accessToken != null && accessToken.isNotEmpty) {
      h['Authorization'] = 'Bearer $accessToken';
    }
    return h;
  }

  static String _apiMsg(dynamic data, int status) {
    if (data is Map) {
      return (data['message'] as String?) ??
          (data['error'] as String?) ??
          'Request failed ($status).';
    }
    return 'Request failed ($status).';
  }

  static List<Map<String, dynamic>> _asObjectList(dynamic data) {
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (data is Map<String, dynamic>) {
      for (final key in ['posts', 'items', 'data', 'results', 'threads']) {
        final inner = data[key];
        if (inner is List) {
          return inner
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    }
    return [];
  }

  // ── GET ─────────────────────────────────────────────────────────
  static Future<dynamic> _get(String path, {String? accessToken}) async {
    final uri = Uri.parse('$_baseUrl$path');
    // ignore: avoid_print
    print('[ForumService] GET $uri');

    late http.Response response;
    try {
      response = await http
          .get(uri, headers: _headers(accessToken: accessToken))
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
      data = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {}

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    throw ForumException(_apiMsg(data, response.statusCode));
  }

  // ── POST ────────────────────────────────────────────────────────
  static Future<dynamic> _post(
    String path,
    Map<String, dynamic> body, {
    String? accessToken,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    // ignore: avoid_print
    print('[ForumService] POST $uri');

    late http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: _headers(accessToken: accessToken),
            body: jsonEncode(body),
          )
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
      data = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {}

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    throw ForumException(_apiMsg(data, response.statusCode));
  }

  // ── PATCH ───────────────────────────────────────────────────────
  static Future<dynamic> _patch(
    String path,
    Map<String, dynamic> body, {
    String? accessToken,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    // ignore: avoid_print
    print('[ForumService] PATCH $uri');

    late http.Response response;
    try {
      response = await http
          .patch(
            uri,
            headers: _headers(accessToken: accessToken),
            body: jsonEncode(body),
          )
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
      data = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {}

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    throw ForumException(_apiMsg(data, response.statusCode));
  }

  // ── DELETE ─────────────────────────────────────────────────────
  static Future<void> _delete(String path, {String? accessToken}) async {
    final uri = Uri.parse('$_baseUrl$path');
    // ignore: avoid_print
    print('[ForumService] DELETE $uri');

    late http.Response response;
    try {
      response = await http
          .delete(uri, headers: _headers(accessToken: accessToken))
          .timeout(const Duration(seconds: 25));
    } on SocketException catch (e) {
      throw ForumException('No internet connection. ($e)');
    } on HandshakeException catch (e) {
      throw ForumException('SSL error. ($e)');
    } catch (e) {
      throw ForumException('Network error: $e');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {}
    throw ForumException(_apiMsg(data, response.statusCode));
  }

  // ── Posts ───────────────────────────────────────────────────────
  static Future<List<ForumPost>> getAllPosts({String? accessToken}) async {
    final data = await _get('/forum/posts', accessToken: accessToken);
    return _asObjectList(data).map(ForumPost.fromJson).toList();
  }

  static Future<List<ForumPost>> getThreads({String? accessToken}) async {
    final data = await _get('/forum/posts/threads', accessToken: accessToken);
    return _asObjectList(data).map(ForumPost.fromJson).toList();
  }

  static Future<ForumPost> getPost(String id, {String? accessToken}) async {
    final data = await _get('/forum/posts/$id', accessToken: accessToken);
    if (data is Map<String, dynamic>) {
      return ForumPost.fromJson(data);
    }
    throw const ForumException('Invalid post response.');
  }

  static Future<ForumPost> createPost({
    required String title,
    required String content,
    required String authorName,
    String? authorId,
    String? accessToken,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'content': content,
      'authorName': authorName,
      if (authorId != null && authorId.isNotEmpty) 'authorId': authorId,
      if (authorId != null && authorId.isNotEmpty) 'cognitoId': authorId,
    };
    final data = await _post('/forum/posts', body, accessToken: accessToken);
    if (data is Map<String, dynamic>) {
      return ForumPost.fromJson(data);
    }
    throw const ForumException('Invalid create post response.');
  }

  static Future<ForumPost> updatePost(
    String id,
    Map<String, dynamic> fields, {
    String? accessToken,
  }) async {
    final data =
        await _patch('/forum/posts/$id', fields, accessToken: accessToken);
    if (data is Map<String, dynamic>) {
      return ForumPost.fromJson(data);
    }
    throw const ForumException('Invalid update post response.');
  }

  static Future<void> deletePost(String id, {String? accessToken}) async {
    await _delete('/forum/posts/$id', accessToken: accessToken);
  }

  // ── Comments ────────────────────────────────────────────────────
  static Future<List<ForumComment>> getComments(
    String postId, {
    String? accessToken,
  }) async {
    final data =
        await _get('/forum/posts/$postId/comments', accessToken: accessToken);
    final rows = _asObjectList(data);
    return rows.map((m) {
      final c = ForumComment.fromJson(m);
      if (c.postId.isEmpty) {
        return ForumComment(
          id: c.id,
          postId: postId,
          content: c.content,
          authorName: c.authorName,
          authorId: c.authorId,
          createdAt: c.createdAt,
          updatedAt: c.updatedAt,
        );
      }
      return c;
    }).toList();
  }

  static Future<ForumComment> addComment({
    required String postId,
    required String content,
    required String authorName,
    String? authorId,
    String? accessToken,
  }) async {
    final body = <String, dynamic>{
      'content': content,
      'authorName': authorName,
      if (authorId != null && authorId.isNotEmpty) 'authorId': authorId,
      if (authorId != null && authorId.isNotEmpty) 'cognitoId': authorId,
    };
    final data = await _post(
      '/forum/posts/$postId/comments',
      body,
      accessToken: accessToken,
    );
    if (data is Map<String, dynamic>) {
      final c = ForumComment.fromJson(data);
      if (c.postId.isEmpty) {
        return ForumComment(
          id: c.id,
          postId: postId,
          content: c.content,
          authorName: c.authorName,
          authorId: c.authorId,
          createdAt: c.createdAt,
          updatedAt: c.updatedAt,
        );
      }
      return c;
    }
    throw const ForumException('Invalid comment response.');
  }

  static Future<ForumComment> updateComment(
    String commentId,
    Map<String, dynamic> fields, {
    String? accessToken,
  }) async {
    final data = await _patch(
      '/forum/comments/$commentId',
      fields,
      accessToken: accessToken,
    );
    if (data is Map<String, dynamic>) {
      return ForumComment.fromJson(data);
    }
    throw const ForumException('Invalid update comment response.');
  }

  static Future<void> deleteComment(
    String commentId, {
    String? accessToken,
  }) async {
    await _delete('/forum/comments/$commentId', accessToken: accessToken);
  }
}
