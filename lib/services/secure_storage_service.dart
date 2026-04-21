import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure persistence for auth session values.
///
/// Note: `flutter_secure_storage` uses platform keystores on mobile/desktop.
/// On web it falls back to less-secure storage, so we no-op there by default.
class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static const kAccessToken = 'auth_access_token';
  static const kIdToken = 'auth_id_token';
  static const kRefreshToken = 'auth_refresh_token';
  static const kUserName = 'auth_user_name';
  static const kUserEmail = 'auth_user_email';
  static const kCognitoId = 'auth_cognito_id';

  static Future<void> writeAll({
    required String accessToken,
    String? idToken,
    String? refreshToken,
    String? userName,
    String? userEmail,
    String? cognitoId,
  }) async {
    if (kIsWeb) return;
    await Future.wait([
      _storage.write(key: kAccessToken, value: accessToken),
      if (idToken != null) _storage.write(key: kIdToken, value: idToken),
      if (refreshToken != null)
        _storage.write(key: kRefreshToken, value: refreshToken),
      if (userName != null) _storage.write(key: kUserName, value: userName),
      if (userEmail != null) _storage.write(key: kUserEmail, value: userEmail),
      if (cognitoId != null) _storage.write(key: kCognitoId, value: cognitoId),
    ]);
  }

  static Future<Map<String, String?>> readAll() async {
    if (kIsWeb) return const {};
    final values = await Future.wait([
      _storage.read(key: kAccessToken),
      _storage.read(key: kIdToken),
      _storage.read(key: kRefreshToken),
      _storage.read(key: kUserName),
      _storage.read(key: kUserEmail),
      _storage.read(key: kCognitoId),
    ]);
    return {
      kAccessToken: values[0],
      kIdToken: values[1],
      kRefreshToken: values[2],
      kUserName: values[3],
      kUserEmail: values[4],
      kCognitoId: values[5],
    };
  }

  static Future<void> clear() async {
    if (kIsWeb) return;
    await Future.wait([
      _storage.delete(key: kAccessToken),
      _storage.delete(key: kIdToken),
      _storage.delete(key: kRefreshToken),
      _storage.delete(key: kUserName),
      _storage.delete(key: kUserEmail),
      _storage.delete(key: kCognitoId),
    ]);
  }
}

