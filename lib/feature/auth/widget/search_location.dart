import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/assets.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/custome_img.dart';

class SearchLocationWidget extends StatelessWidget {
  const SearchLocationWidget({
    required this.subTitle,
    required this.title,
    required this.onTap,
    super.key,
  });

  final String title;
  final String subTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomImage(image: ImagesAsset.location, ht: 24.w, wt: 24.w),
          14.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  string: title,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                4.verticalSpace,
                CommonText(
                  string: subTitle,
                  fontSize: 12.sp,
                  overflow: TextOverflow.ellipsis,
                  color: AppColors.textCaptionColor,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
