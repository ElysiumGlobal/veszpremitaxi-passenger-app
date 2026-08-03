import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/utils.dart';
import '../../../widgets/custome_switch.dart';

class DriverPreference extends StatefulWidget {
  const DriverPreference({super.key});

  @override
  State<DriverPreference> createState() => _DriverPreferenceState();
}

class _DriverPreferenceState extends State<DriverPreference> {
  RxBool acceptCash = false.obs;
  RxBool autoAcceptRide = false.obs;
  RxBool autoQueue = false.obs;
  RxBool pickHour = false.obs;
  RxBool longDistance = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerTitle: false,
        title: AppString.driverPreference.tr,
      ),
      body: SafeArea(
        bottom: Utils().checkPlatForm,

        child: SingleChildScrollView(
          child: Column(
            children: [
              Obx(() {
                return commonContainer(
                  title: AppString.acceptCash.tr,
                  subTitle: AppString.acceptCashMsg.tr,
                  switchValue: acceptCash.value,
                  onSwitch: (value) {
                    acceptCash.value = value;
                  },
                );
              }),
              16.verticalSpace,
              Obx(() {
                return commonContainer(
                  title: AppString.autoAcceptRide.tr,
                  subTitle: AppString.autoAcceptRideMsg.tr,
                  switchValue: autoAcceptRide.value,
                  onSwitch: (value) {
                    autoAcceptRide.value = value;
                  },
                );
              }),

              16.verticalSpace,

              Obx(
                () => commonContainer(
                  title: AppString.autoQueue.tr,
                  subTitle: AppString.autoQueueMsg.tr,
                  switchValue: autoQueue.value,
                  onSwitch: (value) {
                    autoQueue.value = value;
                  },
                ),
              ),
              16.verticalSpace,

              Obx(
                () => commonContainer(
                  title: AppString.pickHourRide.tr,
                  subTitle: AppString.autoQueueMsg.tr,
                  switchValue: pickHour.value,
                  onSwitch: (value) {
                    pickHour.value = value;
                  },
                ),
              ),
              16.verticalSpace,

              Obx(
                () => commonContainer(
                  title: AppString.longDistanceTrip.tr,
                  subTitle: AppString.autoQueueMsg.tr,
                  switchValue: longDistance.value,
                  onSwitch: (value) {
                    longDistance.value = value;
                  },
                ),
              ),
            ],
          ).paddingAll(16.w),
        ),
      ),
    );
  }

  Widget commonContainer({
    required String title,
    required String subTitle,
    required Function(bool value) onSwitch,
    required bool switchValue,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textFieldBorderColor),
        borderRadius: BorderRadius.circular(12.r),
        color: AppColors.whiteColor,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(string: title, fontWeight: FontWeight.w500),
                4.verticalSpace,
                CommonText(string: subTitle, softWrap: true, fontSize: 12.sp),
              ],
            ),
          ),
          16.horizontalSpace,
          CustomSwitch(
            value: switchValue,
            onChanged: (value) {
              onSwitch(value);
            },
          ),
        ],
      ),
    );
  }
}
