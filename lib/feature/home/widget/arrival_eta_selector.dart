import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ArrivalEtaSelector extends StatelessWidget {
  const ArrivalEtaSelector({
    super.key,
    required this.selectedMinutes,
    this.compact = false,
  });

  final RxInt selectedMinutes;
  final bool compact;

  static const List<int> values = <int>[10, 12, 15, 20, 25, 30];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: compact ? 12.h : 18.h),
      padding: EdgeInsets.all(compact ? 12.w : 14.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.textFieldBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CommonText(
            string: 'Mennyi idő alatt érsz az utashoz?',
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.titleTextColor,
          ),
          4.verticalSpace,
          CommonText(
            string: 'A fuvar elfogadásához válassz várható érkezést.',
            fontSize: 12.sp,
            color: AppColors.bodyText,
            softWrap: true,
          ),
          12.verticalSpace,
          Obx(
            () => Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: values.map((int minute) {
                final bool selected = selectedMinutes.value == minute;
                return InkWell(
                  borderRadius: BorderRadius.circular(12.r),
                  onTap: () => selectedMinutes.value = minute,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: compact ? 58.w : 64.w,
                    padding: EdgeInsets.symmetric(vertical: 11.h),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.mainPrimaryColor
                          : AppColors.whiteGrey,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: selected
                            ? AppColors.mainPrimaryColor
                            : AppColors.textFieldBorderColor,
                        width: selected ? 1.6 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CommonText(
                          string: '$minute',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.titleTextColor,
                          textAlign: TextAlign.center,
                        ),
                        CommonText(
                          string: 'perc',
                          fontSize: 11.sp,
                          color: AppColors.bodyText,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
