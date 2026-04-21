import 'package:get/get.dart';
import 'dart:convert';

import 'package:ez_trainz/services/secure_storage_service.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  // ── Temp signup data (held in memory during OTP flow) ─────────
  String signUpName  = '';
  String signUpEmail = '';
  String signUpPhone = '';

  // ── Logged-in user info ────────────────────────────────────────
  final _accessToken = ''.obs;
  final _idToken     = ''.obs;
  final _userName    = ''.obs;
  final _userEmail   = Rxn<String>();
  final _userBio     = Rxn<String>();
  final _cognitoId   = Rxn<String>();

  String get accessToken => _accessToken.value;
  String get idToken     => _idToken.value;
  String get userName    => _userName.value;
  String? get userEmail  => _userEmail.value;
  String? get userBio    => _userBio.value;
  String? get cognitoId  => _cognitoId.value;
  String get firstName   => _userName.value.split(' ').first;
  bool   get isLoggedIn  => _isValidJwtAccessToken(_accessToken.value);
  String get forumBearerToken => _idToken.value.isNotEmpty ? _idToken.value : _accessToken.value;

  /// Restore persisted session (mobile/desktop).
  Future<void> restoreSession() async {
    final data = await SecureStorageService.readAll();
    final token = data[SecureStorageService.kAccessToken] ?? '';
    if (token.isEmpty) return;

    // Only auto-restore sessions for JWT access tokens that are not expired.
    // This prevents stale/dev tokens from immediately bypassing the login screen.
    if (!_isValidJwtAccessToken(token)) {
      await SecureStorageService.clear();
      return;
    }

    _accessToken.value = token;
    _idToken.value = data[SecureStorageService.kIdToken] ?? '';
    _userName.value = data[SecureStorageService.kUserName] ?? _userName.value;
    _userEmail.value = data[SecureStorageService.kUserEmail];
    _cognitoId.value = data[SecureStorageService.kCognitoId];
  }

  void cacheSignUpData({
    required String name,
    required String email,
    required String phone,
  }) {
    signUpName  = name;
    signUpEmail = email;
    signUpPhone = phone;
  }

  void setSession({
    required String token,
    String? idToken,
    required String name,
    String? email,
    String? bio,
    String? cognitoId,
    String? refreshToken,
  }) {
    _accessToken.value = token;
    _idToken.value     = idToken ?? _idToken.value;
    _userName.value    = name;
    _userEmail.value   = email;
    _userBio.value     = bio;
    _cognitoId.value   = cognitoId;

    // Fire-and-forget persistence (not supported on web by design).
    // ignore: discarded_futures
    SecureStorageService.writeAll(
      accessToken: token,
      idToken: idToken,
      refreshToken: refreshToken,
      userName: name,
      userEmail: email,
      cognitoId: cognitoId,
    );
  }

  void logout() {
    _accessToken.value = '';
    _idToken.value     = '';
    _userName.value    = '';
    _userEmail.value   = null;
    _userBio.value     = null;
    _cognitoId.value   = null;
    signUpName  = '';
    signUpEmail = '';
    signUpPhone = '';

    // ignore: discarded_futures
    SecureStorageService.clear();
  }

  static bool _isValidJwtAccessToken(String token) {
    if (token.isEmpty) return false;
    final parts = token.split('.');
    if (parts.length != 3) return false;

    final payload = _decodeJwtPayload(parts[1]);
    if (payload == null) return false;

    final exp = payload['exp'];
    if (exp is! num) return false;

    final expMs = (exp * 1000).round();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    return nowMs < expMs;
  }

  static Map<String, dynamic>? _decodeJwtPayload(String b64UrlPayload) {
    try {
      final normalized = base64Url.normalize(b64UrlPayload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final jsonVal = json.decode(decoded);
      return jsonVal is Map<String, dynamic> ? jsonVal : null;
    } catch (_) {
      return null;
    }
  }
}
