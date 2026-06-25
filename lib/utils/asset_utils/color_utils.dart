import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ColorUtils {

  static const Color white255 = Color.fromRGBO(255,255,255,1);
  static const Color primeBlue = Color(0xFF4DA6E8);
  static const Color primeYellow = Color(0xFFFFE000);
  static const Color primeGray = Color(0xFF888888);
  static const Color deepSkyColor = Color(0xFF63BCE5);
  static const Color skyColor = Color(0xFF9AD7F2);
  static const Color lightSkyColor = Color(0xFFE1F3FC);

  static const Color skyTop     = Color(0xFF7DD3FC);
  static const Color skyMid     = Color(0xFFCDEBFB);
  static const Color goldBottom = Color(0xFFFFE34D);

  static const pageGradient = LinearGradient(
    colors: [skyTop, skyMid, goldBottom],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}