import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/cupertino.dart';
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
              ht: 24.w,
              wt: 24.w,
            ),
          ),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
