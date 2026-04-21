import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/controllers/locale_controller.dart';
import 'package:ez_trainz/screens/main_shell_screen.dart';
import 'package:ez_trainz/screens/sign_up_screen.dart';
import 'package:ez_trainz/services/auth_service.dart';
import 'package:ez_trainz/widgets/social_btn.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'login_empty_fields'.tr);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await AuthService.signIn(
        email: email,
        password: password,
      );

      final token = response['accessToken'] as String? ?? '';
      final idToken =
          response['idToken'] as String? ?? response['token'] as String?;
      final refreshToken = response['refreshToken'] as String?;
      final user = response['user'] as Map<String, dynamic>? ?? {};
      final name = user['name'] as String? ?? email.split('@').first;
      final userEmail = user['email'] as String? ?? email;
      final cognitoId =
          user['cognitoId'] as String? ?? user['sub'] as String?;

      AuthController.to.setSession(
        token: token,
        idToken: idToken,
        name: name,
        email: userEmail,
        cognitoId: cognitoId,
        refreshToken: refreshToken,
      );

      if (mounted) setState(() => _isLoading = false);
      Get.offAll(() => const MainShellScreen());
    } on AuthException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'login_generic_error'.tr;
        _isLoading = false;
      });
    }
  }

  void _onContinueGuest() {
    Get.offAll(() => const MainShellScreen());
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final topPad = mq.padding.top;
    final bottomPad = mq.padding.bottom;

    final screenH = mq.size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFB8E4F8),
      body: Stack(
        children: [
          // GIF in top ~48% of screen
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenH * 0.48,
            child: Image.asset(
              'assets/images/login_sky_bg.gif',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              gaplessPlayback: true,
            ),
          ),
          // Gradient: blends GIF bottom into the sky-blue lower area
          Positioned(
            top: screenH * 0.32,
            left: 0,
            right: 0,
            height: screenH * 0.22,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00B8E4F8),
                    Color(0xFFB8E4F8),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, topPad + 10, 24, bottomPad + 12),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerRight,
                    child: _LangPill(),
                  ),
                  const Spacer(),
                  _buildGlassCard(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard() {
    const blue = Color(0xFF00AEEF);
    const ezBlue = Color(0xFF1E88E5);
    const yellow = Color(0xFFFFE000);
    const fieldBorder = Color(0xFFB3DFFA);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withValues(alpha: 0.42),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.65),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/ez_trainz_logo_text_clean.png',
                  height: 56,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),

              const SizedBox(height: 18),

              _field(
                controller: _emailCtrl,
                hint: 'login_email_or_phone_hint'.tr,
                keyboard: TextInputType.emailAddress,
                fieldBorder: fieldBorder,
              ),

              const SizedBox(height: 12),

              _field(
                controller: _passCtrl,
                hint: 'login_password_hint'.tr,
                isPassword: true,
                fieldBorder: fieldBorder,
              ),

              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(
                      color: Color(0xFFD32F2F), fontSize: 12),
                ),
              ],

              const SizedBox(height: 18),

              Center(
                child: SizedBox(
                  width: 180,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                        side: const BorderSide(
                            color: Colors.white60, width: 1.2),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text('sign_in'.tr,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Center(
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('forgot_password'.tr,
                      style: const TextStyle(
                          color: Color(0xFFFFD600),
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  Expanded(
                      child: Divider(color: const Color(0xFF0090D4).withValues(alpha: 0.35), thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('or_sign_in_with'.tr,
                        style: const TextStyle(
                            color: Color(0xFF0090D4),
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ),
                  Expanded(
                      child: Divider(color: const Color(0xFF0090D4).withValues(alpha: 0.35), thickness: 1)),
                ],
              ),

              const SizedBox(height: 10),

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FacebookSocialBtn(),
                  SizedBox(width: 16),
                  GoogleSocialBtn(),
                ],
              ),

              const SizedBox(height: 10),

              Text('new_here'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(0xFF0090D4),
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () => Get.to(() => const SignUpScreen()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: blue,
                          side: const BorderSide(color: blue, width: 1.5),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                        child: Text('lets_sign_up'.tr,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: _onContinueGuest,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: blue,
                          side: const BorderSide(color: blue, width: 1.5),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('continue_as_guest'.tr,
                              maxLines: 1,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    TextInputType keyboard = TextInputType.text,
    required Color fieldBorder,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.white.withValues(alpha: 0.55),
        border: Border.all(color: fieldBorder, width: 1.3),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscure,
        keyboardType: keyboard,
        onChanged: (_) => setState(() => _error = null),
        style: const TextStyle(
            color: Color(0xFF1A4F8C), fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: const Color(0xFF1A4F8C).withValues(alpha: 0.4),
              fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF1A4F8C).withValues(alpha: 0.4),
                    size: 22,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _LangPill extends StatelessWidget {
  const _LangPill();

  @override
  Widget build(BuildContext context) {
    final lc = LocaleController.to;
    return Obx(() {
      final isEn = lc.isEnglish;
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _chip('EN', isEn, lc.switchToEnglish),
            Container(width: 1, height: 20, color: Colors.white38),
            _chip('বাং', !isEn, lc.switchToBanglish),
          ],
        ),
      );
    });
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF4CAF50) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(label,
            style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
      ),
    );
  }
}
