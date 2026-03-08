import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/screens/main_shell_screen.dart';
import 'package:ez_trainz/screens/sign_up_screen.dart';
import 'package:ez_trainz/services/auth_service.dart';
import 'package:ez_trainz/widgets/animated_character.dart';
import 'package:ez_trainz/widgets/language_switcher.dart';
import 'package:ez_trainz/widgets/social_btn.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;
  bool _isLoading  = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    final email    = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'login_empty_fields'.tr);
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      final response = await AuthService.signIn(
        email: email,
        password: password,
      );

      final token = response['accessToken'] as String? ?? '';
      final user  = response['user'] as Map<String, dynamic>? ?? {};
      final name  = user['name'] as String? ?? email.split('@').first;
      final userEmail = user['email'] as String? ?? email;

      AuthController.to.setSession(
        token: token,
        name: name,
        email: userEmail,
      );

      if (mounted) setState(() => _isLoading = false);
      Get.offAll(() => const MainShellScreen());
    } on AuthException catch (e) {
      setState(() { _error = e.message; _isLoading = false; });
    } catch (e) {
      setState(() { _error = 'login_generic_error'.tr; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4DA6E8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 14),

                // ── Language switcher (EN / Banglish) ───────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: const LanguageSwitcher(),
                ),
                const SizedBox(height: 8),

                // ── HEADER ─────────────────────────────────────────
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('EZ',
                        style: TextStyle(
                          color: Color(0xFFFFE000),
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          height: 1,
                        )),
                    SizedBox(width: 4),
                    Text('TRAINZ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          height: 1,
                        )),
                  ],
                ),

                const SizedBox(height: 10),

                const SizedBox(
                  width: double.infinity,
                  height: 210,
                  child: AnimatedCharacter(),
                ),

                const SizedBox(height: 10),

                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'ভাষা শিখুন, ',
                        style: TextStyle(
                          color: Color(0xFFFFE000),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: 'ভবিষ্যৎ গড়ুন',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ── EMAIL FIELD ────────────────────────────────────
                _LoginField(
                  controller: _emailCtrl,
                  hint: 'enter_email'.tr,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() => _error = null),
                ),
                const SizedBox(height: 14),

                // ── PASSWORD FIELD ─────────────────────────────────
                _LoginField(
                  controller: _passCtrl,
                  hint: 'enter_password'.tr,
                  isPassword: true,
                  obscure: _obscure,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  onChanged: (_) => setState(() => _error = null),
                ),

                // ── ERROR ──────────────────────────────────────────
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFFF2D2D), size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Color(0xFFFF2D2D),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 20),

                // ── SIGN IN BUTTON ─────────────────────────────────
                SizedBox(
                  width: 170,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E8FD4),
                      disabledBackgroundColor:
                          const Color(0xFF2E8FD4).withValues(alpha: 0.6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
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
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            )),
                  ),
                ),

                const SizedBox(height: 14),

                Text('forgot_password'.tr,
                    style: const TextStyle(
                      color: Color(0xFFFFE000),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    )),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Expanded(
                        child: Divider(color: Colors.white60, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text('or_sign_in_with'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          )),
                    ),
                    const Expanded(
                        child: Divider(color: Colors.white60, thickness: 1)),
                  ],
                ),

                const SizedBox(height: 14),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialBtn(
                      color: Color(0xFF1877F2),
                      icon: Icons.facebook,
                      iconColor: Colors.white,
                    ),
                    SizedBox(width: 16),
                    SocialBtn(
                      color: Colors.white,
                      icon: Icons.g_mobiledata,
                      iconColor: Color(0xFFEA4335),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Text('new_here'.tr,
                    style: const TextStyle(color: Colors.white, fontSize: 13)),

                const SizedBox(height: 10),

                SizedBox(
                  width: 170,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () => Get.to(() => const SignUpScreen()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text('lets_sign_up'.tr,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reusable login text field ──────────────────────────────────────
class _LoginField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final bool obscure;
  final TextInputType keyboardType;
  final VoidCallback? onToggleObscure;
  final ValueChanged<String>? onChanged;

  const _LoginField({
    required this.controller,
    required this.hint,
    this.isPassword = false,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.onToggleObscure,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && obscure,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          suffixIcon: isPassword
              ? GestureDetector(
                  onTap: onToggleObscure,
                  child: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white70,
                    size: 20,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
