import 'package:e_taxi/feature/home/controller/home_controller.dart';
import 'package:e_taxi/feature/home/pages/home_screen.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_string.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfeild.dart';

class CancelRequestscreen extends StatefulWidget {
  const CancelRequestscreen({super.key});

  @override
  State<CancelRequestscreen> createState() => _CancelRequestscreenState();
}

class _CancelRequestscreenState extends State<CancelRequestscreen> {
  List<String> reasonList = [
    "Az utas nem jelent meg",
    "Hibás felvételi pont",
    "Útlezárás vagy forgalmi probléma",
    "Az utas túl sokat késik",
    "Biztonsági ok",
    "Egyéb",
  ];

  RxInt selectedIndex = 0.obs;

  final homeController = Get.find<HomeController>();
  TextEditingController reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppString.cancelRequest.tr,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              string: AppString.plzSelectForCancelReason.tr,
              fontWeight: FontWeight.w500,
              color: AppColors.blackColor,
            ),
            Divider(color: AppColors.textFieldBorderColor),
            16.verticalSpace,

            ListView.separated(
              separatorBuilder: (context, index) => 21.verticalSpace,
              shrinkWrap: true,
              itemCount: reasonList.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final data = reasonList[index];
                return Obx(
                  () => checkBoxWidget(
                    onTap: () {
                      selectedIndex.value = index;
                    },
                    title: data,
                    isSelected: selectedIndex.value == index,
                  ),
                );
              },
            ),

            Obx(
              () => selectedIndex.value == reasonList.length - 1
                  ? CustomTextField(
                      hintText: AppString.enterYourReason.tr,
                      controller: reasonController,
                    )
                  : SizedBox.shrink(),
            ),
          ],
        ),
      ).paddingAll(16.w),
      bottomNavigationBar: SafeArea(
        bottom: Utils().checkPlatForm,

        child: Padding(
          padding: EdgeInsets.all(16.w),

          child: CustomButton(
            text: AppString.submit.tr,
            onTap: () async {
              String reason = reasonList[selectedIndex.value];

              if (selectedIndex.value == reasonList.length - 1) {
                if (reasonController.text.trim().isEmpty) {
                  AppSnackBar.showErrorSnackBar(
                    message: AppString.pleaseSelectCancelReason.tr,
                    isError: true,
                  );
                  return;
                }
                reason = reasonController.text.trim();
              }

              AppDialog.commonDialog(
                childs: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CommonText(
                      string: AppString.cancelTrip.tr,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    16.verticalSpace,
                    CommonText(
                      string:
                          "A fuvar lemondásakor ${Utils.formatCurrency("${rideDataModel.value?.booking?.cancelCharge ?? ""}")} lemondási díj számítható fel. Biztosan folytatod?",
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                    16.verticalSpace,
                    CustomButton(
                      text: AppString.goAhead.tr,
                      onTap: () async {
                        Get.back();
                        await homeController.updateBookingRideStatus(
                          bookingId: (rideDataModel.value?.bookingId ?? "")
                              .toString(),
                          statusNo: 5,
                          dropLatLng: LatLng(
                            double.parse(
                              rideDataModel.value?.dropoff?.latitude ?? "0",
                            ),
                            double.parse(
                              rideDataModel.value?.dropoff?.longitude ?? "0",
                            ),
                          ),
                          dropAddress:
                              rideDataModel.value?.dropoff?.address ?? "",
                          cancelReason: reason,
                        );
                      },
                    ),
                    12.verticalSpace,
                    CustomButton(
                      buttonColor: AppColors.whiteColor,
                      borderColor: AppColors.mainPrimaryColor,
                      text: AppString.goBack.tr,
                      onTap: () {
                        Get.back();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget checkBoxWidget({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            height: 24.h,
            width: 24.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.r),
              color: isSelected ? AppColors.greenColor : AppColors.whiteColor,
              border: Border.all(
                color: isSelected
                    ? AppColors.transparent
                    : AppColors.titleTextColor,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.done, size: 12, color: AppColors.whiteColor),
          ),
          12.horizontalSpace,
          CommonText(string: title, fontSize: 14.sp),
        ],
      ),
    );
  }
}
