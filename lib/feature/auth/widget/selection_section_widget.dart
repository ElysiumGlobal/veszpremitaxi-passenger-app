import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/assets.dart';
import '../../../widgets/custome_img.dart';

class SelectionSectionWidget extends StatelessWidget {
  const SelectionSectionWidget({required this.index, super.key});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
      height: 72.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        border: Border(top: BorderSide(color: AppColors.textFieldBorderColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          index == 0
              ? CustomImage(
                  image: ImagesAsset.locationSelect,
                  ht: 40.h,
                  wt: 40.h,
                )
              : Container(
                  height: 40.h,
                  width: 40.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.mainPrimaryColor,
                  ),
                  alignment: Alignment.center,
                  child: CustomImage(image: IconAsset.done, ht: 20.h, wt: 20.h),
                ),
          Container(
            margin: EdgeInsetsGeometry.symmetric(horizontal: 4.w),
            width: 16.w,
            height: 1,
            color: AppColors.titleTextColor,
          ),
          index <= 1
              ? CustomImage(
                  image: index == 1
                      ? ImagesAsset.selectedProfile
                      : ImagesAsset.profile,
                  ht: 40.h,
                  wt: 40.h,
                )
              : Container(
                  height: 40.h,
                  width: 40.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.mainPrimaryColor,
                  ),
                  alignment: Alignment.center,
                  child: CustomImage(image: IconAsset.done, ht: 20.h, wt: 20.h),
                ),
          Container(
            margin: EdgeInsetsGeometry.symmetric(horizontal: 4.w),
            width: 16.w,
            height: 1,
            color: AppColors.titleTextColor,
          ),
          index <= 2
              ? CustomImage(
                  image: index == 2 ? ImagesAsset.selectedCar : ImagesAsset.car,
                  ht: 40.h,
                  wt: 40.h,
                )
              : Container(
                  height: 40.h,
                  width: 40.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.mainPrimaryColor,
                  ),
                  alignment: Alignment.center,
                  child: CustomImage(image: IconAsset.done, ht: 20.h, wt: 20.h),
                ),
          Container(
            margin: EdgeInsetsGeometry.symmetric(horizontal: 4.w),
            width: 16.w,
            height: 1,
            color: AppColors.titleTextColor,
          ),
          CustomImage(
            image: index == 3 ? ImagesAsset.selectedFile : ImagesAsset.document,
            ht: 40.h,
            wt: 40.h,
          ),
        ],
      ),
    );
  }
}
