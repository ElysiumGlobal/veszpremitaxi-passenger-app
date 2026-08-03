import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';
import 'custom_loading_widget.dart';

class CustomButton extends StatefulWidget {
  final double? height;
  final VoidCallback? onTap;
  final double? width;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? text;
  final Color? buttonColor;
  final Color? disableButtonColor;
  final Color? buttonBorderColor;
  final Color? textColor;
  final Color? disableTextColor;
  final bool isDisabled;
  final bool isLoader;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final Widget? prefixIconWidget;

  const CustomButton({
    super.key,
    this.height,
    this.width,
    this.text,
    this.buttonBorderColor,
    this.buttonColor,
    this.fontWeight,
    this.fontSize,
    this.textColor,
    this.onTap,
    this.margin,
    this.padding,
    this.borderColor,
    this.isDisabled = false,
    this.isLoader = false,
    this.disableButtonColor,
    this.disableTextColor,
    this.borderRadius,
    this.prefixIconWidget,
  });

  @override
  CustomButtonState createState() => CustomButtonState();
}

class CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (widget.isLoader || widget.isDisabled) ? null : widget.onTap,
      child: Container(
        height: widget.height ?? 56.h,
        width: widget.width,
        margin: widget.margin,
        padding: widget.padding,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8.r),
          color: (widget.isDisabled)
              ? (widget.disableButtonColor ?? AppColors.mainPrimaryColor)
              : (widget.buttonColor ?? AppColors.mainPrimaryColor),
          border: Border.all(
            width: 1,
            color: widget.borderColor ?? AppColors.transparent,
          ),
        ),
        child: Center(
          child: widget.isLoader
              ? CustomLoadingWidget(color: AppColors.whiteColor, size: 22.h)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: widget.prefixIconWidget != null
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.end,
                  children: [
                    if (widget.prefixIconWidget != null)
                      widget.prefixIconWidget ?? const SizedBox.shrink(),
                    Text(
                      widget.text ?? "",
                      style: TextStyle(
                        fontSize: widget.fontSize ?? 16.sp,
                        fontWeight: widget.fontWeight ?? FontWeight.w500,
                        color: (widget.isDisabled)
                            ? widget.disableTextColor ??
                                  AppColors.textSecondaryColor
                            : widget.textColor ?? AppColors.titleTextColor,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
