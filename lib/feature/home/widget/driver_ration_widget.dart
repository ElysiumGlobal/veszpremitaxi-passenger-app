import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/assets.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/custome_img.dart';

class DriverRatingShowWidget extends StatelessWidget {
  const DriverRatingShowWidget({
    required this.firstTitle,
    required this.firstSubTitle,
    required this.secoundSubTitle,
    required this.secoundTitle,
    required this.thirdSubTitle,
    required this.thirdTitle,
    this.istripList = false,

    super.key,
  });

  final String firstTitle;
  final String firstSubTitle;
  final String secoundTitle;
  final String secoundSubTitle;
  final String thirdTitle;
  final String thirdSubTitle;
  final bool istripList;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: iconTextWidget(
              icon: istripList ? IconAsset.money : IconAsset.rating,
              title: firstTitle,
              subTitle: firstSubTitle,
            ),
          ),
          VerticalDivider(
            indent: 20,
            endIndent: 20,
            color: AppColors.textFieldBorderColor,
          ),
          Expanded(
            child: iconTextWidget(
              icon: istripList ? IconAsset.distance : IconAsset.tripCar,
              title: secoundTitle,
              subTitle: secoundSubTitle,
            ),
          ),
          VerticalDivider(
            indent: 20,
            endIndent: 20,
            color: AppColors.textFieldBorderColor,
          ),
          Expanded(
            child: iconTextWidget(
              icon: IconAsset.time,
              title: thirdTitle,
              subTitle: thirdSubTitle,
            ),
          ),
        ],
      ),
    );
  }

  Widget iconTextWidget({
    required String icon,
    required String title,
    required String subTitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomImage(image: icon, wt: 25.w, ht: 25.w),
        8.verticalSpace,
        CommonText(string: title, fontWeight: FontWeight.w500, fontSize: 16.sp),
        4.verticalSpace,
        CommonText(
          string: subTitle,
          fontWeight: FontWeight.w400,
          fontSize: 14.sp,
        ),
      ],
    );
  }
}
