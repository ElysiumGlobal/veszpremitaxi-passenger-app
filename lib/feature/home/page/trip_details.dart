import 'package:e_taxi/feature/home/controller/home_controller.dart';
import 'package:e_taxi/feature/home/widget/origin_destination_widget.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/log_utils.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({super.key});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      isCoupanApplied.value =
          (riderBookingModel.value?.data?.booking?.promoCode ?? "").isNotEmpty;
    });
  }

  RxBool isCoupanApplied = true.obs;

  final homeController = Get.find<HomeController>();

  TextEditingController promoCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      appBar: CustomAppBar(title: AppString.tripDetails.tr, centerTitle: false),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: AppColors.whiteColor,
                ),
                child: OriginDestinationWidget(
                  destination:
                      riderBookingModel.value?.data?.booking?.dropoffAddress ??
                      "",
                  origin:
                      riderBookingModel.value?.data?.booking?.pickupAddress ??
                      "",
                ),
              ),

              Obx(
                () => isCoupanApplied.value
                    ? Container(
                        padding: EdgeInsets.all(12.w),
                        margin: EdgeInsets.only(top: 16.h),

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          color: AppColors.whiteColor,
                          border: Border.all(
                            color: AppColors.textFieldBorderColor,
                          ),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomImage(
                                  image: IconAsset.tag,
                                  ht: 22.w,
                                  wt: 22.w,
                                ),
                                8.horizontalSpace,
                                CommonText(
                                  string: AppString.appliedCoupon.tr,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.sp,
                                ),
                              ],
                            ),
                            Divider(color: AppColors.textFieldBorderColor),

                            isCoupanApplied.value
                                ? Row(
                                    children: [
                                      CustomImage(image: IconAsset.paymentDone),
                                      8.horizontalSpace,
                                      CommonText(
                                        string:
                                            "Coupon code applied '${riderBookingModel.value?.data?.booking?.promoCode ?? ""}'",
                                        color: AppColors.successColor,
                                      ),

                                      3.horizontalSpace,
                                    ],
                                  ).paddingOnly(top: 6.h)
                                : SizedBox.shrink(),
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
              ),
              16.verticalSpace,
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textFieldBorderColor),
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      string: AppString.totalAmount.tr,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                    ),
                    Divider(color: AppColors.textFieldBorderColor),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonText(
                          string: AppString.rideAmount.tr,
                          fontSize: 14.sp,
                        ),
                        CommonText(
                          string: Utils.formatCurrency(resolveRideAmount()),
                          fontSize: 14.sp,
                        ),
                      ],
                    ),

                    Obx(
                      () => isCoupanApplied.value
                          ? Row(
                              children: [
                                CommonText(
                                  string: AppString.coupon.tr,
                                  fontSize: 14.sp,
                                ),
                                Container(
                                  margin: EdgeInsetsGeometry.symmetric(
                                    horizontal: 5.w,
                                  ),
                                  height: 10,
                                  width: 1,
                                  color: AppColors.titleTextColor,
                                ),
                                CommonText(
                                  string:
                                      riderBookingModel
                                          .value
                                          ?.data
                                          ?.booking
                                          ?.promoCode
                                          .toString() ??
                                      "",
                                  fontWeight: FontWeight.w500,
                                ),
                                Spacer(),
                                CommonText(
                                  string:
                                      "-${Utils.formatCurrency(riderBookingModel.value?.data?.booking?.discountAmount ?? '0')}",
                                  fontSize: 14.sp,
                                  color: AppColors.mainPrimaryColor,
                                ),
                              ],
                            ).paddingOnly(top: 4.h)
                          : SizedBox.shrink(),
                    ),
                    Divider(color: AppColors.textFieldBorderColor),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonText(
                          string: AppString.total.tr,
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                        ),
                        CommonText(
                          string: Utils.formatCurrency(resolveTotalAmount()),
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              16.verticalSpace,
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textFieldBorderColor),
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      string: AppString.paymentMethod.tr,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    Divider(color: AppColors.textFieldBorderColor),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => CommonText(
                            string:
                                riderBookingModel
                                    .value
                                    ?.data
                                    ?.booking
                                    ?.paymentMethod ??
                                "",
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            String? getData = await Navigation.pushNamed(
                              Routes.paymentSelectScreen,
                              arg: {
                                'paymentSelection': true,
                                "amount": resolveTotalAmount(),
                                "bookingId":
                                    riderBookingModel
                                        .value
                                        ?.data
                                        ?.booking
                                        ?.id ??
                                    "0",
                                "method":
                                    riderBookingModel
                                        .value
                                        ?.data
                                        ?.booking
                                        ?.paymentMethod ??
                                    "",
                              },
                            );
                            if (getData != null) {
                              LogUtils.printAction("GetDATA:::::$getData");
                              riderBookingModel.value?.data?.booking =
                                  riderBookingModel.value?.data?.booking
                                      ?.copyWith(paymentMethod: getData);
                              riderBookingModel.refresh();
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.w,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.mainPrimaryColor,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: CommonText(string: AppString.change.tr),
                          ),
                        ),
                      ],
                    ),
                  ],
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
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Utils().launchDialer(
                    riderBookingModel.value?.data?.driver?.phone ?? "",
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.w,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: AppColors.mainPrimaryColor,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.call, color: AppColors.titleTextColor),
                      10.horizontalSpace,
                      CommonText(string: AppString.call.tr),
                    ],
                  ),
                ),
              ),
              22.horizontalSpace,
              Expanded(
                child: CustomButton(
                  text: AppString.cancelRequest.tr,
                  borderColor: AppColors.errorColor,
                  buttonColor: AppColors.warningBgColor,
                  textColor: AppColors.errorColor,
                  onTap: () {
                    Navigation.pushNamed(Routes.cancelRequestScreen);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
