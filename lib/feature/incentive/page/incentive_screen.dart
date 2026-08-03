import 'package:e_taxi/feature/incentive/controller/incentive_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../utils/app_string.dart';
import '../../../utils/assets.dart';
import '../../../utils/utils.dart';
import '../../../widgets/no_data_widget.dart';
import '../../home/widget/progress_widget.dart';
import 'incentive_details.dart';

class IncentiveScreen extends StatefulWidget {
  const IncentiveScreen({super.key});

  @override
  State<IncentiveScreen> createState() => _IncentiveScreenState();
}

class _IncentiveScreenState extends State<IncentiveScreen> {
  int? _todayIndex;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.microtask(() {
      final startDate = DateTime(
        _today.value.year,
        _today.value.month - 1,
        _today.value.day,
      );
      final endDate = DateTime(
        _today.value.year,
        _today.value.month + 1,
        _today.value.day,
      );

      _dateList.value = [];
      for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
        _dateList.add(startDate.add(Duration(days: i)));
      }

      _todayIndex = _dateList.indexWhere(
        (d) =>
            d.year == _today.value.year &&
            d.month == _today.value.month &&
            d.day == _today.value.day,
      );

      _scrollController = ScrollController();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(milliseconds: 700), () {
          if (_todayIndex != -1) {
            _scrollController.animateTo(
              ((_todayIndex ?? 0)) * 66.w,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
            );
          }
        });
      });

      incentiveController.getIncentive(
        date: Utils().serverDesDate(DateTime.now()),
      );
    });
  }

  final incentiveController = Get.put(IncentiveController());

  RxList<DateTime> _dateList = <DateTime>[].obs;
  ScrollController _scrollController = ScrollController();
  Rx<DateTime> _today = DateTime.now().obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(centerTitle: false, title: AppString.incentive.tr),
      body: SafeArea(
        bottom: Utils().checkPlatForm,

        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Obx(
                () => Container(
                  height: 100.h,
                  color: AppColors.whiteColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 24.h,
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: (_dateList).length,
                    itemBuilder: (context, index) {
                      final date = _dateList[index];

                      return Obx(() {
                        bool isToday =
                            date.day == _today.value.day &&
                            date.month == _today.value.month &&
                            date.year == _today.value.year;
                        return GestureDetector(
                          onTap: incentiveController.loading.value
                              ? null
                              : () {
                                  _today.value = date;
                                  _today.refresh();
                                  incentiveController.getIncentive(
                                    date: Utils().serverDesDate(date),
                                  );
                                },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.w),
                            child: AnimatedContainer(
                              key: ValueKey(index),
                              duration: const Duration(milliseconds: 200),
                              width: 60.w,
                              decoration: BoxDecoration(
                                color: isToday
                                    ? AppColors.mainPrimaryColor
                                    : AppColors.whiteGrey,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CommonText(
                                    string: DateFormat('dd').format(date),

                                    fontSize: 18,
                                    fontWeight: isToday
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isToday
                                        ? AppColors.whiteColor
                                        : AppColors.blackColor,
                                  ),
                                  CommonText(
                                    string: DateFormat('MMM').format(date),

                                    color: isToday
                                        ? AppColors.whiteColor
                                        : AppColors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
              ),

              Obx(() {
                return incentiveController.loading.value
                    ? CircularProgressIndicator()
                    : ((incentiveController.liveList).isEmpty &&
                          (incentiveController.upcomingList).isEmpty &&
                          (incentiveController.completedList).isEmpty)
                    ? NoDataWidget(
                        icon: ImagesAsset.noData,
                        title: AppString.noDataAvailable.tr,
                        subTitle: AppString.weNotFindAnything.tr,
                        onTap: () {
                          incentiveController.getIncentive(
                            date: Utils().serverDesDate(DateTime.now()),
                          );
                        },
                      )
                    : Column(
                        children: [
                          Container(
                            height: 52.h,
                            color: AppColors.sucessContainer,
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                16.horizontalSpace,
                                CommonText(
                                  string: AppString.totalIncentiveEarning.tr,
                                  color: AppColors.successColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                Spacer(),
                                CommonText(
                                  string: Utils.formatCurrency(
                                    "${incentiveController.incentiveModel.value?.data?.totalIncentiveEarning ?? "0"}",
                                  ),
                                  color: AppColors.successColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                16.horizontalSpace,
                              ],
                            ),
                          ),
                          16.verticalSpace,
                          if ((incentiveController.liveList).isNotEmpty) ...{
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 16.w),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,

                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.textFieldBorderColor,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.r),
                                      color: AppColors.errorBgColor,
                                    ),
                                    child: CommonText(
                                      string: "Live",
                                      color: AppColors.errorColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  16.verticalSpace,
                                  ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        Divider(
                                          color: AppColors.textFieldBorderColor,
                                        ),
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount:
                                        (incentiveController.liveList).length,
                                    itemBuilder: (context, index) {
                                      final data =
                                          incentiveController.liveList[index];
                                      return GestureDetector(
                                        onTap: () {
                                          Get.to(
                                            () => IncentivDetailsScreen(
                                              data: data,
                                            ),
                                          );
                                        },
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  CommonText(
                                                    string: data.title ?? "",
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 18.sp,
                                                  ),
                                                  2.verticalSpace,
                                                  CommonText(
                                                    string:
                                                        "Teljesíts még ${int.parse(data.progress?.target ?? "0") - (data.progress?.current ?? 0)} fuvart a bónuszért",
                                                    color: AppColors
                                                        .textCaptionColor,
                                                    softWrap: true,
                                                  ),
                                                  8.verticalSpace,
                                                  CommonText(
                                                    string:
                                                        "Ends at ${Utils().convertFullTime(data.timeInfo ?? "")}",
                                                    softWrap: true,
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
                                                    (data
                                                            .progress
                                                            ?.percentage ??
                                                        0) *
                                                    0.01,
                                                customWidget: CommonText(
                                                  string:
                                                      data.progress?.display ??
                                                      "",
                                                  color: AppColors
                                                      .mainPrimaryColor,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          },

                          if ((incentiveController.completedList)
                              .isNotEmpty) ...{
                            Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16.w,
                              ).copyWith(top: 16.h),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.textFieldBorderColor,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.r),
                                      color: AppColors.sucessContainer,
                                    ),
                                    child: CommonText(
                                      string: "Teljesítve",
                                      color: AppColors.successColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  16.verticalSpace,
                                  ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        Divider(
                                          color: AppColors.textFieldBorderColor,
                                        ),
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount:
                                        (incentiveController.completedList)
                                            .length,
                                    itemBuilder: (context, index) {
                                      final data = incentiveController
                                          .completedList[index];
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CommonText(
                                                  string:
                                                      "${data.progress?.target ?? ""} sorozat teljesítve",
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18.sp,
                                                ),

                                                2.verticalSpace,
                                                CommonText(
                                                  string:
                                                      "Earned Bonus ${Utils.formatCurrency(data.rewardAmount ?? '0')}",
                                                  color: AppColors
                                                      .textCaptionColor,
                                                  softWrap: true,
                                                ),
                                                8.verticalSpace,
                                                CommonText(
                                                  string:
                                                      "Teljesítés ideje: ${Utils().convertFullTime(data.timeInfo ?? "")}",
                                                  softWrap: true,
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
                                              progressValue: 1,

                                              customWidget: CommonText(
                                                string:
                                                    "${(data.progress?.percentage ?? 0).clamp(0, 100)}",
                                                color:
                                                    AppColors.mainPrimaryColor,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          },
                          if ((incentiveController.upcomingList)
                              .isNotEmpty) ...{
                            Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16.w,
                              ).copyWith(top: 16.h),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.textFieldBorderColor,
                                ),
                                color: AppColors.whiteColor,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.r),
                                      color: AppColors.warningBgColor,
                                    ),
                                    child: CommonText(
                                      string: "Upcoming",
                                      color: AppColors.warningColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  16.verticalSpace,
                                  ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        Divider(
                                          color: AppColors.textFieldBorderColor,
                                        ),
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount:
                                        (incentiveController.upcomingList)
                                            .length,
                                    itemBuilder: (context, index) {
                                      final data = incentiveController
                                          .upcomingList[index];
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CommonText(
                                                  string: data.title ?? "",
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18.sp,
                                                ),
                                                2.verticalSpace,

                                                CommonText(
                                                  string:
                                                      "Get a ${Utils.formatCurrency(data.rewardAmount ?? "0")} Bonus when you hit your target.",
                                                  color: AppColors
                                                      .textCaptionColor,
                                                  softWrap: true,
                                                ),
                                                8.verticalSpace,
                                                CommonText(
                                                  string:
                                                      "Kezdés ma: ${Utils().convertFullTime(data.timeInfo ?? "")}",
                                                  softWrap: true,
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
                                              title: "${data.rewardAmount}",
                                              progressValue: 0.0,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          },
                        ],
                      );
              }),

              16.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
