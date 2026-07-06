import 'package:ez_trainz/utils/utils.dart';
import 'package:flutter/material.dart';

class EzTrainzLogoTextWidget {

  Widget ezTrainzLogoTextWidget({
    Alignment alignment = Alignment.center,
    required String imagePath,
    required ImageSourceType sourceType,
    required double height,
    required double width,
    required BuildContext context,
  }) {
    return Align(
      alignment: alignment,
      child: ImageHelperWidget().imageHelperWidget(
        imagePath: imagePath,
        sourceType: sourceType,
        height: height,
        width: width,
        context: context,
      ),
    );
  }
}