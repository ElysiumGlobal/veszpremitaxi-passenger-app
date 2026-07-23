import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/cupertino.dart';
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 145.w,
        padding: EdgeInsetsGeometry.symmetric(horizontal: 8.w, vertical: 8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: AppColors.whiteColor,
        ),

        child: Row(
          children: [
            CustomImage(image: image),
            8.horizontalSpace,
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(string: title, fontSize: 14.sp),
                  if (subtitle.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: CommonText(
                        string: subtitle,
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
    );
  }
}
