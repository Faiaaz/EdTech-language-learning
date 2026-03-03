import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  // ── Temp signup data (held in memory during OTP flow) ─────────
  String signUpName  = '';
  String signUpEmail = '';
  String signUpPhone = '';

  // ── Logged-in user info ────────────────────────────────────────
  final _accessToken = ''.obs;
  final _userName    = ''.obs;
  final _userEmail   = Rxn<String>();
  final _userBio     = Rxn<String>();

  String get accessToken => _accessToken.value;
  String get userName    => _userName.value;
  String? get userEmail  => _userEmail.value;
  String? get userBio    => _userBio.value;
  String get firstName   => _userName.value.split(' ').first;
  bool   get isLoggedIn  => _accessToken.value.isNotEmpty;

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
    required String name,
    String? email,
    String? bio,
  }) {
    _accessToken.value = token;
    _userName.value    = name;
    _userEmail.value   = email;
    _userBio.value     = bio;
  }

  void logout() {
    _accessToken.value = '';
    _userName.value    = '';
    _userEmail.value   = null;
    _userBio.value     = null;
    signUpName  = '';
    signUpEmail = '';
    signUpPhone = '';
  }
}
