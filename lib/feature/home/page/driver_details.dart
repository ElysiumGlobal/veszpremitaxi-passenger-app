import 'package:dotted_line/dotted_line.dart';
import 'package:e_taxi/feature/home/controller/home_controller.dart';
import 'package:e_taxi/feature/home/widget/origin_destination_widget.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/cachenetworkimage.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/location_utils.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../widget/dialog.dart';
import '../widget/driver_ration_widget.dart';

class DriverDetailsScreen extends StatefulWidget {
  const DriverDetailsScreen({super.key});

  @override
  State<DriverDetailsScreen> createState() => _DriverDetailsScreenState();
}

class _DriverDetailsScreenState extends State<DriverDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    RxBool isPop = false.obs;

    final data = riderBookingModel.value?.data;
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      appBar: CustomAppBar(
        title: AppString.driverDetails.tr,
        centerTitle: false,
      ),
      body: PopScope(
        canPop: isPop.value,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop == false) {
            final result = await AppDialog.commonDialog(
              barrierDismissible: false,
              childs: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonText(
                    string: "E-Taxi",
                    fontWeight: FontWeight.w600,
                    fontSize: 26.sp,
                  ),
                  16.verticalSpace,
                  CommonText(
                    string: "Are you sure you want to back",
                    fontSize: 16.sp,
                    softWrap: true,
                  ),
                  24.verticalSpace,
                  CustomButton(
                    text: "NO",
                    onTap: () {
                      Get.back(result: false);
                    },
                  ),
                  16.verticalSpace,
                  CustomButton(
                    text: "Yes",
                    buttonColor: AppColors.transparent,
                    borderColor: AppColors.blackColor,
                    onTap: () {
                      Get.back(result: true);
                    },
                  ),
                ],
              ),
            );
            if (result) {
              isPop.value = true;
              Navigation.replaceAll(Routes.dashboardScreen);
            }
          }
        },
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Row(
                children: [
                  NetworkImageWidget(
                    image: data?.driver?.profilePhoto ?? "",
                    ht: 78.w,
                    wt: 78.w,
                    radius: 100,
                  ),
                  16.horizontalSpace,

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        12.verticalSpace,
                        CommonText(
                          string: data?.driver?.name ?? "",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        8.verticalSpace,
                        CommonText(
                          string: data?.driver?.phone ?? "",
                          fontSize: 14.sp,
                          color: AppColors.bodyText,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              16.verticalSpace,
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: AppColors.whiteColor,
                  border: Border.all(color: AppColors.textFieldBorderColor),
                ),
                child: DriverRatingShowWidget(
                  firstSubTitle: "Rating",
                  firstTitle: data?.driver?.rating ?? "",
                  secoundSubTitle: "Trip",
                  secoundTitle: data?.driver?.totalTrips ?? "",
                  thirdSubTitle: "Rating",
                  thirdTitle: data?.driver?.rating ?? "",
                ),
              ),
              16.verticalSpace,
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: AppColors.whiteColor,
                  border: Border.all(color: AppColors.textFieldBorderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    titleData(
                      title: "Member since",
                      data: data?.driver?.vehicle?.year ?? "",
                    ),
                    SizedBox(
                      height: 15,
                      child: Center(
                        child: DottedLine(
                          direction: Axis.horizontal,
                          lineLength: double.infinity,
                          lineThickness: 2,
                          dashLength: 5,
                          dashColor: AppColors.textFieldBorderColor,
                        ),
                      ),
                    ),
                    titleData(
                      title: "Vehicle Model",
                      data: data?.driver?.vehicle?.model ?? "",
                    ),
                    SizedBox(
                      height: 15,
                      child: Center(
                        child: DottedLine(
                          direction: Axis.horizontal,
                          lineLength: double.infinity,
                          lineThickness: 2,
                          dashLength: 5,
                          dashColor: AppColors.textFieldBorderColor,
                        ),
                      ),
                    ),
                    titleData(
                      title: "Plate number",
                      data: data?.driver?.vehicle?.numberPlate ?? "",
                    ),
                  ],
                ),
              ),
              16.verticalSpace,
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: AppColors.whiteColor,
                  border: Border.all(color: AppColors.textFieldBorderColor),
                ),
                child: OriginDestinationWidget(
                  destination: data?.booking?.dropoffAddress ?? "",
                  origin: data?.booking?.pickupAddress ?? "",
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: Utils().checkPlatForm,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            boxShadow: [
              BoxShadow(
                color: AppColors.blackColor.withValues(alpha: .4),
                offset: Offset(0, -1),
                spreadRadius: 0,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.titleTextColor,
                      ),
                      child: Icon(Icons.close, color: AppColors.whiteColor),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Utils().launchDialer(data?.driver?.phone ?? "");
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.titleTextColor,
                      ),
                      child: Icon(Icons.call, color: AppColors.whiteColor),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigation.pushNamed(
                        Routes.chatScreen,
                        params: {
                          'bookingId':
                              '${riderBookingModel.value?.data?.bookingId}',
                        },
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.titleTextColor,
                      ),
                      child: Icon(Icons.message, color: AppColors.whiteColor),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      String title =
                          "Origin : ${riderBookingModel.value?.data?.pickup?.address ?? ""}\nDetination : ${riderBookingModel.value?.data?.dropoff?.address ?? ""}\n\n";
                      title +=
                          "https://www.google.com/maps/dir/?api=1&origin=${LocationService().currentUserLatLg.value?.latitude ?? riderBookingModel.value?.data?.pickup?.latitude},${LocationService().currentUserLatLg.value?.longitude ?? riderBookingModel.value?.data?.pickup?.longitude}&destination=${riderBookingModel.value?.data?.dropoff?.latitude},${riderBookingModel.value?.data?.dropoff?.longitude}&travelmode=driving";
                      final box = context.findRenderObject() as RenderBox?;

                      SharePlus.instance.share(
                        ShareParams(
                          text: title,
                          sharePositionOrigin:
                              box!.localToGlobal(Offset.zero) & box.size,
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.titleTextColor,
                      ),
                      child: Icon(Icons.share, color: AppColors.whiteColor),
                    ),
                  ),
                ],
              ),
              16.verticalSpace,
              CustomButton(
                text: AppString.continueString.tr,
                onTap: () {
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget titleData({required String title, required String data}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CommonText(string: title, color: AppColors.textCaptionColor),
        CommonText(string: data, fontSize: 14.sp),
      ],
    );
  }
}
