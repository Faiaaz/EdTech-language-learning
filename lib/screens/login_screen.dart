import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB8E4F8),
      body: Image.asset(
        'assets/images/login_sky_bg.gif',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.topCenter,
        gaplessPlayback: true,
      ),
    );
  }
}
