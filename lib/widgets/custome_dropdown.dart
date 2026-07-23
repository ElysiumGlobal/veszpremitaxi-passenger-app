import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';
import 'common_text.dart';

class CutomeDropDownButton1 extends StatelessWidget {
  const CutomeDropDownButton1({
    super.key,
    required this.hintValue,
    required this.value,
    required this.listData,
    required this.onChange,
  });

  final RxString value;
  final String hintValue;
  final List listData;
  final Function(String? event) onChange;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        customButton: Container(
          height: 56.h, //47.h
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: AppColors.textFieldBorderColor),
            color: AppColors.whiteColor,
          ),
          padding: EdgeInsets.only(
            top: 8.h,
            bottom: 8.h,
            left: 14.w,
            right: 10.w,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Obx(
                  () => CommonText(
                    string: value.value.isEmpty ? hintValue : value.value,
                    color: value.value.isEmpty
                        ? AppColors.hintTextColor
                        : AppColors.titleTextColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.blackColor,
                size: 24.h,
              ),
            ],
          ),
        ),
        items: List.generate(
          listData.length,
          (index) => DropdownMenuItem<String>(
            value: listData[index],
            child: Container(
              width: double.maxFinite,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.textFieldBorderColor),
                ),
              ),
              child: CommonText(
                string: listData[index],
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimaryColor,
                overflow: TextOverflow.ellipsis,
              ).paddingOnly(bottom: 10.h),
            ),
          ),
        ),
        onChanged: onChange,
        dropdownStyleData: DropdownStyleData(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: AppColors.whiteColor,
            border: Border.all(color: AppColors.textFieldBorderColor),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
