import 'package:e_taxi/widgets/cacheNetworkImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/app_colors.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/custome_img.dart';

class SelectvehicleWidget extends StatelessWidget {
  const SelectvehicleWidget({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.isFile=false,
    super.key,
  });

  final String title;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isFile;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 88.h,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? AppColors.mainPrimaryColor
                : AppColors.textFieldBorderColor,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isFile?CustomImage(image: icon,ht: 32.h,wt: 32.w, ):
            NetworkImageWidget(
              image: icon,
              radius: 0,
              ht: 32.h,
              wt: 32.w,
              boxFit: BoxFit.cover,
            ),
            4.verticalSpace,
            CommonText(
              string: title,
              fontWeight: FontWeight.w400,
              fontSize: 16.sp,
              color: AppColors.textSecondaryColor,
              overflow: TextOverflow.fade,
            ),
          ],
        ),
      ),
    );
  }
}
