import 'dart:math';
import 'package:flutter/material.dart';

class ResponsiveConfig {
  ResponsiveConfig._();

  static const double designWidth = 428.0;
  static const double designHeight = 926.0;

  static late MediaQueryData _mediaQuery;
  static late Size _screenSize;

  static late double _widthScale;
  static late double _heightScale;
  static late double _scale;

  /// Initialize once (recommended in MaterialApp builder)
  static void init(BuildContext context) {
    final mq = MediaQuery.of(context);

    _mediaQuery = mq;
    _screenSize = mq.size;

    _widthScale = _screenSize.width / designWidth;
    _heightScale = _screenSize.height / designHeight;

    _scale = min(_widthScale, _heightScale);
  }

  /// Screen info
  static Size get screenSize => _screenSize;
  static double get screenWidth => _screenSize.width;
  static double get screenHeight => _screenSize.height;

  /// Width scaling
  static double width(num value) {
    return (value * _widthScale);
  }

  /// Height scaling
  static double height(num value) {
    return (value * _heightScale);
  }

  /// Radius scaling (use uniform scale)
  static double radius(num value) {
    return (value * _scale);
  }

  /// Font scaling (respects accessibility properly)
  static double font(num value) {
    return _mediaQuery.textScaler.scale(value * _scale);
  }

}

/// Extensions
extension ResponsiveExtension on num {
  /// width
  double get w => ResponsiveConfig.width(this);

  /// height
  double get h => ResponsiveConfig.height(this);

  /// font size
  double get sp => ResponsiveConfig.font(this);

  /// radius
  double get r => ResponsiveConfig.radius(this);

  /// all padding margin
  double get apm => ResponsiveConfig.radius(this);

  /// horizontal padding/margin
  double get hp => ResponsiveConfig.width(this);

  /// vertical padding/margin
  double get vp => ResponsiveConfig.height(this);
}