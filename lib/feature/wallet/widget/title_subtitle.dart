import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/app_colors.dart';
import '../../../widgets/common_text.dart';

class CommonColumn extends StatelessWidget {
  const CommonColumn({required this.title, required this.subTitle, super.key});

  final String title;
  final String subTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CommonText(string: title, fontWeight: FontWeight.w500, fontSize: 16.sp),
        CommonText(
          string: subTitle,
          fontSize: 12.sp,
          color: AppColors.headlineColor,
        ),
      ],
    );
  }
}
