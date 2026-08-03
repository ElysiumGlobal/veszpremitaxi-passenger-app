import 'package:e_taxi/widgets/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';
import '../utils/assets.dart';
import 'common_text.dart';
import 'custome_img.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.automaticallyImplyLeading,
    this.actions,
    this.centerTitle,
    this.appBarSize,
    this.bottom,
    this.leading,
    this.color,
    this.leadingSize,
    this.titleWidget,
  });

  final String? title;
  final bool? automaticallyImplyLeading;
  final bool? centerTitle;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double? appBarSize;
  final double? leadingSize;
  final Widget? leading;
  final Color? color;
  final Widget? titleWidget;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
      leadingWidth: leadingSize,
      titleSpacing: 5.w,

      surfaceTintColor: AppColors.transparent,
      leading: (automaticallyImplyLeading ?? true) && leading == null
          ? GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Container(
                height: 48.h,
                width: 48.h,
                alignment: Alignment.center,
                child: CustomWidget.iconChange(
                  child: CustomImage(
                    image: IconAsset.arrowLeft,
                    ht: 24.h,
                    wt: 24.h,
                  ),
                ),
              ),
            )
          : leading,
      elevation: 0,
      shadowColor: AppColors.transparent,
      backgroundColor: color ?? AppColors.whiteColor,
      title:
          titleWidget ??
          CommonText(
            string: title ?? "",
            color: AppColors.titleTextColor,
            fontWeight: FontWeight.w500,
            fontSize: 16.sp,
          ),
      centerTitle: centerTitle ?? true,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarSize ?? 64.h);
}
