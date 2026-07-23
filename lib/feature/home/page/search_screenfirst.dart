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
                                color: AppColors.whiteGrey,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 8,
                                    spreadRadius: 0,
                                    offset: Offset(0, 1),
                                    color: AppColors.blackColor.withValues(
                                      alpha: .4,
                                    ),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: CustomImage(
                                image: IconAsset.arrowLeftIcon,
                              ),
                            ),
                          ),
                        ),
                        12.horizontalSpace,
                        Expanded(
                          child: CustomTextField(
                            controller: TextEditingController(),
                            hintText: "Search here",
                            autoFocus: true,
                            suffixIcon: IconAsset.search,

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
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.whiteColor,
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
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                      Divider(color: AppColors.textFieldBorderColor),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 15.w,
                                width: 15.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(
                                        0xff0993c0,
                                      ).withValues(alpha: .2),
                                      blurRadius: 1,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              CustomImage(
                                image: IconAsset.currentLocation,
                                ht: 22.w,
                                wt: 22.w,
                              ),
                            ],
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
                                          ),
                                          4.verticalSpace,
                                          CommonText(
                                            string: LocationService()
                                                .currentAddressUse
                                                .value
                                                .split("**")
                                                .last,
                                            fontSize: 12.sp,
                                            color: AppColors.textCaptionColor,
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
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w500,
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
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonText(
                                  string: AppString.recentSearch.tr,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                Divider(color: AppColors.textFieldBorderColor),
                                8.verticalSpace,
                                Expanded(
                                  child: Obx(
                                    () => ListView.separated(
                                      separatorBuilder: (context, index) =>
                                          Divider(
                                            color:
                                                AppColors.textFieldBorderColor,
                                          ),
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
              hintText: "Eg. Basement, City centre complex, Bhuj, Gujrat370001",
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
                            Divider(color: AppColors.textFieldBorderColor),
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
