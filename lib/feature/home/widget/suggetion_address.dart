import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SuggestionAddressWidget extends StatelessWidget {
  const SuggestionAddressWidget({
    required this.onTap,
    required this.title,
    required this.subTitle,
    super.key,
  });

  final String title;
  final String subTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: AppColors.textFieldBorderColor.withValues(alpha: .55),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withValues(alpha: .045),
              blurRadius: 9,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.textFieldBorderColor,
              ),
              child: CustomImage(
                image: IconAsset.locationPin,
                ht: 15.h,
                wt: 15.h,
                fit: BoxFit.cover,
              ),
            ),
            10.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    string: title,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  2.verticalSpace,
                  CommonText(
                    string: subTitle,
                    fontSize: 11.sp,
                    overflow: TextOverflow.ellipsis,
                    color: AppColors.textCaptionColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
