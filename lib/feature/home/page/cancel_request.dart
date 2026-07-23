import 'package:e_taxi/feature/home/controller/home_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/utils.dart';

class CancelRequestScreen extends StatefulWidget {
  const CancelRequestScreen({super.key});

  @override
  State<CancelRequestScreen> createState() => _CancelRequestScreenState();
}

class _CancelRequestScreenState extends State<CancelRequestScreen> {
  RxInt selectedIndex = 0.obs;

  List<String> reasonList = [
    "Waiting for long time",
    "Unable to contact driver",
    "Driver denied to go to destination",
    "Driver denied to come to pickup",
    "Wrong address shown",
    "The Price is not reasonable",
    "Car condition is not good",
    "Other",
  ];
  TextEditingController reasonController = TextEditingController();

  final homeController = Get.find<HomeController>();

  String? rideId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Get.arguments != null) {
      rideId = Get.arguments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      appBar: CustomAppBar(
        title: AppString.cancelRequest.tr,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                string: AppString.reasonForCancel.tr,
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
              27.verticalSpace,

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
                () => selectedIndex.value == (reasonList.length - 1)
                    ? CustomTextField(
                        hintText: AppString.enterYourReason.tr,
                        controller: reasonController,
                      ).paddingOnly(top: 16.h)
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: Utils().checkPlatForm,
        child: Padding(
          padding: EdgeInsets.all(16.w),

          child: CustomButton(
            text: AppString.submit.tr,
            onTap: () {
              String reason = "";

              if (selectedIndex.value == reasonList.length - 1) {
                if (reasonController.text.trim().isEmpty) {
                  AppSnackBar.showErrorSnackBar(
                    message: "Please Enter your reason",
                    isError: true,
                  );
                  return;
                }
                reason = reasonController.text.trim();
              } else {
                reason = reasonList[selectedIndex.value];
              }

              homeController.cancelRide(
                bookingId:
                    rideId ??
                    riderBookingModel.value?.data?.booking?.id ??
                    homeController
                        .bookingCreateModel
                        .value
                        ?.data
                        ?.booking
                        ?.id ??
                    "",
                reason: reason,
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
