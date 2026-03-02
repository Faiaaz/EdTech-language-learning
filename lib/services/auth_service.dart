import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class AuthService {
  static const _baseUrl =
      'https://arlvajyrck.execute-api.us-east-1.amazonaws.com/dev';

  static String _normalisePhone(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[\s\-()]'), '');
    if (cleaned.startsWith('+88')) return cleaned;
    if (cleaned.startsWith('88') && cleaned.length == 13) return '+$cleaned';
    return '+88$cleaned';
  }

  // ── Shared request helper ──────────────────────────────────────
  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> payload, {
    String? accessToken,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');

    // ignore: avoid_print
    print('[AuthService] POST $uri');
    // ignore: avoid_print
    print('[AuthService] Payload: $payload');

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    late http.Response response;
    try {
      response = await http
          .post(uri, headers: headers, body: jsonEncode(payload))
          .timeout(const Duration(seconds: 20));
    } on SocketException catch (e) {
      throw AuthException('No internet connection. ($e)');
    } on HandshakeException catch (e) {
      throw AuthException('SSL error. ($e)');
    } catch (e) {
      throw AuthException('Network error: $e');
    }

    // ignore: avoid_print
    print('[AuthService] Status: ${response.statusCode}');
    // ignore: avoid_print
    print('[AuthService] Body: ${response.body}');

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
    throw AuthException(apiMsg);
  }

  // ── Sign Up ────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    return _post('/auth/signup', {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      'phoneNumber': _normalisePhone(phoneNumber.trim()),
    });
  }

  // ── Verify OTP ─────────────────────────────────────────────────
  // TODO: update path + payload keys once backend dev confirms endpoint
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    return _post('/auth/confirm', {
      'email': email.trim().toLowerCase(),
      'code': otp.trim(),
    });
  }

  // ── Resend OTP ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>> resendOtp({
    required String email,
  }) async {
    return _post('/auth/resend-otp', {
      'email': email.trim().toLowerCase(),
    });
  }

  // ── Sign In ────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    return _post('/auth/signin', {
      'email': email.trim().toLowerCase(),
      'password': password,
    });
  }
}
