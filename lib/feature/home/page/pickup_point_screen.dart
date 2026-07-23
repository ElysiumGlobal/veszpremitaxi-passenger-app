import 'dart:async';

import 'package:e_taxi/feature/home/controller/home_controller.dart';
import 'package:e_taxi/feature/home/widget/dialog.dart';
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
import '../../../utils/google_utils.dart';
import '../../../utils/log_utils.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/utils.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/custom_textfeild.dart';

class PickupPointScreen extends StatefulWidget {
  const PickupPointScreen({super.key});

  @override
  State<PickupPointScreen> createState() => _PickupPointScreenState();
}

class _PickupPointScreenState extends State<PickupPointScreen> {
  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (Get.arguments != null) {
      var arg = Get.arguments;
      pickUpLatLng.value = arg['pickUpLatLng'];

      userSelectLatLng = pickUpLatLng.value;
      updateCameraPosition();

      Future.microtask(() {
        title.value = Utils()
            .getString(homeController.selectedLocationModel.oAddress ?? "")
            .first;
        subTitle.value = Utils()
            .getString(homeController.selectedLocationModel.oAddress ?? "")
            .last;
      });
    }
  }

  Future<void> updateCameraPosition() async {
    await Future.delayed(Duration(milliseconds: 500));
    GoogleMapController controller = await _controller.future;

    CameraPosition cameraPosition = CameraPosition(
      target: pickUpLatLng.value,
      zoom: 13,
    );

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );

    await Future.delayed(Duration(seconds: 2));
    listenMap = true;
  }

  Rx<LatLng> pickUpLatLng = LatLng(0, 0).obs;

  RxString title = "".obs;
  RxString subTitle = "".obs;

  List<String> iconList = [
    IconAsset.buildingSimple,
    IconAsset.homeSimple,
    IconAsset.add,
  ];
  List<String> nameList = [AppString.work, AppString.home, AppString.addNew];

  LatLng? userSelectLatLng;
  bool listenMap = false;

  Rx<String> currentAddress = "".obs;

  Future<void> updateAddress(LatLng latLng) async {
    String value = await GoogleMapUtils.latLngToLocation(latLng);

    if (value.isNotEmpty) {
      title.value = value.split("**").first;
      subTitle.value = value.split("**").last;
    }
  }

  RxBool isChangeAddress = false.obs;

  final homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 430.h,
                    child: Obx(
                      () => GoogleMap(
                        padding: EdgeInsets.only(top: 40.h),
                        initialCameraPosition: CameraPosition(
                          target: pickUpLatLng.value,
                          zoom: 14,
                        ),
                        mapToolbarEnabled: false,
                        zoomControlsEnabled: false,
                        mapType: MapType.normal,
                        onMapCreated: (controller) {
                          Future.delayed(Duration(milliseconds: 500), () {
                            _controller.complete(controller);
                          });
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        onCameraMove: (position) {
                          if (listenMap) {
                            userSelectLatLng = position.target;
                          }
                        },
                        onCameraIdle: () async {
                          if (userSelectLatLng != null &&
                              userSelectLatLng != pickUpLatLng.value) {
                            isChangeAddress.value = true;
                            updateAddress(userSelectLatLng!);
                          }
                        },
                        //
                        // markers: markers,
                        // polylines: _polyLines,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16.h,
                    left: 16.h,
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        width: 40.h,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blackColor.withValues(
                                alpha: 0.1,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: CustomImage(image: IconAsset.arrowLeftIcon),
                      ),
                    ),
                  ),
                  Icon(Icons.location_on_sharp, color: AppColors.successColor),
                ],
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.r),
                  ),
                  color: AppColors.whiteColor,
                ),

                transform: Matrix4.translationValues(0, -10.h, 0),
                // Moves 10px UP
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      string: AppString.doubleCheckPickupPoint.tr,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 12.h),
                      padding: EdgeInsets.all(12.w),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: AppColors.textFieldBorderColor,
                        ),
                      ),
                      child: Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                              string: title.value,
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                            ),
                            2.verticalSpace,
                            CommonText(
                              string: subTitle.value,
                              fontWeight: FontWeight.w400,
                              fontSize: 14.sp,
                              color: AppColors.textCaptionColor,
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    CommonText(
                      string: AppString.saveLocationAs.tr,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    16.verticalSpace,
                    Wrap(
                      direction: Axis.horizontal,
                      runSpacing: 10.w,
                      spacing: 10.w,
                      children: [
                        ...List.generate(3, (index) {
                          return GestureDetector(
                            onTap: () async {
                              TextEditingController addressController =
                                  TextEditingController();

                              if (index == 2) {
                                AppDialog.commonDialog(
                                  childs: Column(
                                    mainAxisSize: MainAxisSize.min,
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
                                        readOnly: true,
                                        title: AppString.location.tr,
                                        controller: TextEditingController(
                                          text:
                                              "${title.value} ${subTitle.value}",
                                        ),
                                        hintText:
                                            "Eg. Basement, City centre complex, Bhuj, Gujrat370001",
                                        onChanged: (value) {
                                          if (value.isNotEmpty) {}
                                        },
                                      ),
                                      16.verticalSpace,

                                      CustomButton(
                                        text: AppString.addNewAddress.tr,
                                        onTap: () async {
                                          if (addressController.text
                                                  .trim()
                                                  .length <
                                              3) {
                                            AppSnackBar.showErrorSnackBar(
                                              message: AppString.addAddress.tr,
                                              isError: true,
                                            );
                                            return;
                                          }

                                          FocusScope.of(context).unfocus();
                                          bool result = await homeController
                                              .addAddressFromPickUpScreen(
                                                latLng: userSelectLatLng!,
                                                name: addressController.text
                                                    .trim(),
                                                address:
                                                    "${title.value} ${subTitle.value}",
                                              );
                                          LogUtils.printAction(
                                            "CALL::::$result",
                                          );
                                          if (result) {
                                            Future.delayed(
                                              Duration(milliseconds: 50),
                                              () {
                                                Navigation.pop();
                                                AppSnackBar.showErrorSnackBar(
                                                  message:
                                                      "Location saved successfully",
                                                );
                                              },
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                AppDialog.commonDialog(
                                  childs: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CommonText(
                                        string:
                                            AppString.areYouSureAddAddress.tr,
                                        softWrap: true,
                                        fontSize: 18.sp,
                                      ),

                                      24.verticalSpace,

                                      CustomButton(
                                        text: AppString.addNewAddress.tr,
                                        onTap: () async {
                                          bool result = await homeController
                                              .addAddressFromPickUpScreen(
                                                latLng: userSelectLatLng!,
                                                name: index == 1
                                                    ? "Work"
                                                    : "Home",
                                                address:
                                                    "${title.value} ${subTitle.value}",
                                              );
                                          LogUtils.printAction(
                                            "CALL::::$result",
                                          );
                                          if (result) {
                                            Future.delayed(
                                              Duration(milliseconds: 50),
                                              () {
                                                Navigation.pop();
                                                AppSnackBar.showErrorSnackBar(
                                                  message:
                                                      "Location saved successfully",
                                                );
                                              },
                                            );
                                          }
                                        },
                                      ),
                                      16.verticalSpace,
                                      CustomButton(
                                        buttonColor: AppColors.transparent,
                                        borderColor: AppColors.blackColor,
                                        text: AppString.notNow.tr,
                                        onTap: () async {
                                          Get.back();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24.r),
                                border: Border.all(
                                  color: AppColors.textFieldBorderColor,
                                ),
                              ),

                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomImage(
                                    image: iconList[index],
                                    color: AppColors.blackColor,
                                  ),
                                  8.horizontalSpace,
                                  CommonText(string: nameList[index]),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: Utils().checkPlatForm,
        child: Padding(
          padding: EdgeInsets.all(16.w),

          child: Obx(
            () => CustomButton(
              text: isChangeAddress.value == false
                  ? AppString.confirmPickup.tr
                  : AppString.saveUpdatePickUp.tr,
              onTap: () {
                if (isChangeAddress.value == false) {
                  // old address

                  homeController.confirmRide(
                    bookingId:
                        homeController
                            .bookingCreateModel
                            .value
                            ?.data
                            ?.booking
                            ?.id ??
                        "",
                    latLng: userSelectLatLng!,
                  );
                } else {
                  homeController.updatePickUpLocation(
                    bookingId:
                        homeController
                            .bookingCreateModel
                            .value
                            ?.data
                            ?.booking
                            ?.id ??
                        "",
                    address: "${title.value}, ${subTitle.value}",
                    latLng: userSelectLatLng!,
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
