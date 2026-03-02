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
    if (v.isEmpty) return 'Full name is required';
    if (v.length < 3) return 'Name must be at least 3 characters';
    if (!RegExp(r"^[a-zA-Z\s\-'.]+$").hasMatch(v)) {
      return 'Name can only contain letters, spaces, or hyphens';
    }
    return null;
  }

  String? _validateEmail(String v) {
    v = v.trim();
    if (v.isEmpty) return 'Email address is required';
    if (!RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-z]{2,}$').hasMatch(v)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String v) {
    v = v.trim();
    if (v.isEmpty) return 'Phone number is required';
    final cleaned = v.replaceAll(RegExp(r'[\s\-()]'), '');
    final normalized = cleaned.startsWith('+88')
        ? cleaned.substring(3)
        : (cleaned.startsWith('88') && cleaned.length == 13)
            ? cleaned.substring(2)
            : cleaned;
    if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(normalized)) {
      return 'Enter a valid BD number (e.g. 017XXXXXXXX)';
    }
    return null;
  }

  String? _validatePassword(String v) {
    if (v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Must include an uppercase letter';
    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Must include a number';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\+\=\[\]\/\~`]').hasMatch(v)) {
      return 'Must include a special character (e.g. @, #, !)';
    }
    return null;
  }

  String? _validateConfirm(String v) {
    if (v.isEmpty) return 'Please confirm your password';
    if (v != _passCtrl.text) return 'Passwords do not match';
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
      if (mounted) setState(() { _apiError = "Something went wrong: $e"; _isLoading = false; });
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4DA6E8),
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'EZ',
                          style: TextStyle(
                            color: Color(0xFFFFE000),
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            height: 1,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'TRAINZ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),

            // ── SCROLLABLE FORM ───────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideIn,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'আপনার ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    height: 1.4,
                                  ),
                                ),
                                TextSpan(
                                  text: 'অ্যাকাউন্ট',
                                  style: TextStyle(
                                    color: Color(0xFFFFE000),
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    height: 1.4,
                                  ),
                                ),
                                TextSpan(
                                  text: ' তৈরি করুন',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            'Create your account',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 16),

                          LabeledField(
                            label: 'Full Name',
                            hint: 'Enter your full name',
                            icon: Icons.person_outline_rounded,
                            controller: _nameCtrl,
                            errorText: _nameError,
                            onChanged: (_) =>
                                setState(() => _nameError = null),
                          ),
                          const SizedBox(height: 12),

                          LabeledField(
                            label: 'Email Address',
                            hint: 'Enter your email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailCtrl,
                            errorText: _emailError,
                            onChanged: (_) =>
                                setState(() => _emailError = null),
                          ),
                          const SizedBox(height: 12),

                          LabeledField(
                            label: 'Phone Number',
                            hint: '017XXXXXXXX',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            controller: _phoneCtrl,
                            errorText: _phoneError,
                            onChanged: (_) =>
                                setState(() => _phoneError = null),
                          ),
                          const SizedBox(height: 12),

                          LabeledField(
                            label: 'Password',
                            hint: 'Min 8 chars, uppercase, number, symbol',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            controller: _passCtrl,
                            errorText: _passError,
                            onChanged: (_) =>
                                setState(() => _passError = null),
                          ),
                          const SizedBox(height: 12),

                          LabeledField(
                            label: 'Confirm Password',
                            hint: 'Re-enter your password',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            controller: _confirmCtrl,
                            errorText: _confirmError,
                            onChanged: (_) =>
                                setState(() => _confirmError = null),
                          ),

                          // ── API ERROR BANNER ──────────────────────
                          if (_apiError != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF2D2D).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFFF2D2D), width: 1),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: Color(0xFFFF2D2D), size: 18),
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

                          // ── NINJA PENGUIN ─────────────────────────
                          const Align(
                            alignment: Alignment.center,
                            child: Image(
                              image: AssetImage(
                                  'assets/images/ninja_penguin_transparent.png'),
                              height: 120,
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── BOTTOM ACTIONS ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onContinue,
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
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Color(0xFFFFE000),
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
          ],
        ),
      ),
    );
  }
}