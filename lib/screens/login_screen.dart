import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/screens/main_shell_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeOut;

  @override
  void initState() {
    super.initState();
    _fadeOut = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    // Show the GIF for ~3 s then fade out and go to the dashboard.
    Future.delayed(const Duration(milliseconds: 3000), _navigateToDashboard);
  }

  Future<void> _navigateToDashboard() async {
    if (!mounted) return;
    await _fadeOut.forward();
    if (mounted) Get.offAll(() => const MainShellScreen());
  }

  @override
  void dispose() {
    _fadeOut.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: ReverseAnimation(_fadeOut),
        child: Container(
          decoration: const BoxDecoration(
            // Gradient mirrors the GIF's sky-to-cloud palette so the edges
            // of the contained image dissolve invisibly into the background.
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF5BBAD9), // deep sky — matches top edge of GIF
                Color(0xFF8ED4EE), // mid sky
                Color(0xFFB8E4F8), // horizon blue
                Color(0xFFD8EFF8), // haze
                Color(0xFFEDF8FD), // near-white cloud base
              ],
              stops: [0.0, 0.22, 0.45, 0.72, 1.0],
            ),
          ),
          child: Center(
            child: Image.asset(
              'assets/images/login_sky_bg.gif',
              fit: BoxFit.contain,
              width: double.infinity,
              gaplessPlayback: true,
            ),
          ),
        ),
      ),
    );
  }
}
