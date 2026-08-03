import 'dart:async';
import 'dart:convert';

import 'package:e_taxi/core/service/location_utils.dart';
import 'package:e_taxi/feature/auth/controller/register_controller.dart';
import 'package:e_taxi/feature/auth/widget/search_location.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../utils/app_preferences.dart';
import '../../../../utils/navigation_utils/navigation.dart';
import '../../../../utils/navigation_utils/routes.dart';
import '../../../../utils/utils.dart';
import '../../../../widgets/common_text.dart';
import 'location_set_screen.dart';

class ManualLocationScreen extends StatefulWidget {
  const ManualLocationScreen({super.key});

  @override
  State<ManualLocationScreen> createState() => _ManualLocationScreenState();
}

class _ManualLocationScreenState extends State<ManualLocationScreen> {
  final registerController = Get.find<RegisterController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      appBar: CustomAppBar(centerTitle: false, title: AppString.setLocation.tr),
      body: SafeArea(
        bottom: Utils().checkPlatForm,

        child: Obx(
          () => registerController.selectedIndx.value == 0
              ? Column(
                  children: [
                    CustomTextField(
                      hintText: AppString.search.tr,
                      controller: TextEditingController(),

                      prefixIcon: IconAsset.search,
                      suffixIcon: IconAsset.close,

                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (registerController.debounce?.isActive ?? false)
                            registerController.debounce?.cancel();
                          registerController.debounce = Timer(
                            const Duration(milliseconds: 400),
                            () {
                              registerController.searchPlace(value);
                            },
                          );
                        }
                      },
                    ).paddingSymmetric(vertical: 24.h),
                    GestureDetector(
                      onTap: () async {
                        await LocationService().getCurrentLocation();

                        print("HERE ");

                        if (LocationService().currentUserLatLg.value != null) {
                          final result = await registerController.checkService(
                            LocationService()
                                    .currentUserLatLg
                                    .value
                                    ?.latitude ??
                                0,
                            LocationService()
                                    .currentUserLatLg
                                    .value
                                    ?.longitude ??
                                0,
                            isDeviceLocation: true,
                          );

                          if (result) {
                            AppPreference.setInt(
                              AppPreference.userRegisterStepComplete,
                              1,
                            );
                            final data = AppPreference.getString(
                              AppPreference.userInitData,
                            );
                            Navigation.pushNamed(
                              Routes.profileSetUpScreen,
                              arg: jsonDecode(data),
                            );
                            AppPreference.setInt(AppPreference.userStep, 1);
                          }
                        }
                      },
                      child: Row(
                        children: [
                          CustomImage(image: IconAsset.gps, ht: 24.w, wt: 24.w),
                          14.horizontalSpace,
                          Expanded(
                            child: CommonText(
                              string: AppString.useDeviceLocation.tr,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ).paddingOnly(bottom: 12.h),
                    ),
                    Expanded(
                      child: Obx(
                        () => registerController.searchList.isEmpty
                            ? Center(
                                child: CommonText(string: "Search Here..."),
                              )
                            : registerController.searchLoading.value
                            ? Skeletonizer(
                                enabled: true,
                                child: ListView.builder(
                                  itemCount: 5,
                                  itemBuilder: (context, index) {
                                    return SearchLocationWidget(
                                      subTitle: "data.description",
                                      title: " surat",
                                      onTap: () async {},
                                    ).paddingSymmetric(vertical: 12.h);
                                  },
                                ),
                              )
                            : ListView.separated(
                                itemBuilder: (context, index) {
                                  final data =
                                      registerController.searchList[index];
                                  return SearchLocationWidget(
                                    subTitle: data.description ?? "",
                                    title: (data.terms ?? []).isNotEmpty
                                        ? data.terms?.first.value ?? ""
                                        : "",
                                    onTap: () async {
                                      FocusScope.of(context).unfocus();
                                      registerController.getPlaceDetails(
                                        data.placeId ?? "",
                                        (data.terms ?? []).isNotEmpty
                                            ? data.terms?.first.value ?? ""
                                            : "",
                                      );
                                    },
                                  ).paddingSymmetric(vertical: 12.h);
                                },
                                separatorBuilder: (context, index) => Container(
                                  width: double.infinity,
                                  height: 1,
                                  color: AppColors.dividerColor,
                                ),
                                itemCount: registerController.searchList.length,
                              ),
                      ),
                    ),
                  ],
                ).paddingSymmetric(horizontal: 16.w)
              : registerController.selectedIndx.value == 1
              ? Obx(
                  () => Skeletonizer(
                    enabled: registerController.selectedAddress.isEmpty,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.w),
                          color: AppColors.whiteColor,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CommonText(
                                      string: AppString.detectLocation.tr,
                                      color: AppColors.textCaptionColor,
                                    ),
                                    4.verticalSpace,
                                    CommonText(
                                      string:
                                          registerController
                                              .selectedAddress
                                              .isEmpty
                                          ? "seleceted address"
                                          : registerController
                                                .selectedAddress['formatted_address'],
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  registerController.selectedIndx.value = 0;
                                },
                                child: Container(
                                  height: 40.w,
                                  width: 40.w,

                                  decoration: BoxDecoration(
                                    color: AppColors.whiteGrey,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: CustomImage(
                                    image: IconAsset.edit,
                                    ht: 24.w,
                                    wt: 24.w,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        32.verticalSpace,
                        CustomImage(
                          image: ImagesAsset.setLocation,
                          ht: 260.h,
                        ).paddingSymmetric(horizontal: 16.w),
                        32.verticalSpace,
                        TitleSubTitleWidget(
                          title:
                              "${AppString.youSetInBhuj.tr} ${registerController.selectedAddress['name']}",
                          subTitle: AppString.weLiveYourSelectedCity.tr,
                        ).paddingSymmetric(horizontal: 16.w),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    32.verticalSpace,
                    CustomImage(image: ImagesAsset.notLocation, ht: 260.h),
                    32.verticalSpace,
                    TitleSubTitleWidget(
                      title:
                          "${AppString.weAreNotInBhuj.tr} ${registerController.tempAddress['name'] ?? "Select Location"} ${AppString.yet.tr}",
                      subTitle: AppString.serviceNotAvailable.tr,
                    ),
                  ],
                ).paddingSymmetric(horizontal: 16.w),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Obx(
          () => registerController.selectedIndx.value == 0
              ? SizedBox.shrink()
              : CustomButton(
                  text: registerController.selectedIndx.value == 1
                      ? AppString.continueString.tr
                      : AppString.changeCity.tr,
                  sufixIconWidget: registerController.selectedIndx.value == 1
                      ? true
                      : false,
                  onTap: () {
                    if (registerController.selectedIndx.value == 1 &&
                        registerController.selectedAddress.isNotEmpty) {
                      AppPreference.setInt(
                        AppPreference.userRegisterStepComplete,
                        1,
                      );
                      final data = AppPreference.getString(
                        AppPreference.userInitData,
                      );
                      Navigation.pushNamed(
                        Routes.profileSetUpScreen,
                        arg: jsonDecode(data),
                      );
                      AppPreference.setInt(AppPreference.userStep, 1);
                    } else if (registerController.selectedIndx.value == 2) {
                      registerController.selectedIndx.value = 0;
                    }
                  },
                ).paddingOnly(left: 16.w, right: 16.w, bottom: 24.w),
        ),
      ),
    );
  }
}
