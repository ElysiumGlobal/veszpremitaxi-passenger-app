import 'dart:io';

import 'package:e_taxi/feature/trip_activity/controller/trip_activity_controller.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/utils.dart';
import '../../../widgets/dotted_widget.dart';
import '../../home/widget/originDestinationTime.dart';
import '../model/trip_activity_model.dart';
import '../widget/driver_ration_widget.dart';
import '../widget/support_widget.dart';

class TripSupportScreen extends StatefulWidget {
  const TripSupportScreen({super.key});

  @override
  State<TripSupportScreen> createState() => _TripSupportScreenState();
}

class _TripSupportScreenState extends State<TripSupportScreen> {
  Trip? trip;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Get.arguments != null) {
      Map data = Get
          .arguments;
      trip = data['trip'];
      reason = data['title'];
    }
  }

  String reason = "";

  RxList<XFile> imageList = <XFile>[].obs;

  final tripController = Get.find<TripController>();
  TextEditingController msgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppString.tripSupport.tr, centerTitle: false),
      body: SafeArea(
        bottom: Utils().checkPlatForm,

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      firstTitle: Utils.formatCurrency(trip?.financial?.totalFare?.toString()),
                      secoundSubTitle: AppString.distance.tr,
                      secoundTitle: Utils.formatDistance(trip?.financial?.distance),
                      thirdSubTitle: AppString.tripTime.tr,
                      thirdTitle: Utils.formatDuration(trip?.financial?.duration),
                    ),
                  ],
                ),
              ),

              27.verticalSpace,
              containerWidgetTrip(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    CommonText(
                      string: reason.tr,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                    Divider(color: AppColors.textFieldBorderColor),
                    16.verticalSpace,

                    CustomTextField(
                      title: AppString.describeDetails.tr,
                      hintText: "Írd le röviden, mi történt a fuvar során…",

                      controller: msgController,
                    ),
                  ],
                ),
              ),

              27.verticalSpace,

              containerWidgetTrip(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    CommonText(
                      string: AppString.uploadScreenshot.tr,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),

                    16.verticalSpace,

                    Obx(
                      () => imageList.isEmpty
                          ? SizedBox.shrink()
                          : SizedBox(
                              height: 116.h,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.only(bottom: 16.h),
                                itemBuilder: (context, index) {
                                  return Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Image.file(
                                        (File(imageList[index].path)),
                                        height: 100.h,
                                        width: 110.w,
                                        fit: BoxFit.cover,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          imageList.removeAt(index);
                                        },
                                        child: Container(
                                          height: 24.w,
                                          width: 24.w,
                                          decoration: BoxDecoration(
                                            color: AppColors.whiteColor,
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: CustomImage(
                                            image: IconAsset.close,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return 16.horizontalSpace;
                                },
                                itemCount: imageList.length,
                              ),
                            ),
                    ),

                    CustomButton(
                      buttonColor: AppColors.textFieldBorderColor,
                      text: AppString.uploadFile.tr,
                      prefixIconWidget: CustomImage(
                        image: IconAsset.add,
                        ht: 20.h,
                        wt: 20.h,
                      ).paddingOnly(right: 4.w),
                      onTap: () async {
                        if (imageList.length <= 3) {
                          XFile? image = await Utils().getImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            imageList.add(image);
                            imageList.refresh();
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ).paddingSymmetric(horizontal: 16.w, vertical: 24.h),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: CustomButton(
          text: AppString.submitTicket.tr,
          onTap: () async {
            if (msgController.text.trim().isEmpty) {
              AppSnackBar.showErrorSnackBar(
                message: "Írd le a probléma okát.",
                isError: true,
              );
              return;
            }

            final res = await tripController.tripSupportTicket(
              bookingId: (trip?.id ?? "").toString(),
              imageList: imageList.map((element) => element.path).toList(),
              msg: msgController.text.trim(),
              subject: reason,
            );

            if (res.isNotEmpty) {
              Get.back();
              Get.back();
              AppSnackBar.showErrorSnackBar(message: res['message']);
            }
          },
        ).paddingOnly(left: 16.w, right: 16.w, bottom: 24.h),
      ),
    );
  }

  Widget containerWidget(Widget child) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.textFieldBorderColor),
        color: AppColors.whiteColor,
      ),
      child: child,
    );
  }
}
