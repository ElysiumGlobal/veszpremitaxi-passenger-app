import 'package:e_taxi/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/app_colors.dart';
import '../../../widgets/common_text.dart';

class CustomCircularProgress extends StatelessWidget {
  const CustomCircularProgress({
    this.customWidget,
    this.stokevalue = 2,
    required this.size,
    required this.title,
    required this.progressValue,
    super.key,
  });

  final double size;
  final String title;
  final double progressValue;
  final double stokevalue;
  final Widget? customWidget;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progressValue),
        duration: const Duration(seconds: 2),
        builder: (context, value, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scaleByDouble(-1.0, 1.0, 1.0, 1.0),
                child: SizedBox(
                  height: size,
                  width: size,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: stokevalue,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.whiteGrey,
                    ),
                  ),
                ),
              ),

              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scaleByDouble(-1.0, 1.0, 1, 1),
                child: SizedBox(
                  height: size,
                  width: size,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: stokevalue,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.mainPrimaryColor,
                    ),
                    backgroundColor: AppColors.transparent,
                  ),
                ),
              ),

              if (title.isNotEmpty)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: CommonText(
                      string: title.isEmpty ? "" : Utils.formatCurrency(title),
                      color: AppColors.mainPrimaryColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (customWidget != null) customWidget ?? SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }
}
