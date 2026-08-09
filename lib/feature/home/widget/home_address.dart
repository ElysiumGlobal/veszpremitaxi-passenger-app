import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeAddressWidget extends StatelessWidget {
  const HomeAddressWidget({
    required this.onTap,
    required this.title,
    required this.image,
    required this.subtitle,
    super.key,
  });

  final String image;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 145.w,
          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: AppColors.whiteColor,
            border: Border.all(
              color: AppColors.brandNavy.withValues(alpha: .08),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandNavy.withValues(alpha: .055),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: AppColors.primaryContainer,
                ),
                alignment: Alignment.center,
                child: CustomImage(image: image, ht: 18.w, wt: 18.w),
              ),
              8.horizontalSpace,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      string: title,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandNavy,
                    ),
                    if (subtitle.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: CommonText(
                          string: subtitle,
                          fontSize: 11.sp,
                          color: AppColors.textCaptionColor,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
