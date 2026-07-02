import 'package:flutter/material.dart';
import 'package:ez_trainz/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';

class TextHelperWidget {


  Gradient? _resolveGradient({
    Gradient? gradient,
    List<Color>? colors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end   = Alignment.bottomRight,
  }) {
    return gradient ?? (colors != null ? LinearGradient(colors: colors, begin: begin, end: end) : null);
  }

  TextStyle _buildTextStyle({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.montserrat(
      fontSize: fontSize?.sp,
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration ?? TextDecoration.none,
    );
  }


  BoxDecoration _buildDecoration({
    required Color containerColor,
    required BoxShape shape,
    Gradient? gradient,
    BorderRadiusGeometry? borderRadius,
    required bool hasBorder,
    required Color borderColor,
    required double borderWidth,
  }) {
    return BoxDecoration(
      color: gradient != null ? null : containerColor,
      gradient: gradient,
      shape: shape,
      borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
      border: hasBorder
          ? Border.all(color: borderColor, width: borderWidth.w)
          : null,
    );
  }

// ─── Public widget function ──────────────────────────────────────────────────

  Widget headingText({
    // Content
    required String text,

    // Typography
    double fontSize = 24,
    Color textColor = const Color.fromRGBO(35, 47, 48, 1),
    FontWeight fontWeight = FontWeight.w700,
    FontStyle fontStyle = FontStyle.normal,
    double? letterSpacing,
    double? lineHeight,
    TextDecoration? textDecoration,
    TextAlign textAlign = TextAlign.start,
    TextOverflow overflow = TextOverflow.visible,
    int? maxLines,

    // Layout
    double width = 428,
    double? circleDiameter,
    Alignment alignment = Alignment.centerLeft,
    EdgeInsetsGeometry? padding,

    // Appearance
    Color containerColor = Colors.transparent,
    BorderRadiusGeometry? borderRadius,
    BoxShape boxShape = BoxShape.rectangle,

    // Border
    bool hasBorder = false,
    Color borderColor = Colors.black,
    double borderWidth = 1.0,

    // Gradient
    Gradient? gradient,
    List<Color>? gradientColors,
    AlignmentGeometry gradientBegin = Alignment.topLeft,
    AlignmentGeometry gradientEnd = Alignment.bottomRight,
  }) {
    assert(
    boxShape != BoxShape.circle || circleDiameter != null,
    'Provide circleDiameter when using BoxShape.circle',
    );

    final bool isCircle = boxShape == BoxShape.circle;
    final double size = (isCircle ? circleDiameter! : width).w;

    final resolvedGradient = _resolveGradient(
      gradient: gradient,
      colors: gradientColors,
      begin: gradientBegin,
      end: gradientEnd,
    );

    final textWidget = Text(
      text,
      maxLines: maxLines,
      overflow: maxLines != null ? overflow : TextOverflow.visible,
      textAlign: isCircle ? TextAlign.center : textAlign,
      style: _buildTextStyle(
        fontSize: fontSize,
        color: textColor,
        fontWeight: fontWeight,
        height: lineHeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        decoration: textDecoration,
      ),
    );

    return Container(
      width: size,
      height: isCircle ? size : null,
      alignment: isCircle ? Alignment.center : alignment,
      padding: padding ?? EdgeInsets.zero,
      decoration: _buildDecoration(
        containerColor: containerColor,
        shape: boxShape,
        gradient: resolvedGradient,
        borderRadius: borderRadius,
        hasBorder: hasBorder,
        borderColor: borderColor,
        borderWidth: borderWidth,
      ),
      child: isCircle ? FittedBox(fit: BoxFit.contain, child: textWidget) : textWidget,
    );
  }

// ─── Main widget function ────────────────────────────────────────────────────

  Widget headingTextWithoutWidth({
    // Content
    required String text,
    // Typography
    double fontSize = 24,
    Color textColor = const Color.fromRGBO(35, 47, 48, 1),
    FontWeight fontWeight = FontWeight.w700,
    FontStyle fontStyle = FontStyle.normal,
    double? letterSpacing,
    double? lineHeight,
    TextDecoration? textDecoration,
    TextAlign textAlign = TextAlign.start,
    TextOverflow overflow = TextOverflow.ellipsis,
    int? maxLines,
    // Container layout
    Alignment alignment = Alignment.centerLeft,
    EdgeInsetsGeometry? padding,
    // Container appearance
    Color containerColor = Colors.transparent,
    BorderRadiusGeometry? borderRadius,
    BoxShape boxShape = BoxShape.rectangle,
    double? circleDiameter,
    // Border
    bool hasBorder = false,
    Color borderColor = Colors.black,
    double borderWidth = 1.0,
    // Gradient (pass gradient directly, or let it be built from gradientColors)
    Gradient? gradient,
    List<Color>? gradientColors,
    AlignmentGeometry gradientBegin = Alignment.topLeft,
    AlignmentGeometry gradientEnd = Alignment.bottomRight,
  }) {
    final bool isCircle = boxShape == BoxShape.circle;
    final double? size = isCircle ? (circleDiameter ?? 48) : null;

    final resolvedGradient = _resolveGradient(
      gradient: gradient,
      colors: gradientColors,
      begin: gradientBegin,
      end: gradientEnd,
    );

    final textStyle = _buildTextStyle(
      fontSize: fontSize,
      color: textColor,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: lineHeight,
      letterSpacing: letterSpacing,
      decoration: textDecoration,
    );

    final Widget textWidget = Text(
      text,
      maxLines: maxLines,
      overflow: maxLines != null ? overflow : TextOverflow.visible,
      textAlign: isCircle ? TextAlign.center : textAlign,
      style: textStyle,
    );

    return Container(
      width: size,
      height: size,
      alignment: isCircle ? Alignment.center : alignment,
      padding: padding ?? EdgeInsets.zero,
      decoration: _buildDecoration(
        containerColor: containerColor,
        shape: boxShape,
        gradient: resolvedGradient,
        borderRadius: borderRadius,
        hasBorder: hasBorder,
        borderColor: borderColor,
        borderWidth: borderWidth,
      ),
      child: isCircle ? FittedBox(fit: BoxFit.scaleDown, child: textWidget) : textWidget,
    );
  }

  Widget flagIcon(String flagEmoji) {
    return Text(
      flagEmoji,
      style: GoogleFonts.montserrat(
        fontSize: 26.sp,
        height: 1.2,
      ),
    );
  }


}