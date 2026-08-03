import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';
import 'common_text.dart';

class CustomTextField extends StatelessWidget {
  final bool readOnly;
  final TextEditingController controller;
  final int maxLine;
  final int minLine;
  final Function(String)? onChanged;
  final Function(String?)? onSaved;
  final String? Function(String?)? validation;
  final TextInputType keyboardType;
  final int? maxLength;
  final double? radius;
  final bool enabled;
  final FocusNode? focusNode;
  final String? hintText;
  final TextAlign? textAlign;
  final Color? fillColor;
  final VoidCallback? onTap;
  final Color? enableColor;
  final Color? focusedColor;
  final Color? cursorColor;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final String? title;
  final String? prefixIcon;
  final String? suffixIcon;
  final bool isPasswordField;
  final bool titleblack;
  final Widget? titlestarWidget;
  final TextInputAction textInputAction;
  final Function(PointerDownEvent event)? onOutTap;
  final bool showSend;
  final List<TextInputFormatter>? textinputformate;
  final TextStyle? hintTextStyle;
  final VoidCallback? onSendTap;
  final double? textfielHeight;
  final bool? isShowError;
  final bool autoFocus;

  CustomTextField({
    super.key,
    this.onChanged,
    this.maxLine = 1,
    this.minLine = 1,
    this.maxLength,
    this.radius,
    this.fillColor,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.onSaved,
    this.focusNode,
    this.hintText,
    this.textAlign,
    this.onTap,
    this.enableColor,
    this.focusedColor,
    this.cursorColor,
    required this.controller,
    this.contentPadding,
    this.prefixWidget,
    this.suffixWidget,
    this.prefixIcon,
    this.suffixIcon,
    this.title,
    this.textfielHeight,
    this.readOnly = false,
    this.isPasswordField = false,
    this.titlestarWidget,
    this.titleblack = false,
    this.onOutTap,
    this.textInputAction = TextInputAction.done,

    this.textinputformate,
    this.showSend = false,
    this.hintTextStyle,
    this.onSendTap,
    this.validation,
    this.isShowError,
    this.autoFocus = false,
  });

  final ValueNotifier<bool> _isObscure = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title?.isNotEmpty ?? false)
          Row(
            children: [
              CommonText(
                string: title ?? "",
                fontSize: 12.sp,
                color: titleblack
                    ? AppColors.titleTextColor
                    : AppColors.titleTextColor,
                fontWeight: FontWeight.w500,
              ),
              titlestarWidget ?? const SizedBox.shrink(),
            ],
          ).paddingOnly(bottom: 4.h),
        Material(
          borderRadius: BorderRadius.circular(radius ?? 6.r),
          child: ValueListenableBuilder(
            valueListenable: _isObscure,
            builder: (context, bool isObscure, _) {
              if (!isPasswordField) {
                isObscure = false;
              }
              return SizedBox(
                height: textfielHeight ?? 56.h,
                child: IntrinsicHeight(
                  child: TextFormField(
                    autofocus: autoFocus,
                    validator: validation,
                    readOnly: readOnly,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                      color: AppColors.titleTextColor,
                    ),
                    onTap: onTap,
                    obscureText: isPasswordField ? _isObscure.value : false,
                    obscuringCharacter: '*',
                    onChanged: onChanged,
                    controller: controller,
                    maxLines: maxLine,
                    minLines: minLine,
                    maxLength: maxLength,
                    keyboardType: keyboardType,
                    focusNode: focusNode,
                    cursorColor: cursorColor ?? AppColors.mainPrimaryColor,
                    textAlign: textAlign ?? TextAlign.start,
                    enabled: enabled,
                    onFieldSubmitted: onSaved,
                    textInputAction: textInputAction,
                    inputFormatters: textinputformate,

                    decoration: InputDecoration(
                      prefix: prefixWidget,
                      contentPadding:
                          contentPadding ??
                          EdgeInsets.symmetric(
                            vertical: 18.h,
                            horizontal: 12.w,
                          ),
                      isDense: true,
                      counterText: "",
                      prefixIcon: (prefixIcon?.isNotEmpty ?? false)
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomImage(
                                  image: prefixIcon ?? "",
                                  ht: 24.h,
                                  wt: 24.h,
                                  fit: BoxFit.cover,
                                ).paddingOnly(left: 12.w, right: 7.w),
                              ],
                            )
                          : null,
                      suffixIcon: suffixWidget != null
                          ? suffixWidget
                          : isPasswordField
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _isObscure.value = !isObscure;
                                  },
                                  child: Icon(
                                    _isObscure.value
                                        ? CupertinoIcons.eye
                                        : CupertinoIcons.eye_slash,
                                    size: 24.h,
                                  ),
                                ).paddingOnly(right: 12.w),
                              ],
                            )
                          : ((suffixIcon?.isNotEmpty ?? false)
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomImage(
                                        image: suffixIcon ?? "",
                                        ht: 24.h,
                                        wt: 24.h,
                                      ).paddingOnly(left: 10.w, right: 12.w),
                                    ],
                                  )
                                : null),

                      hintText: hintText,
                      hintStyle:
                          hintTextStyle ??
                          TextStyle(
                            color: AppColors.hintTextColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 15.sp,
                          ),
                      filled: true,
                      fillColor: fillColor ?? AppColors.whiteColor,
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(radius ?? 6.r),
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.textFieldBorderColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(radius ?? 6.r),
                        ),
                        borderSide: BorderSide(
                          color: enableColor ?? AppColors.textFieldBorderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(radius ?? 6.r),
                        ),
                        borderSide: BorderSide(
                          color: focusedColor ?? AppColors.textFieldBorderColor,
                        ),
                      ),
                    ),
                    onTapOutside: onOutTap,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
