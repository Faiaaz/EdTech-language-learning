import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB8E4F8),
      body: Center(
        child: Image.asset(
          'assets/images/login_sky_bg.gif',
          fit: BoxFit.contain,
          width: double.infinity,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
