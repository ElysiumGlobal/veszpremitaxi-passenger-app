import 'dart:async';

import 'package:e_taxi/core/location_utils.dart';
import 'package:e_taxi/feature/home/controller/home_controller.dart';
import 'package:e_taxi/feature/home/widget/dialog.dart';
import 'package:e_taxi/feature/home/widget/home_address.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_string.dart';
import '../../../utils/assets.dart';
import '../../../utils/log_utils.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custome_img.dart';
import '../widget/suggetion_address.dart';

class SearchFirstScreen extends StatefulWidget {
  const SearchFirstScreen({super.key});

  @override
  State<SearchFirstScreen> createState() => _SearchFirstScreenState();
}

class _SearchFirstScreenState extends State<SearchFirstScreen> {
  final homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      body: SafeArea(
        bottom: Utils().checkPlatForm,
        child: Stack(
          children: [
            Column(
              children: [
                16.verticalSpace,
                SizedBox(
                  height: 56.h,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Get.back();
                          },

                          child: SizedBox(
                            height: 64.h,
                            child: Container(
                              height: 40.h,
                              width: 40.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.brandNavy,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 3),
                                    color: AppColors.brandNavy.withValues(alpha: .16),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: AppColors.mainPrimaryColor,
                                size: 21.w,
                              ),
                            ),
                          ),
                        ),
                        12.horizontalSpace,
                        Expanded(
                          child: CustomTextField(
                            controller: TextEditingController(),
                            hintText: 'Keress indulási címet',
                            autoFocus: true,
                            radius: 12.r,
                            fillColor: AppColors.whiteColor,
                            enableColor: AppColors.brandNavy.withValues(alpha: .12),
                            focusedColor: AppColors.mainPrimaryColor,
                            cursorColor: AppColors.brandNavy,
                            hintTextStyle: TextStyle(
                              color: AppColors.textCaptionColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                            suffixWidget: Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: Container(
                                width: 36.w,
                                height: 36.w,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.search_rounded,
                                  color: AppColors.brandNavy,
                                  size: 21.w,
                                ),
                              ),
                            ),

                            onChanged: (search) {
                              if (search.isNotEmpty) {
                                homeController.userSearchPlace(search);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                16.verticalSpace,
                SizedBox(
                  height: 63.h,
                  child: Obx(
                    () => ListView.separated(
                      separatorBuilder: (context, index) => 4.horizontalSpace,
                      padding: EdgeInsets.only(left: 16.w),
                      itemCount: homeController.userAddressList.length + 1,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        if (index == homeController.userAddressList.length) {
                          return HomeAddressWidget(
                            title: AppString.more.tr,
                            image: IconAsset.moreAdd,
                            subtitle: "",
                            onTap: () {
                              addAddressTap();
                            },
                          );
                        }
                        final data = homeController.userAddressList[index];
                        return HomeAddressWidget(
                          title: data.name ?? "",
                          image: IconAsset.homeAdd,
                          subtitle: data.address ?? "",
                          onTap: () {
                            homeController.setSelectedLocation(
                              isOrigin: true,
                              address: data.address ?? "",
                              latLng: LatLng(
                                double.parse(data.latitude ?? "0.0"),
                                double.parse(data.longitude ?? "0.0"),
                              ),
                              name: data.name ?? "",
                            );
                            Navigation.pushNamed(Routes.searchSecoundScreen);
                          },
                        );
                      },
                    ),
                  ),
                ),
                16.verticalSpace,
                Container(
                  padding: EdgeInsets.all(10.w),
                  margin: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    color: AppColors.brandNavy,
                    border: Border.all(
                      color: AppColors.mainPrimaryColor.withValues(alpha: .28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandNavy.withValues(alpha: .10),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CommonText(
                            string: AppString.currentLocation.tr,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mainPrimaryColor,
                          ),
                        ],
                      ),
                      Divider(
                        color: AppColors.whiteColor.withValues(alpha: .14),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 34.w,
                            height: 34.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              color: AppColors.mainPrimaryColor,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.my_location_rounded,
                              color: AppColors.brandNavy,
                              size: 20.w,
                            ),
                          ),
                          8.horizontalSpace,
                          Expanded(
                            child: Obx(
                              () =>
                                  LocationService()
                                      .currentAddressUse
                                      .value
                                      .isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        homeController.setSelectedLocation(
                                          name: LocationService()
                                              .currentAddressUse
                                              .value
                                              .split("**")
                                              .first,
                                          address: LocationService()
                                              .currentAddress
                                              .value,
                                          latLng: LocationService()
                                              .currentUserLatLg
                                              .value!,
                                          isOrigin: true,
                                        );
                                        Navigation.pushNamed(
                                          Routes.searchSecoundScreen,
                                        );
                                      },
                                      behavior: HitTestBehavior.translucent,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CommonText(
                                            string: LocationService()
                                                .currentAddressUse
                                                .value
                                                .split("**")
                                                .first,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.whiteColor,
                                          ),
                                          3.verticalSpace,
                                          CommonText(
                                            string: LocationService()
                                                .currentAddressUse
                                                .value
                                                .split("**")
                                                .last,
                                            fontSize: 12.sp,
                                            color: AppColors.whiteColor.withValues(alpha: .68),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () async {
                                        final location =
                                            await LocationService()
                                                .getCurrentLocation();
                                        if (location == null) {
                                          AppSnackBar.showErrorSnackBar(
                                            message:
                                                AppString.turnOnLocation.tr,
                                            isError: true,
                                          );
                                        }
                                      },
                                      child: CommonText(
                                        string: AppString.getCurrentLocation.tr,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.whiteColor,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Obx(
                    () => homeController.searchList.isEmpty
                        ? SizedBox.shrink()
                        : Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 16.w,
                              horizontal: 16.w,
                            ),
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: AppColors.brandNavy.withValues(alpha: .08),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.brandNavy.withValues(alpha: .06),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 30.w,
                                      height: 30.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer,
                                        borderRadius: BorderRadius.circular(9.r),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.place_rounded,
                                        color: AppColors.brandNavy,
                                        size: 18.w,
                                      ),
                                    ),
                                    9.horizontalSpace,
                                    CommonText(
                                      string: 'Találatok',
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.brandNavy,
                                    ),
                                  ],
                                ),
                                Divider(color: AppColors.textFieldBorderColor),
                                8.verticalSpace,
                                Expanded(
                                  child: Obx(
                                    () => ListView.separated(
                                      separatorBuilder: (context, index) =>
                                          6.verticalSpace,
                                      itemCount:
                                          homeController.searchList.length,
                                      itemBuilder: (context, index) {
                                        final data =
                                            homeController.searchList[index];
                                        return SuggestionAddressWidget(
                                          title: (data.terms ?? []).isNotEmpty
                                              ? data.terms?.first.value ?? ""
                                              : "",
                                          subTitle: data.description ?? "",
                                          onTap: () {
                                            homeController.searchOrigin(
                                              data.placeId ?? "",
                                              (data.terms ?? []).isNotEmpty
                                                  ? data.terms?.first.value ??
                                                        ""
                                                  : "",
                                              data.description ?? "",
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
            Obx(
              () => homeController.getLatLngLoading.value
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  void addAddressTap() {
    TextEditingController addressController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    String placeId = "";

    AppDialog.commonBottomSheetWidget(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              string: AppString.addAddress.tr,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
            16.verticalSpace,
            CustomTextField(
              title: AppString.name.tr,
              controller: addressController,
              hintText: "Eg. Gym",
            ),
            8.verticalSpace,
            CustomTextField(
              title: AppString.location.tr,
              controller: locationController,
              hintText: "Például: 8200 Veszprém, Kossuth Lajos utca 1.",
              onChanged: (value) {
                if (value.isNotEmpty) {
                  homeController.userSearchPlace(value);
                }
              },
            ),
            16.verticalSpace,
            Obx(
              () => homeController.searchList.isEmpty
                  ? SizedBox.shrink()
                  : SizedBox(
                      height: 270.h,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) =>
                            6.verticalSpace,
                        padding: EdgeInsets.zero,
                        itemCount: homeController.searchList.length > 4
                            ? 4
                            : homeController.searchList.length,
                        itemBuilder: (context, index) {
                          final data = homeController.searchList[index];
                          return SuggestionAddressWidget(
                            title: (data.terms ?? []).isNotEmpty
                                ? data.terms?.first.value ?? ""
                                : "",
                            subTitle: data.description ?? "",
                            onTap: () {
                              placeId = data.placeId ?? "";
                              locationController.text = data.description ?? "";
                            },
                          );
                        },
                      ),
                    ),
            ),
            CustomButton(
              text: AppString.addNewAddress.tr,
              onTap: () async {
                if (addressController.text.trim().length < 3) {
                  AppSnackBar.showErrorSnackBar(
                    message: AppString.addAddress.tr,
                    isError: true,
                  );
                  return;
                } else if (placeId.isEmpty) {
                  AppSnackBar.showErrorSnackBar(
                    message: AppString.pleaseSelectLocation.tr,
                    isError: true,
                  );
                  return;
                }
                FocusScope.of(context).unfocus();
                bool result = await homeController.addAddress(
                  placeId,
                  addressController.text.trim(),
                );
                LogUtils.printAction("CALL::::$result");
                if (result) {
                  Future.delayed(Duration(milliseconds: 50), () {
                    Navigation.pop();
                    AppSnackBar.showErrorSnackBar(
                      message: "Location saved successfully",
                    );
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
