import 'package:e_taxi/feature/account/controller/account_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../utils/app_string.dart';
import '../../../utils/assets.dart';
import '../../../utils/utils.dart';
import '../../../widgets/cacheNetworkImage.dart';
import '../../../widgets/driver_ride_overView.dart';
import '../../../widgets/no_data_widget.dart';
import '../../../widgets/rating_widget.dart';

class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    accountController.getPerformanceData();
  }

  final accountController = Get.find<AccountController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerTitle: false,
        title: AppString.myPerformance.tr,
      ),
      body: SafeArea(
        bottom: Utils().checkPlatForm,

        child: Obx(
          () => accountController.performanceLoading.value
              ? Skeletonizer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 130.h,
                        width: double.maxFinite,
                        color: AppColors.whiteColor,
                      ),

                      CommonText(
                        string: "Last 20 Order",
                      ).paddingSymmetric(vertical: 16.h),
                      Container(
                        height: 130.h,
                        width: double.maxFinite,
                        color: AppColors.whiteColor,
                      ),
                      CommonText(
                        string: "Utasértékelés ",
                      ).paddingSymmetric(vertical: 16.h),
                      Container(
                        height: 150.h,
                        width: double.maxFinite,
                        color: AppColors.whiteColor,
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DriverRideOverviewWidget(
                            bgColor: AppColors.whiteColor,
                            timeOnline:
                                accountController
                                    .performerModel
                                    .value
                                    ?.data
                                    ?.allTimePerformance
                                    ?.timeOnlineHrs ??
                                "0",
                            totalRide:
                                accountController
                                    .performerModel
                                    .value
                                    ?.data
                                    ?.allTimePerformance
                                    ?.totalRides ??
                                "0",
                            complete:
                                accountController
                                    .performerModel
                                    .value
                                    ?.data
                                    ?.allTimePerformance
                                    ?.completedRides ??
                                "0",
                            completeRate:
                                accountController
                                    .performerModel
                                    .value
                                    ?.data
                                    ?.allTimePerformance
                                    ?.completionRate ??
                                "0",
                            avgRating:
                                accountController
                                    .performerModel
                                    .value
                                    ?.data
                                    ?.allTimePerformance
                                    ?.avgRating ??
                                "0",
                          ),
                          CommonText(
                            string: "Last 20 Order",
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ).paddingSymmetric(vertical: 16.h),
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              color: AppColors.whiteColor,
                              border: Border.all(
                                color: AppColors.textFieldBorderColor,
                              ),
                            ),
                            child: Column(
                              children: [
                                CCRARWidget(
                                  complete:
                                      accountController
                                          .performerModel
                                          .value
                                          ?.data
                                          ?.last20Orders
                                          ?.completed ??
                                      "0",
                                  completeRate:
                                      accountController
                                          .performerModel
                                          .value
                                          ?.data
                                          ?.last20Orders
                                          ?.completionRate ??
                                      "0",
                                  avgRating:
                                      accountController
                                          .performerModel
                                          .value
                                          ?.data
                                          ?.last20Orders
                                          ?.avgRating ??
                                      "0",
                                ),
                                Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      height: 16.h,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppColors.textFieldBorderColor,
                                        borderRadius: BorderRadius.circular(
                                          24.r,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                          height: 24.h,
                                          width: 24.h,
                                          decoration: BoxDecoration(
                                            color:
                                                nameList.first ==
                                                    (accountController
                                                            .performerModel
                                                            .value
                                                            ?.data
                                                            ?.last20Orders
                                                            ?.performanceIndicator
                                                            ?.category ??
                                                        "")
                                                ? AppColors.mainPrimaryColor
                                                : AppColors
                                                      .textFieldBorderColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Container(
                                          height: 24.h,
                                          width: 24.h,
                                          decoration: BoxDecoration(
                                            color:
                                                nameList[1] ==
                                                    (accountController
                                                            .performerModel
                                                            .value
                                                            ?.data
                                                            ?.last20Orders
                                                            ?.performanceIndicator
                                                            ?.category ??
                                                        "")
                                                ? AppColors.mainPrimaryColor
                                                : AppColors
                                                      .textFieldBorderColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Container(
                                          height: 24.h,
                                          width: 24.h,
                                          decoration: BoxDecoration(
                                            color:
                                                nameList[2] ==
                                                    (accountController
                                                            .performerModel
                                                            .value
                                                            ?.data
                                                            ?.last20Orders
                                                            ?.performanceIndicator
                                                            ?.category ??
                                                        "")
                                                ? AppColors.mainPrimaryColor
                                                : AppColors
                                                      .textFieldBorderColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ).paddingSymmetric(vertical: 16.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TitleSubTitle1612(
                                        title: "0-9",
                                        body: AppString.bad.tr,
                                      ),
                                    ),
                                    VerticalDivider(
                                      color: AppColors.textFieldBorderColor,
                                    ),
                                    Expanded(
                                      child: TitleSubTitle1612(
                                        title: "10-15",
                                        body: AppString.avgRating.tr,
                                      ),
                                    ),
                                    VerticalDivider(
                                      color: AppColors.textFieldBorderColor,
                                    ),
                                    Expanded(
                                      child: TitleSubTitle1612(
                                        title: "16-20",
                                        body: AppString.good.tr,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          CommonText(
                            string: AppString.riderReview.tr,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ).paddingSymmetric(vertical: 16.h),
                        ],
                      ),
                    ),
                    (accountController
                                    .performerModel
                                    .value
                                    ?.data
                                    ?.riderReviews ??
                                [])
                            .isNotEmpty
                        ? SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final data = accountController
                                    .performerModel
                                    .value
                                    ?.data
                                    ?.riderReviews?[index];
                                return Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: AppColors.textFieldBorderColor,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          NetworkImageWidget(
                                            image:
                                                data?.rider?.profilePhoto ?? "",
                                            ht: 64.w,
                                            wt: 64.w,
                                            radius: 50.r,
                                          ),
                                          12.horizontalSpace,
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CommonText(
                                                  string:
                                                      data?.rider?.name ?? '',
                                                  fontSize: 16.sp,
                                                  color: AppColors.blackColor,
                                                ),
                                                2.verticalSpace,

                                                RatingBarWidget(
                                                  selectedIndex: double.parse(
                                                    "${data?.rating ?? '0.0'}",
                                                  ).toInt(),
                                                  onTap: (index) {},
                                                ),
                                              ],
                                            ),
                                          ),
                                          12.horizontalSpace,
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                              vertical: 4.w,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                            ),
                                            child: CommonText(
                                              string: data?.reviewedAt ?? "",
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          4.verticalSpace,
                                          Divider(
                                            color:
                                                AppColors.textFieldBorderColor,
                                          ),

                                          if ((data?.tags ?? []).isNotEmpty)
                                            Wrap(
                                              runSpacing: 8.w,
                                              spacing: 8.w,
                                              children: List.generate(
                                                (data?.tags ?? []).length,
                                                (index) {
                                                  return Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 8.w,
                                                          vertical: 4.w,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: AppColors
                                                            .textFieldBorderColor,
                                                      ),
                                                      color:
                                                          AppColors.whiteGrey,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4.r,
                                                          ),
                                                    ),
                                                    child: CommonText(
                                                      string: "polite",
                                                      fontSize: 12.sp,
                                                      color:
                                                          AppColors.blackColor,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ).paddingOnly(top: 4.h),
                                          4.verticalSpace,
                                          CommonText(
                                            string: data?.reviewText ?? "",
                                            softWrap: true,
                                            color: AppColors.blackColor,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                              childCount:
                                  (accountController
                                              .performerModel
                                              .value
                                              ?.data
                                              ?.riderReviews ??
                                          [])
                                      .length,
                            ),
                          )
                        : SliverToBoxAdapter(
                            child: NoDataWidget(
                              icon: ImagesAsset.noData,
                              title: AppString.noDataAvailable.tr,
                              subTitle: AppString.weNotFindAnything.tr,
                              onTap: () {
                                accountController.getPerformanceData();
                              },
                            ),
                          ),
                  ],
                ),
        ).paddingAll(16.w),
      ),
    );
  }

  final List<String> nameList = ['bad', 'avarage', 'good'];
}
