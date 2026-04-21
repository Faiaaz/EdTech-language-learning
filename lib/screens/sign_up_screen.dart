import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/services/auth_service.dart';
import 'package:ez_trainz/screens/otp_screen.dart';
import 'package:ez_trainz/widgets/labeled_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  // Controllers
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // Field errors
  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passError;
  String? _confirmError;

  // API state
  bool   _isLoading  = false;
  String? _apiError;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── VALIDATORS ────────────────────────────────────────────────

  String? _validateName(String v) {
    v = v.trim();
    if (v.isEmpty) return 'val_name_required'.tr;
    if (v.length < 3) return 'val_name_length'.tr;
    if (!RegExp(r"^[a-zA-Z\s\-'.]+$").hasMatch(v)) {
      return 'val_name_format'.tr;
    }
    return null;
  }

  String? _validateEmail(String v) {
    v = v.trim();
    if (v.isEmpty) return 'val_email_required'.tr;
    if (!RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-z]{2,}$').hasMatch(v)) {
      return 'val_email_format'.tr;
    }
    return null;
  }

  String? _validatePhone(String v) {
    v = v.trim();
    if (v.isEmpty) return 'val_phone_required'.tr;
    final cleaned = v.replaceAll(RegExp(r'[\s\-()]'), '');
    final normalized = cleaned.startsWith('+88')
        ? cleaned.substring(3)
        : (cleaned.startsWith('88') && cleaned.length == 13)
            ? cleaned.substring(2)
            : cleaned;
    if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(normalized)) {
      return 'val_phone_format'.tr;
    }
    return null;
  }

  String? _validatePassword(String v) {
    if (v.isEmpty) return 'val_pass_required'.tr;
    if (v.length < 8) return 'val_pass_length'.tr;
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'val_pass_uppercase'.tr;
    if (!RegExp(r'[0-9]').hasMatch(v)) return 'val_pass_number'.tr;
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\+\=\[\]\/\~`]').hasMatch(v)) {
      return 'val_pass_special'.tr;
    }
    return null;
  }

  String? _validateConfirm(String v) {
    if (v.isEmpty) return 'val_confirm_required'.tr;
    if (v != _passCtrl.text) return 'val_confirm_match'.tr;
    return null;
  }

  bool _runValidation() {
    _nameError    = _validateName(_nameCtrl.text);
    _emailError   = _validateEmail(_emailCtrl.text);
    _phoneError   = _validatePhone(_phoneCtrl.text);
    _passError    = _validatePassword(_passCtrl.text);
    _confirmError = _validateConfirm(_confirmCtrl.text);
    return _nameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _passError == null &&
        _confirmError == null;
  }

  // ── API CALL ──────────────────────────────────────────────────

  Future<void> _onContinue() async {
    setState(() => _apiError = null);

    final isValid = _runValidation();
    setState(() {}); // refresh field errors

    if (!isValid) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.signUp(
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        password: _passCtrl.text,
        phoneNumber: _phoneCtrl.text,
      );

      // Cache name, email, phone for OTP page
      AuthController.to.cacheSignUpData(
        name:  _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim().toLowerCase(),
        phone: _phoneCtrl.text.trim(),
      );

      // Stop loading first, then navigate
      if (mounted) setState(() => _isLoading = false);

      // Navigate to OTP screen
      Get.to(() => const OtpScreen());
    } on AuthException catch (e) {
      if (mounted) setState(() { _apiError = e.message; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _apiError = 'login_generic_error'.tr; _isLoading = false; });
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────

  static const _sky = Color(0xFFB8E4F8);
  static const _titleBlue = Color(0xFF1A4F8C);
  static const _btnBlue = Color(0xFF00AEEF);
  static const _ezBlue = Color(0xFF1E88E5);
  static const _yellow = Color(0xFFFFE000);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final topPad = mq.padding.top;
    final bottomPad = mq.padding.bottom;
    final screenH = mq.size.height;

    return Scaffold(
      backgroundColor: _sky,
      body: Stack(
        children: [
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
          Positioned.fill(
            child: Padding(
              padding:
                  EdgeInsets.fromLTRB(20, topPad + 8, 20, bottomPad + 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.38),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.6),
                              width: 1.2,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: _titleBlue,
                            size: 18,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Image.asset(
                            'assets/images/ez_trainz_logo_text_clean.png',
                            height: 48,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: SlideTransition(
                        position: _slideIn,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                color: Colors.white.withValues(alpha: 0.42),
                                border: Border.all(
                                  color:
                                      Colors.white.withValues(alpha: 0.65),
                                  width: 1.5,
                                ),
                              ),
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                    18, 18, 18, 20),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: const TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'আপনার ',
                                            style: TextStyle(
                                              color: _titleBlue,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                              height: 1.35,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'অ্যাকাউন্ট',
                                            style: TextStyle(
                                              color: _yellow,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                              height: 1.35,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' তৈরি করুন',
                                            style: TextStyle(
                                              color: _titleBlue,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                              height: 1.35,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Create your account',
                                      style: TextStyle(
                                        color: _titleBlue.withValues(
                                            alpha: 0.62),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    LabeledField(
                                      label: 'signup_name_label'.tr,
                                      hint: 'signup_name_hint'.tr,
                                      icon: Icons.person_outline_rounded,
                                      controller: _nameCtrl,
                                      errorText: _nameError,
                                      glassStyle: true,
                                      onChanged: (_) => setState(
                                          () => _nameError = null),
                                    ),
                                    const SizedBox(height: 12),
                                    LabeledField(
                                      label: 'signup_email_label'.tr,
                                      hint: 'signup_email_hint'.tr,
                                      icon: Icons.email_outlined,
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      controller: _emailCtrl,
                                      errorText: _emailError,
                                      glassStyle: true,
                                      onChanged: (_) => setState(
                                          () => _emailError = null),
                                    ),
                                    const SizedBox(height: 12),
                                    LabeledField(
                                      label: 'signup_phone_label'.tr,
                                      hint: 'signup_phone_hint'.tr,
                                      icon: Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
                                      controller: _phoneCtrl,
                                      errorText: _phoneError,
                                      glassStyle: true,
                                      onChanged: (_) => setState(
                                          () => _phoneError = null),
                                    ),
                                    const SizedBox(height: 12),
                                    LabeledField(
                                      label: 'signup_pass_label'.tr,
                                      hint: 'signup_pass_hint'.tr,
                                      icon: Icons.lock_outline_rounded,
                                      isPassword: true,
                                      controller: _passCtrl,
                                      errorText: _passError,
                                      glassStyle: true,
                                      onChanged: (_) => setState(
                                          () => _passError = null),
                                    ),
                                    const SizedBox(height: 12),
                                    LabeledField(
                                      label: 'signup_confirm_label'.tr,
                                      hint: 'signup_confirm_hint'.tr,
                                      icon: Icons.lock_outline_rounded,
                                      isPassword: true,
                                      controller: _confirmCtrl,
                                      errorText: _confirmError,
                                      glassStyle: true,
                                      onChanged: (_) => setState(
                                          () => _confirmError = null),
                                    ),
                                    if (_apiError != null) ...[
                                      const SizedBox(height: 14),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF2D2D)
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: const Color(0xFFFF2D2D),
                                              width: 1),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.error_outline,
                                                color: Color(0xFFFF2D2D),
                                                size: 18),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                _apiError!,
                                                style: const TextStyle(
                                                  color: Color(0xFFFF2D2D),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    const Align(
                                      alignment: Alignment.center,
                                      child: Image(
                                        image: AssetImage(
                                            'assets/images/ninja_penguin_transparent.png'),
                                        height: 110,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: _isLoading
                                            ? null
                                            : _onContinue,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _btnBlue,
                                          disabledBackgroundColor: _btnBlue
                                              .withValues(alpha: 0.55),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            side: const BorderSide(
                                                color: Colors.white60,
                                                width: 1.2),
                                          ),
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.5,
                                                ),
                                              )
                                            : Text(
                                                'signup_button'.tr,
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'signup_have_account'.tr,
                                          style: const TextStyle(
                                            color: _titleBlue,
                                            fontSize: 13,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: _isLoading
                                              ? null
                                              : () => Navigator.of(context)
                                                  .pop(),
                                          child: Text(
                                            'signup_sign_in'.tr,
                                            style: const TextStyle(
                                              color: _yellow,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}