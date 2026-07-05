import 'dart:math';

import 'package:flutter/material.dart';

class ResponsiveConfig {
  ResponsiveConfig._();

  /// Reference design size — authored in PORTRAIT
  /// (e.g. iPhone 13/14 Pro Max: 428 x 926 logical pixels).
  static const double designWidth = 428.0;
  static const double designHeight = 926.0;

  static late MediaQueryData _mediaQuery;
  static late Size _screenSize;

  static late double _widthScale;
  static late double _heightScale;
  static late double _effectiveDesignWidth;
  static late double _effectiveDesignHeight;
  static late double _scale;

  static void init(BuildContext context) {
    final mq = MediaQuery.of(context);

    _mediaQuery = mq;
    _screenSize = mq.size;

    final bool isLandscape = mq.orientation == Orientation.landscape;
    _effectiveDesignWidth = isLandscape ? designHeight : designWidth;
    _effectiveDesignHeight = isLandscape ? designWidth : designHeight;
    print(_effectiveDesignWidth);
    print(_effectiveDesignHeight);

    _widthScale = _screenSize.width / _effectiveDesignWidth;
    _heightScale = _screenSize.height / _effectiveDesignHeight;

    print(_widthScale);
    print(_heightScale);

    _scale = min(_widthScale, _heightScale);
  }

  /// Screen info
  static Size get screenSize => _screenSize;
  static double get screenWidth => _screenSize.width;
  static double get screenHeight => _screenSize.height;
  static bool get isLandscape => _mediaQuery.orientation == Orientation.landscape;

  static double width(num value) {
    return value * _widthScale;
  }

  static double height(num value) {
    return value * _heightScale;
  }

  /// Radius scaling (use uniform scale)
  static double radius(num value) {
    return value * _scale;
  }

  /// Font scaling (respects accessibility properly)
  static double font(num value) {
    return _mediaQuery.textScaler.scale(value * _scale);
  }

  static double fullWidth() {
    return isLandscape ? (926 * _widthScale) : (428 * _widthScale);
  }

  static double fullHeight() {
    return isLandscape ? (428 * _heightScale) : (926 * _heightScale);
  }
}

/// Extensions
extension ResponsiveExtension on num {
  /// width
  double w() {
    return ResponsiveConfig.width(this);
  }

  /// height
  double h() {
    return ResponsiveConfig.height(this);
  }

  /// font size
  double sp() {
    return ResponsiveConfig.font(this);
  }

  /// radius
  double r() {
    return ResponsiveConfig.radius(this);
  }

  /// all padding margin
  double apm() {
    return ResponsiveConfig.radius(this);
  }

  /// horizontal padding/margin
  double hp() {
    return ResponsiveConfig.width(this);
  }

  /// vertical padding/margin
  double vp() {
    return ResponsiveConfig.height(this);
  }

  /// full width
  double fw() {
    return ResponsiveConfig.fullWidth();
  }

  /// full height
  double fh() {
    return ResponsiveConfig.fullHeight();
  }
}