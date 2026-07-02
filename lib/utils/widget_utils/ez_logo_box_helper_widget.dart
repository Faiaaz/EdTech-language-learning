import 'package:ez_trainz/utils/utils.dart';
import 'package:flutter/material.dart';

class EzLogoBoxHelperWidget {

  Widget ezLogoBoxHelperWidget({
    required double containerHeight,
    required double containerWidth,
    required double borderRadius,
    required double fontSize,
  }) {
    return Container(
      height: containerHeight.h(),
      width: containerWidth.w(),
      decoration: BoxDecoration(
        color: ColorUtils.primeBlue,
        borderRadius: BorderRadius.circular(borderRadius.r())
      ),
      alignment: Alignment.center,
      child: TextHelperWidget().headingTextWithoutWidth(
        text: "EZ",
        alignment: Alignment.center,
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        textColor: ColorUtils.primeYellow,
        letterSpacing: 1.5,
        lineHeight: 1,
      ),
    );
  }


}
