import 'package:flutter/material.dart';

class EZLogoBoxed extends StatelessWidget {
  const EZLogoBoxed({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFF4DA6E8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'EZ',
          style: TextStyle(
            color: Color(0xFFFFE000),
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            height: 1,
          ),
        ),
      ),
    );
  }
}
