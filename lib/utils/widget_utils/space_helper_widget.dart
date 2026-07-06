import 'package:ez_trainz/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';


class SpaceHelperWidget {

  /// Horizontal Spacing
  static Widget h({
    required double width,
    required BuildContext context,
  }) {
    return SizedBox(width: width.w(context));
  }

  /// Vertical Spacing
  static Widget v({
    required double height,
    required BuildContext context,
  }) {
    return SizedBox(height: height.h(context));
  }

  /// Square Spacing (equal width & height)
  static Widget sq({required double height,required double width,required BuildContext context}) {
    return SizedBox(width: width.w(context), height: height.h(context));
  }

}