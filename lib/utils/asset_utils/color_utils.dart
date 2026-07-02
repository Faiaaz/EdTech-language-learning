import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../app_theme.dart';

class ColorUtils {

  static const Color white255 = Color.fromRGBO(255,255,255,1);
  static const Color primeBlue = Color(0xFF4DA6E8);
  static const Color primeYellow = Color(0xFFFFE000);
  static const Color primeGray = Color(0xFF888888);
  static const Color deepSkyColor = Color(0xFF63BCE5);
  static const Color skyColor = Color(0xFF9AD7F2);
  static const Color lightSkyColor = Color(0xFFE1F3FC);

  static const Color skyTop = Color(0xFF7DD3FC);
  static const Color skyMid = Color(0xFFCDEBFB);
  static const Color goldBottom = Color(0xFFFFE34D);

  static const Color textPrimary = Color(0xFF0F2233);
  static const Color textMuted   = Color(0xFF52617A);
  static const Color accentYellow = Color(0xFFFFD000);

  static const Color border  = Color(0xFFD6E4F0);

  static const Color cardAlt = Color(0xFFFFFBEA);
  static const Color accentBlue   = Color(0xFF0EA5E9);
  static const Color accentBlueDk = Color(0xFF0284C7);

  static const pageGradient = LinearGradient(
    colors: [skyTop, skyMid, goldBottom],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}