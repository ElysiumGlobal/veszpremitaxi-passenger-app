import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_string.dart';
import '../../../utils/assets.dart';
import '../../../utils/utils.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/custome_img.dart';
import '../../home/widget/progress_widget.dart';
import '../model/incentive_model.dart';

class IncentivDetailsScreen extends StatefulWidget {
  IncentivDetailsScreen({required this.data, super.key});

  final Incentive? data;

  @override
  State<IncentivDetailsScreen> createState() => _IncentivDetailsScreenState();
}

class _IncentivDetailsScreenState extends State<IncentivDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(centerTitle: false, title: AppString.incentive.tr),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,

                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.textFieldBorderColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          string: widget.data?.title ?? "",
                          fontWeight: FontWeight.w600,
                          fontSize: 18.sp,
                        ),
                        2.verticalSpace,
                        CommonText(
                          string:
                              "Teljesíts még ${int.parse(widget.data?.progress?.target ?? "0") - (widget.data?.progress?.current ?? 0)} fuvart a bónuszért",
                          color: AppColors.textCaptionColor,
                          softWrap: true,
                        ),
                        8.verticalSpace,
                        CommonText(
                          string:
                              "Ends at ${Utils().convertFullTime(widget.data?.timeInfo ?? "")}",
                        ),
                      ],
                    ),
                  ),
                  10.horizontalSpace,
                  Container(
                    height: 72.w,
                    width: 72.w,
                    child: CustomCircularProgress(
                      stokevalue: 4,
                      size: 70.w,
                      title: "",
                      progressValue:
                          (widget.data?.progress?.percentage ?? 0) * 0.01,
                      customWidget: CommonText(
                        string: widget.data?.progress?.display ?? "",
                        color: AppColors.mainPrimaryColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            16.verticalSpace,

            ...(widget.data?.milestones ?? []).map((e) {
              return Container(
                margin: EdgeInsets.only(bottom: 16.h),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),

                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.textFieldBorderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 40.h,
                      width: 40.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        color: AppColors.whiteGrey,
                      ),
                      alignment: Alignment.center,
                      child: CustomImage(
                        image: e.achieved == true
                            ? IconAsset.right
                            : ImagesAsset.drivingCar,
                        ht: 24.h,
                        wt: 24.h,
                        color: AppColors.blackColor,
                      ),
                    ),
                    16.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(
                            string: e.title ?? "",
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                          ),
                          CommonText(
                            string: e.achieved == true
                                ? "Teljesítve"
                                : "${e.title ?? ""}",
                            color: e.achieved == true
                                ? AppColors.successColor
                                : AppColors.errorColor,
                          ),
                        ],
                      ),
                    ),
                    16.horizontalSpace,
                    CommonText(
                      string: "+${Utils.formatCurrency("${e.reward}")}",
                      color: e.achieved == true
                          ? AppColors.successColor
                          : AppColors.hintTextColor,
                    ),
                  ],
                ),
              );
            }),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,

                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.textFieldBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    string: "Incentive Guidelines:",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  16.verticalSpace,
                  titleShow(
                    "A bónusz számításába csak a befejezett, nem lemondott és nem elutasított fuvarok számítanak bele.",
                  ),
                  16.verticalSpace,
                  titleShow(
                    "A jogosultsághoz a fuvarokat a megadott időszakban kell teljesíteni.",
                  ),
                  16.verticalSpace,
                  titleShow(
                    "Only rides from eligible zones/cities will be counted.",
                  ),
                  16.verticalSpace,
                  titleShow(
                    "Incentives are earned by achieving specific milestones",
                  ),
                  16.verticalSpace,
                ],
              ),
            ),
          ],
        ),
      ).paddingAll(16.w),
    );
  }

  Widget titleShow(String title) {
    return Row(
      children: [
        Container(
          height: 10.h,
          width: 10.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.mainPrimaryColor,
          ),
        ),
        8.horizontalSpace,
        Expanded(
          child: CommonText(
            string: title,
            softWrap: true,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
