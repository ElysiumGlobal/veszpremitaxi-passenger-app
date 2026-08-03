import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CheckboxWidget extends StatelessWidget {
  const CheckboxWidget({
    required this.onTap,
    required this.title,
    required this.select,
    this.radius,
    super.key,
  });

  final String title;
  final bool select;
  final Function(bool) onTap;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey("$title"),
      onTap: () {
        onTap(!select);
      },
      behavior: HitTestBehavior.translucent,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            height: 24.h,
            width: 24.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius ?? 4.r),
              border: Border.all(
                color: select
                    ? AppColors.mainPrimaryColor
                    : AppColors.blackColor,
              ),
              color: select
                  ? AppColors.mainPrimaryColor
                  : AppColors.transparentColor,
            ),
            alignment: Alignment.center,
            child: select
                ? CustomImage(
                    image: IconAsset.done,
                    ht: 16.h,
                    wt: 16.h,
                    color: AppColors.whiteColor,
                  )
                : null,
          ),
          8.horizontalSpace,
          CommonText(string: title),
        ],
      ),
    );
  }
}
