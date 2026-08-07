import 'package:dotted_line/dotted_line.dart';
import 'package:e_taxi/feature/home/widget/dialog.dart';
import 'package:e_taxi/feature/home/widget/driver_details_widget.dart';
import 'package:e_taxi/feature/home/widget/driver_ration_widget.dart';
import 'package:e_taxi/feature/home/widget/origin_destination_widget.dart';
import 'package:e_taxi/feature/profile/controller/profile_controller.dart';
import 'package:e_taxi/feature/trip/controller/trip_controller.dart';
import 'package:e_taxi/feature/trip/model/trip_details_model.dart';
import 'package:e_taxi/feature/trip/widget/trip_card_widget.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/assets.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custome_dropdown.dart';

class RideDetailsScreen extends StatefulWidget {
  final String index;

  const RideDetailsScreen({required this.index, super.key});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    index = int.parse(widget.index);
  }

  int index = 0;

  final tripController = Get.find<TripController>();

  final profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      TripHistory tripHistory = tripController.tripHistoryList[index];
      return Scaffold(
        backgroundColor: AppColors.whiteGrey,
        appBar: CustomAppBar(
          title: AppString.rideDetails.tr,
          centerTitle: false,
          actions: [
            if ((tripHistory.tripInfo?.invoice ?? "").isNotEmpty)
              IconButton(
                onPressed: () {
                  Utils().downloadPdf(
                    tripHistory.tripInfo?.invoice ?? "",
                    "${tripHistory.tripInfo?.bookingCode}",
                  );
                },
                icon: Icon(Icons.download),
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TripCardWidget(tripHistory: tripHistory),
                20.verticalSpace,
                CommonText(
                  string: AppString.rideDetails.tr,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
                10.verticalSpace,
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 12.w,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.whiteColor,
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OriginDestinationWidget(
                        destination:
                            tripHistory.locations?.dropoffAddress ?? "",
                        origin: tripHistory.locations?.pickupAddress ?? "",
                        customImage: true,
                        showDotLine: false,
                      ),
                      16.verticalSpace,
                      SizedBox(
                        height: 10,
                        child: DottedLine(
                          direction: Axis.horizontal,
                          lineLength: double.infinity,
                          lineThickness: 2,
                          dashLength: 5,
                          dashColor: AppColors.textFieldBorderColor,
                        ),
                      ),
                      16.verticalSpace,

                      DriverRatingShowWidget(
                        istripList: true,
                        firstSubTitle: AppString.rideFare.tr,
                        firstTitle: Utils.formatCurrency(
                          tripHistory.pricing?.rideFare,
                        ),
                        secoundSubTitle: AppString.distance.tr,
                        secoundTitle:
                            tripHistory.locations?.actualDistance ?? "",
                        thirdSubTitle: AppString.tripTime.tr,
                        thirdTitle:
                            tripHistory.locations?.tripTimeMinutes ?? "",
                      ),
                      if ((tripHistory.pricing?.tipAmount ?? "").isNotEmpty)
                        CommonText(
                          string:
                              "${AppString.tipAmount.tr} : ${Utils.formatCurrency(tripHistory.pricing?.tipAmount ?? "")}",
                          color: AppColors.successColor,
                        ).paddingOnly(left: 18.w, top: 3.h),

                      16.verticalSpace,
                      SizedBox(
                        height: 10,
                        child: DottedLine(
                          direction: Axis.horizontal,
                          lineLength: double.infinity,
                          lineThickness: 2,
                          dashLength: 5,
                          dashColor: AppColors.textFieldBorderColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: DriverDetailsWidget(
                          image: tripHistory.driverInfo?.profilePhoto ?? "",
                          firstText:
                              tripHistory
                                  .driverInfo
                                  ?.vehicle
                                  ?.vehiclePlateNumber ??
                              "",
                          thirdText:
                              tripHistory.driverInfo?.vehicle?.model ?? "",
                          secoundText: tripHistory.driverInfo?.name ?? "",
                          rating: tripHistory.driverInfo?.driverRating ?? "0",
                          // rating: tripHistory.ratings?.userRating,
                          radius: 100,
                        ),
                      ),

                      if (tripHistory.tripInfo?.status == "completed" &&
                          getTime(tripHistory.tripInfo?.completedAt ?? "") &&
                          (tripHistory.refundStatus ?? "").isEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 10,
                              child: DottedLine(
                                direction: Axis.horizontal,
                                lineLength: double.infinity,
                                lineThickness: 2,
                                dashLength: 5,
                                dashColor: AppColors.textFieldBorderColor,
                              ),
                            ).paddingSymmetric(vertical: 16.h),
                            Row(
                              children: [
                                Expanded(
                                  child: CommonText(
                                    string: AppString.doYouWantRefund.tr,
                                    color: AppColors.textCaptionColor,
                                    softWrap: true,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                8.horizontalSpace,
                                GestureDetector(
                                  onTap: () {
                                    AppDialog.commonBottomSheetWidget(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CommonText(
                                              string:
                                                  AppString.refundRequest.tr,
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            16.verticalSpace,
                                            CutomeDropDownButton1(
                                              value: dropDownValue,
                                              hintValue: 'Válassz problémát',
                                              listData: reasonList,
                                              onChange: (event) {
                                                dropDownValue.value =
                                                    event ?? "";
                                              },
                                            ),
                                            16.verticalSpace,
                                            CustomTextField(
                                              title: AppString.message.tr,
                                              controller:
                                                  TextEditingController(),
                                              minLine: 5,
                                              maxLine: 6,
                                              hintText:
                                                  'Írd le röviden a problémát',
                                              textfielHeight: 130.h,
                                              keyboardType: TextInputType.name,
                                              textInputAction:
                                                  TextInputAction.newline,
                                              onChanged: (v) {
                                                msg = v;
                                              },
                                            ),
                                            24.verticalSpace,
                                            CustomButton(
                                              text: AppString.refund.tr,
                                              onTap: () async {
                                                if (dropDownValue
                                                    .value
                                                    .isEmpty) {
                                                  AppSnackBar.showErrorSnackBar(
                                                    message: AppString
                                                        .pleaseSelectReasonRefund
                                                        .tr,
                                                    isError: true,
                                                  );
                                                  return;
                                                }

                                                if (msg.isEmpty) {
                                                  AppSnackBar.showErrorSnackBar(
                                                    message: AppString
                                                        .pleaseEnterReasonRefund
                                                        .tr,
                                                    isError: true,
                                                  );

                                                  return;
                                                }

                                                await tripController
                                                    .refundReqSend(
                                                      bookingId:
                                                          tripHistory
                                                              .tripInfo
                                                              ?.id ??
                                                          "",
                                                      reason:
                                                          dropDownValue.value,
                                                      des: msg,
                                                      index: int.parse(
                                                        widget.index,
                                                      ),
                                                    );
                                              },
                                            ),
                                            16.verticalSpace,
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.r),
                                      color: AppColors.mainPrimaryColor,
                                    ),
                                    child: CommonText(
                                      string: AppString.refund.tr,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                if ((tripHistory.refundStatus ?? "") == "pending" ||
                    (tripHistory.refundStatus ?? "") == "rejected")
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        string: AppString.refund.tr,
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                      ).paddingSymmetric(vertical: 16.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.textFieldBorderColor,
                          ),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                              string: AppString.refundStatus.tr,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            4.verticalSpace,
                            CommonText(
                              string: AppString.trackProgressRefund.tr,
                              softWrap: true,
                              color: AppColors.textCaptionColor,
                            ),
                            16.verticalSpace,
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      color: AppColors.warningBgColor,
                                    ),
                                    alignment: Alignment.center,
                                    child: CommonText(
                                      string: tripHistory.refundStatus ?? "",
                                      color: AppColors.warningColor,
                                    ),
                                  ),
                                ),
                                16.horizontalSpace,
                                GestureDetector(
                                  onTap: () {
                                    Navigation.pushNamed(
                                      Routes.chatSupportScreen,
                                      params: {
                                        "bookingId":
                                            '${tripHistory.tripInfo?.id}',
                                        "title": "Visszatérítés",
                                      },
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
                                    child: CustomImage(
                                      image: IconAsset.message,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                if (tripHistory.tripInfo?.status != "expired")
                  CommonText(
                    string: AppString.support.tr,
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp,
                  ).paddingSymmetric(vertical: 16.h),
                if (tripHistory.tripInfo?.status != "expired")
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 12.w,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigation.pushNamed(
                              Routes.chatSupportScreen,
                              params: {
                                "bookingId": '${tripHistory.tripInfo?.id}',
                                "title": 'Promóciós probléma',
                              },
                            );
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Row(
                            children: [
                              Expanded(
                                child: CommonText(
                                  string: AppString.notReceivePromoDis.tr,
                                  softWrap: true,
                                  fontSize: 14.sp,
                                ),
                              ),
                              10.horizontalSpace,
                              Icon(Icons.arrow_forward_ios_sharp, size: 18),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 16.w),
                          height: 1,
                          width: double.infinity,
                          color: AppColors.textFieldBorderColor,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigation.pushNamed(
                              Routes.chatSupportScreen,
                              params: {
                                "bookingId": '${tripHistory.tripInfo?.id}',
                                "title": 'A sofőr hosszabb útvonalon ment',
                              },
                            );
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Row(
                            children: [
                              Expanded(
                                child: CommonText(
                                  string: AppString.driverTookLongRoute.tr,
                                  softWrap: true,
                                  fontSize: 14.sp,
                                ),
                              ),
                              10.horizontalSpace,
                              Icon(Icons.arrow_forward_ios_sharp, size: 18),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 16.w),
                          height: 1,
                          width: double.infinity,
                          color: AppColors.textFieldBorderColor,
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigation.pushNamed(
                              Routes.chatSupportScreen,
                              params: {
                                "bookingId": '${tripHistory.tripInfo?.id}',
                                "title": 'Valamit az autóban hagytam',
                              },
                            );
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Row(
                            children: [
                              Expanded(
                                child: CommonText(
                                  string: AppString.leftSomthingInCab.tr,
                                  softWrap: true,
                                  fontSize: 14.sp,
                                ),
                              ),
                              10.horizontalSpace,
                              Icon(Icons.arrow_forward_ios_sharp, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        bottomNavigationBar:
            ((tripHistory.tripInfo?.status ?? "") != "completed" &&
                (tripHistory.tripInfo?.status ?? "") != "cancelled" &&
                (tripHistory.tripInfo?.status ?? "") != "expired")
            ? SafeArea(
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
                  child: CustomButton(
                    text: AppString.cancelRide.tr,
                    onTap: () {
                      Navigation.pushNamed(
                        Routes.cancelRequestScreen,
                        arg: tripHistory.tripInfo?.id,
                      );
                    },
                  ),
                ),
              )
            : SafeArea(bottom: Utils().checkPlatForm, child: SizedBox.shrink()),
      );
    });
  }

  bool getTime(String time) {
    if (time.isEmpty) {
      return false;
    }
    DateTime dateTime = DateTime.parse(time);
    DateTime now = DateTime.now().toUtc(); // convert to UTC to match 'Z'

    Duration diff = now.difference(dateTime);

    return diff.inHours <=
        int.parse(profileController.userModel.value?.refundTime ?? "24");
  }

  List<String> reasonList = [
    'A sofőr nem érkezett meg',
    'A sofőr lemondta a fuvart',
    'A sofőr nem megfelelő útvonalon ment',
    'A fuvar nem megfelelően fejeződött be',
  ];
  RxString dropDownValue = "".obs;

  String msg = "";
}
