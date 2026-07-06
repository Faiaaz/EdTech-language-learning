import 'package:ez_trainz/utils/utils.dart';
import 'package:flutter/material.dart';

class EzLogoBoxHelperWidget {

  Widget ezLogoBoxHelperWidget({
    required double containerHeight,
    required double containerWidth,
    required double borderRadius,
    required double fontSize,
    required BuildContext context,
  }) {
    return Container(
      height: containerHeight.h(context),
      width: containerWidth.w(context),
      decoration: BoxDecoration(
        color: ColorUtils.primeBlue,
        borderRadius: BorderRadius.circular(borderRadius.r(context))
      ),
      alignment: Alignment.center,
      child: TextHelperWidget().headingTextWithoutWidth(
        text: "EZ",
        context: context,
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
