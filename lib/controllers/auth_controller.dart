import 'package:get/get.dart';

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
  bool   get isLoggedIn  => _accessToken.value.isNotEmpty;
  String get forumBearerToken => _idToken.value.isNotEmpty ? _idToken.value : _accessToken.value;

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
  }) {
    _accessToken.value = token;
    _idToken.value     = idToken ?? _idToken.value;
    _userName.value    = name;
    _userEmail.value   = email;
    _userBio.value     = bio;
    _cognitoId.value   = cognitoId;
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
  }
}
