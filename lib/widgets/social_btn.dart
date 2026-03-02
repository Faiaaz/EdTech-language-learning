import 'package:flutter/material.dart';

class SocialBtn extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Color iconColor;

  const SocialBtn({
    super.key,
    required this.color,
    required this.icon,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: 24),
    );
  }
}
