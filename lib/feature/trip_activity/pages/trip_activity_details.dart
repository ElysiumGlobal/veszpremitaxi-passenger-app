import 'package:e_taxi/feature/home/widget/originDestinationTime.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/cacheNetworkImage.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/dotted_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../../../widgets/rating_widget.dart';
import '../model/trip_activity_model.dart';
import '../widget/driver_ration_widget.dart';
import '../widget/support_widget.dart';

class TripActivityDetails extends StatefulWidget {
  const TripActivityDetails({super.key});

  @override
  State<TripActivityDetails> createState() => _TripActivityDetailsState();
}

class _TripActivityDetailsState extends State<TripActivityDetails> {
  Trip? trip;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    trip = Get.arguments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppString.tripActivity.tr,
        centerTitle: false,
      ),
      body: SafeArea(
        bottom: Utils().checkPlatForm,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              containerWidgetTrip(
                Column(
                  children: [
                    Row(
                      children: [
                        NetworkImageWidget(
                          image: trip?.user?.profilePhoto ?? "",
                          ht: 64.w,
                          wt: 64.w,
                          radius: 50.r,
                        ),
                        12.horizontalSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                string: trip?.user?.name ?? "",
                                fontSize: 16.sp,
                                color: AppColors.blackColor,
                              ),
                              2.verticalSpace,

                              RatingBarWidget(
                                selectedIndex: double.parse(
                                  (trip?.user?.rating ?? "0.0").toString(),
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
                            color: getBgColor(trip?.status ?? ""),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: CommonText(
                            string: Utils.tripStatusLabel(trip?.status),
                            fontSize: 14.sp,
                            color: getTextColor(trip?.status ?? ""),
                          ),
                        ),
                      ],
                    ),
                    if (trip?.status == "completed")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          4.verticalSpace,
                          Divider(color: AppColors.textFieldBorderColor),
                          4.verticalSpace,
                          CommonText(
                            string: trip?.user?.comment ?? "",
                            softWrap: true,
                            color: AppColors.blackColor,
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              16.verticalSpace,

              containerWidgetTrip(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      string:
                          "${trip?.bookingCode} | ${Utils().convertFullTime(trip?.createdAt ?? "")}",
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryColor,
                    ),
                    SizedBox(
                      height: 30.h,
                      child: Center(child: DottedWidget()),
                    ),
                    OriginDestinationWidget(
                      destination: trip?.dropoffAddress ?? "",
                      origin: trip?.pickupAddress ?? "",
                      customImage: true,
                      showDotLine: false,
                    ),
                    SizedBox(
                      height: 30.h,
                      child: Center(child: DottedWidget()),
                    ),
                    DriverRatingShowWidget(
                      firstSubTitle: AppString.rideFare.tr,
                      firstTitle: trip?.status == "completed"
                          ? Utils.formatCurrency(
                              "${trip?.financial?.fareBreakdown?.totalAmount ?? ""}",
                            )
                          : Utils.formatCurrency(
                              trip?.financial?.totalFare.toString(),
                            ),
                      secoundSubTitle: AppString.distance.tr,
                      secoundTitle: Utils.formatDistance(trip?.financial?.distance),
                      thirdSubTitle: AppString.tripTime.tr,
                      thirdTitle: Utils.formatDuration(trip?.financial?.duration),
                    ),
                  ],
                ),
              ),

              if (trip?.status == "completed")
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonText(
                      string: AppString.fareDetails.tr,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ).paddingSymmetric(vertical: 12.h),
                    containerWidgetTrip(
                      Column(
                        children: [
                          titlePriceTrip(
                            AppString.baseFare.tr,
                            Utils.formatCurrency(
                              trip?.financial?.fareBreakdown?.baseFare,
                            ),
                          ),
                          titlePriceTrip(
                            AppString.distanceFare.tr,
                            Utils.formatCurrency(
                              trip?.financial?.fareBreakdown?.distanceFare,
                            ),
                          ),
                          titlePriceTrip(
                            AppString.timeFare.tr,
                            Utils.formatCurrency(
                              trip?.financial?.fareBreakdown?.timeFare,
                            ),
                          ),
                          titlePriceTrip(
                            AppString.waitingCharge.tr,
                            Utils.formatCurrency(
                              trip?.financial?.fareBreakdown?.waitingCharge,
                            ),
                          ),
                          titlePriceTrip(
                            AppString.nightCharge.tr,
                            Utils.formatCurrency(
                              trip?.financial?.fareBreakdown?.nightCharge,
                            ),
                          ),
                          titlePriceTrip(
                            AppString.surgeCharge.tr,
                            Utils.formatCurrency(
                              trip?.financial?.fareBreakdown?.surgeAmount,
                            ),
                          ),
                          titlePriceTrip(
                            AppString.taxFare.tr,
                            Utils.formatCurrency(
                              trip?.financial?.fareBreakdown?.taxAmount,
                            ),
                          ),
                          titlePriceTrip(
                            AppString.tipReceived.tr,
                            Utils.formatCurrency(
                              trip?.financial?.fareBreakdown?.tipAmount,
                            ),
                          ),
                          titlePriceTrip(
                            AppString.discountAmount.tr,
                            "${Utils.formatCurrency(trip?.financial?.fareBreakdown?.discountAmount)}",
                          ),

                          Divider(color: AppColors.textFieldBorderColor),
                          titlePriceTrip(
                            AppString.totalFare.tr,
                            Utils.formatCurrency(
                              trip?.financial?.fareBreakdown?.totalAmount,
                            ),
                            size: 16.sp,
                            fontWt: FontWeight.w500,
                          ),
                          Divider(color: AppColors.textFieldBorderColor),
                          8.verticalSpace,
                          titlePriceTrip(
                            AppString.totalTripEarning.tr,
                            Utils.formatCurrency(
                              "${trip?.financial?.fareBreakdown?.driverAmount ?? ""}",
                            ),
                            color: AppColors.successColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              CommonText(
                string: AppString.support.tr,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ).paddingSymmetric(vertical: 12.h),
              containerWidgetTrip(
                rideIndex == 0
                    ? Column(
                        children: [
                          supportWidget(AppString.paymentIssueFare),
                          Divider(
                            color: AppColors.textFieldBorderColor,
                          ).paddingSymmetric(vertical: 4.h),
                          supportWidget(AppString.passengerLeftIteam),
                          Divider(
                            color: AppColors.textFieldBorderColor,
                          ).paddingSymmetric(vertical: 4.h),
                          supportWidget(AppString.otherIssueRelated),
                        ],
                      )
                    : rideIndex == 1
                    ? Column(
                        children: [
                          supportWidget(AppString.cancelDueToEmergency),
                          Divider(
                            color: AppColors.textFieldBorderColor,
                          ).paddingSymmetric(vertical: 4.h),

                          supportWidget(AppString.passengerNotAtPickupLoc),
                          Divider(
                            color: AppColors.textFieldBorderColor,
                          ).paddingSymmetric(vertical: 4.h),

                          supportWidget(AppString.otherIssueRelated),
                        ],
                      )
                    : Column(
                        children: [
                          supportWidget(AppString.passengerCancelAfterArrive),
                          Divider(
                            color: AppColors.textFieldBorderColor,
                          ).paddingSymmetric(vertical: 4.h),

                          supportWidget(AppString.fareOrOtherIssue),
                          Divider(
                            color: AppColors.textFieldBorderColor,
                          ).paddingSymmetric(vertical: 4.h),

                          supportWidget(AppString.otherIssueRelated),
                        ],
                      ),
              ),
            ],
          ).paddingSymmetric(horizontal: 16.w, vertical: 24.h),
        ),
      ),
    );
  }

  int rideIndex = 0;

  Widget supportWidget(String title) {
    return GestureDetector(
      onTap: () {
        Navigation.pushNamed(
          Routes.tripSupportScreen,
          arg: {'trip': trip, "title": title},
        );
      },
      child: Row(
        children: [
          Expanded(
            child: CommonText(
              string: title.tr,
              softWrap: true,
              fontSize: 14.sp,
            ),
          ),
          10.horizontalSpace,
          Icon(Icons.arrow_forward_ios_sharp, size: 16),
        ],
      ),
    );
  }

  Color getTextColor(String value) {
    switch (value) {
      case "completed":
        return AppColors.successColor;
      case "cancelled":
        return AppColors.errorColor;
      default:
        return AppColors.warningColor;
    }
  }

  Color getBgColor(String value) {
    switch (value) {
      case "completed":
        return AppColors.sucessContainer;
      case "cancelled":
        return AppColors.errorBgColor;
      default:
        return AppColors.warningBgColor;
    }
  }
}
