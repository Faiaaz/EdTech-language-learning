import 'package:ez_trainz/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';


class SpaceHelperWidget {

  /// Horizontal Spacing
  static Widget h(double width) {
    return SizedBox(width: width.w);
  }

  /// Vertical Spacing
  static Widget v(double height) {
    return SizedBox(height: height.h);
  }

  /// Square Spacing (equal width & height)
  static Widget sq(double height,double width) {
    return SizedBox(width: width.w, height: height.h);
  }

}