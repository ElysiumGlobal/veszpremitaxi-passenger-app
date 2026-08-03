import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../widgets/cacheNetworkImage.dart';

class ListTileWidget extends StatelessWidget {
  const ListTileWidget({
    required this.image,
    required this.title,
    this.trailing,
    this.trailingWidget,
    this.subtitle,
    this.bodyWidget,
    super.key,
  });

  final String image;
  final String title;
  final String? subtitle;
  final String? trailing;
  final Widget? bodyWidget;
  final Widget? trailingWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.textFieldBorderColor),
      ),
      child: Row(
        children: [
          NetworkImageWidget(image: image, ht: 48.w, wt: 48.w, radius: 50.r),
          16.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  string: title,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
                subtitle != null
                    ? CommonText(
                        string: subtitle!,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.bodyText,
                      )
                    : bodyWidget!,
              ],
            ),
          ),
          if (trailingWidget != null) trailingWidget ?? SizedBox.shrink(),
          if (trailing != null)
            CommonText(
              string: trailing!,
              fontWeight: FontWeight.w500,
              fontSize: 16.sp,
            ),
        ],
      ),
    );
  }
}
