import 'dart:math';

import 'package:flutter/material.dart';

class ResponsiveUtils {

  static Size _screenSize({required BuildContext context}) {
    return MediaQuery.of(context).size;
  }

  /// Width ratio
  static double widthRatio({required BuildContext context}) {
    final screenWidth = _screenSize(context: context).width;
    return screenWidth / DesignUtils.designWidth(context: context);
  }

  /// Height ratio
  static double heightRatio({required BuildContext context}) {
    final screenHeight = _screenSize(context: context).height;
    return screenHeight / DesignUtils.designHeight(context: context);
  }
  
  
  static double scale({required BuildContext context}) {
    return min(widthRatio(context: context), heightRatio(context: context));
  }

  /// Width scaling
  static double width({
    required BuildContext context,
    required num width,
  }) {
    print("print $width");
    if(MediaQuery.of(context).orientation == Orientation.portrait && width == 428) {
      return width * widthRatio(context: context);
    } else if(MediaQuery.of(context).orientation == Orientation.landscape && width == 428) {
      return 926 * widthRatio(context: context);
    } else {
      return width * widthRatio(context: context);
    }
  }

  /// Height scaling
  static double height({
    required BuildContext context,
    required num height,
  }) {
    if(MediaQuery.of(context).orientation == Orientation.portrait && height == 926) {
      return height * heightRatio(context: context);
    } else if(MediaQuery.of(context).orientation == Orientation.landscape && height == 926) {
      return 428 * heightRatio(context: context);
    } else {
      return height * heightRatio(context: context);
    }
  }


  /// Radius scaling (use uniform scale)
  static double radius({required num value,required BuildContext context}) {
    return value * scale(context: context);
  }

  /// Font scaling (respects accessibility properly)
  static double font({required num value,required BuildContext context}) {
    return MediaQueryData().textScaler.scale(value * scale(context: context));
  }


}


class DesignUtils {
  static num designHeight({required BuildContext context}) {
    return MediaQuery.of(context).orientation == Orientation.portrait ? 926 : 428;
  }

  static num designWidth({required BuildContext context}) {
    return MediaQuery.of(context).orientation == Orientation.portrait ? 428 : 926;
  }
}

/// Extensions
extension ResponsiveExtension on num {
  /// width
  double w(BuildContext context) {
    return ResponsiveUtils.width(context: context,width: this);
  }

  /// height
  double h(BuildContext context) {
    return ResponsiveUtils.height(context: context,height: this);
  }

  /// font size
  double sp(BuildContext context) {
    return ResponsiveUtils.font(context: context,value: this);
  }

  /// radius
  double r(BuildContext context) {
    return ResponsiveUtils.radius(context: context,value: this);
  }

  /// all padding margin
  double apm(BuildContext context) {
    return ResponsiveUtils.radius(context: context,value: this);
  }

  /// horizontal padding/margin
  double hp(BuildContext context) {
    return ResponsiveUtils.width(context: context,width: this);
  }

  /// vertical padding/margin
  double vp(BuildContext context) {
    return ResponsiveUtils.height(context: context,height: this);
  }

}