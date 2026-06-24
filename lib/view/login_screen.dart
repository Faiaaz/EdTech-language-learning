import 'package:flutter/material.dart';

/// Kept as a named route target (/login). Actual post-splash airplane
/// transition and dashboard routing live in splash_screen.dart.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFB8E4F8),
    );
  }
}
