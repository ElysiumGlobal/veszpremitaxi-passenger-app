import 'package:e_taxi/core/service/location_utils.dart';
import 'package:e_taxi/feature/home/controller/home_controller.dart';
import 'package:e_taxi/feature/home/pages/home_screen.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../utils/app_string.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';

class TripConfirmationScreen extends StatefulWidget {
  const TripConfirmationScreen({super.key});

  @override
  State<TripConfirmationScreen> createState() => _TripConfirmationScreenState();
}

class _TripConfirmationScreenState extends State<TripConfirmationScreen> {
  final homeController = Get.find<HomeController>();
  RxBool isPop = false.obs;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isPop.value,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop == false) {
          isPop.value = true;
          Navigation.popupUtil(Routes.homeScreen);
        }
      },
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomImage(image: ImagesAsset.confirmRide),
            CommonText(
              string: AppString.tripCompletedSuccessFully.tr,
              softWrap: true,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w500,
              fontSize: 16.sp,
            ),
            4.verticalSpace,
            CommonText(
              string: AppString.yourSummeryRecord.tr,
              softWrap: true,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w500,
            ),
          ],
        ).paddingSymmetric(horizontal: 16.w),
        bottomNavigationBar: SafeArea(
          bottom: Utils().checkPlatForm,

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomButton(
                text: AppString.readyForNextRide.tr,
                onTap: () {
                  rideDataModel.value = null;
                  Navigation.popupUtil(Routes.homeScreen);
                },
              ),
              16.verticalSpace,
              CustomButton(
                text: AppString.goOffline.tr,
                buttonColor: AppColors.transparent,
                borderColor: AppColors.blackColor,
                onTap: () {
                  homeController.userOnlineOffline(
                    LocationService().currentUserLatLg.value ?? LatLng(0, 0),
                    screenRedirect: true,
                    onlineOffline: 0,
                  );
                },
              ),
            ],
          ).paddingAll(16.w),
        ),
      ),
    );
  }
}
