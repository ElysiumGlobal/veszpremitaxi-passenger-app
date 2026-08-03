import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubtitleTitleWidget extends StatelessWidget {
  const SubtitleTitleWidget({
    required this.title,
    required this.subTitle,
    required this.secsubTitle,
    required this.sectitle,
    required this.thirdsubTitle,
    required this.thirdtitle,
    this.topBlackColor = false,
    super.key,
  });

  final String title;
  final String subTitle;

  final String sectitle;
  final String secsubTitle;
  final String thirdtitle;
  final String thirdsubTitle;
  final bool topBlackColor;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: commonWidget(title, subTitle)),
          VerticalDivider(
            color: topBlackColor
                ? AppColors.titleTextColor
                : AppColors.textFieldBorderColor,
          ),
          Expanded(child: commonWidget(sectitle, secsubTitle)),
          VerticalDivider(
            color: topBlackColor
                ? AppColors.titleTextColor
                : AppColors.textFieldBorderColor,
          ),
          Expanded(child: commonWidget(thirdtitle, thirdsubTitle)),
        ],
      ),
    );
  }

  Widget commonWidget(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        if (topBlackColor == false) ...{
          CommonText(
            string: title,
            fontWeight: FontWeight.w400,
            fontSize: 12.sp,
            color: AppColors.textCaptionColor,
          ),
          4.verticalSpace,
          CommonText(
            string: subtitle,
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
          ),
        },
        if (topBlackColor) ...{
          CommonText(
            string: title,
            fontWeight: FontWeight.w500,
            fontSize: 16.sp,
          ),
          4.verticalSpace,
          CommonText(
            string: subtitle,
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
            color: AppColors.textSecondaryColor,
          ),
        },
      ],
    );
  }
}
