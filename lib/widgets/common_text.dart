import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/constants.dart';

class CommonText extends StatelessWidget {
  final String string;
  final double? fontSize;
  final bool? softWrap;
  final String? fontFamily;
  final FontWeight? fontWeight;
  final Color? color;
  final double? letterSpacing;
  final double? height;
  final TextAlign? textAlign;
  final FontStyle? fontStyle;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextDecoration? textDecoration;
  final Color? decorationColor;

  const CommonText({
    super.key,
    required this.string,
    this.color,
    this.softWrap,
    this.height,
    this.fontFamily,
    this.textAlign,
    this.fontWeight,
    this.fontSize,
    this.letterSpacing,
    this.overflow,
    this.fontStyle,
    this.maxLines,
    this.textDecoration,
    this.decorationColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      string,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap ?? false,
      textAlign: textAlign,
      style: TextStyle(
        fontStyle: fontStyle,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? AppColors.titleTextColor,
        letterSpacing: letterSpacing,
        height: height,
        fontFamily: fontFamily ?? Constants.fontFamily,
        decoration: textDecoration,
        decorationColor: decorationColor,
      ),
    );
  }
}
