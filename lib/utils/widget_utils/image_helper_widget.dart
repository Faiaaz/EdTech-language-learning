import 'dart:io';
import 'package:ez_trainz/utils/utils.dart';
import 'package:flutter/material.dart';

enum ImageSourceType { asset, network, file }

class ImageHelperWidget {

  Widget imageHelperWidget({
    required BuildContext context,
    required String imagePath,
    required ImageSourceType sourceType,
    required double height,
    required double width,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    Color? color,
    BlendMode? colorBlendMode,
    String? semanticLabel,
    FilterQuality filterQuality = FilterQuality.high,
    bool gaplessPlayback = true,
  }) {

    ImageProvider resolveProvider() {
      switch (sourceType) {
        case ImageSourceType.network:
          return NetworkImage(imagePath);
        case ImageSourceType.asset:
          return AssetImage(imagePath);
        case ImageSourceType.file:
          final path = imagePath.startsWith('file://')
              ? Uri.parse(imagePath).toFilePath()
              : imagePath;
          return FileImage(File(path));
      }
    }

    Widget fallback({
      required Widget child,
      required BuildContext context,
    }) {
      return SizedBox(
        height: height.h(context),
        width: width.w(context),
        child: Center(child: child),
      );
    }

    Widget content = SizedBox(
      height: height.h(context),
      width: width.w(context),
      child: FittedBox(
        fit: fit,
        child: Image(
          image: resolveProvider(),
          color: color,
          colorBlendMode: colorBlendMode,
          semanticLabel: semanticLabel,
          filterQuality: filterQuality,
          gaplessPlayback: gaplessPlayback,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return fallback(
              context: context,
              child: placeholder ?? SizedBox(
                height: 20.h(context),
                width: 20.w(context),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return fallback(
              context: context,
              child: errorWidget ?? const Icon(
                Icons.broken_image_outlined,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );

    return content;
  }


}

