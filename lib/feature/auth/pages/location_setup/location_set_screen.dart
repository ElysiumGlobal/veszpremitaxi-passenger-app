import 'dart:convert';

import 'package:e_taxi/core/service/location_utils.dart';
import 'package:e_taxi/feature/auth/controller/register_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_preferences.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../utils/navigation_utils/navigation.dart';
import '../../../../utils/navigation_utils/routes.dart';
import '../../../../utils/utils.dart';

class LocationSetScreen extends StatefulWidget {
  const LocationSetScreen({super.key});

  @override
  State<LocationSetScreen> createState() => _LocationSetScreenState();
}

class _LocationSetScreenState extends State<LocationSetScreen> {
  final registerController = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: AppString.setLocation.tr,
        leading: SizedBox(width: 16.w),
        leadingSize: 16.w,
      ),
      body: SafeArea(
        bottom: Utils().checkPlatForm,

        child: Column(
          children: [
            Container(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
              height: 72.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                border: Border(
                  top: BorderSide(color: AppColors.textFieldBorderColor),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomImage(
                    image: ImagesAsset.locationSelect,
                    ht: 40.h,
                    wt: 40.h,
                  ),
                  Container(
                    margin: EdgeInsetsGeometry.symmetric(horizontal: 4.w),
                    width: 16.w,
                    height: 1,
                    color: AppColors.titleTextColor,
                  ),
                  CustomImage(image: ImagesAsset.profile, ht: 40.h, wt: 40.h),
                  Container(
                    margin: EdgeInsetsGeometry.symmetric(horizontal: 4.w),
                    width: 16.w,
                    height: 1,
                    color: AppColors.titleTextColor,
                  ),
                  CustomImage(image: ImagesAsset.car, ht: 40.h, wt: 40.h),
                  Container(
                    margin: EdgeInsetsGeometry.symmetric(horizontal: 4.w),
                    width: 16.w,
                    height: 1,
                    color: AppColors.titleTextColor,
                  ),
                  CustomImage(image: ImagesAsset.document, ht: 40.h, wt: 40.h),
                ],
              ),
            ),
            32.verticalSpace,
            CustomImage(
              image: ImagesAsset.enableLocation,
              wt: 270.w,
              ht: 300.h,
              fit: BoxFit.fill,
            ).paddingSymmetric(horizontal: 16.w),
            32.verticalSpace,
            TitleSubTitleWidget(
              title: AppString.enableLocationService.tr,
              subTitle: AppString.receiveRideReqNearYou.tr,
            ).paddingSymmetric(horizontal: 16.w),
            Spacer(),
            Column(
              children: [
                CustomButton(
                  text: AppString.useDeviceLocation.tr,
                  onTap: () async {
                    await LocationService().getCurrentLocation();
                    if (LocationService().currentUserLatLg.value != null) {
                      final result = await registerController.checkService(
                        LocationService().currentUserLatLg.value?.latitude ?? 0,
                        LocationService().currentUserLatLg.value?.longitude ??
                            0,
                        isDeviceLocation: true,
                      );

                      if (result) {
                        final data = AppPreference.getString(
                          AppPreference.userInitData,
                        );
                        print("DATA:::$data");
                        Navigation.pushNamed(
                          Routes.profileSetUpScreen,
                          arg: jsonDecode(data),
                        );
                        AppPreference.setInt(
                          AppPreference.userRegisterStepComplete,
                          1,
                        );
                        AppPreference.setInt(AppPreference.userStep, 1);
                      }
                    }
                  },
                ),
                6.verticalSpace,
                CustomButton(
                  text: AppString.setManually.tr,
                  buttonColor: AppColors.transparentColor,
                  onTap: () {
                    Navigation.pushNamed(Routes.manualLocationScreen);
                  },
                ),
                10.verticalSpace,
              ],
            ).paddingSymmetric(horizontal: 16.w),
          ],
        ),
      ),
    );
  }
}

class TitleSubTitleWidget extends StatelessWidget {
  const TitleSubTitleWidget({
    required this.title,
    required this.subTitle,
    super.key,
  });

  final String title;
  final String subTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CommonText(
          string: title,
          fontSize: 22.sp,
          fontWeight: FontWeight.w500,
          softWrap: true,
          textAlign: TextAlign.center,
        ),
        12.verticalSpace,
        CommonText(
          string: subTitle,
          fontSize: 14.sp,
          color: AppColors.bodyText,
          softWrap: true,
          textAlign: TextAlign.center,
        ),
      ],
    ).paddingSymmetric(horizontal: 16.w);
  }
}
