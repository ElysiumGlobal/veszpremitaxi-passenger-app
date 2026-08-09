import 'dart:async';

import 'package:e_taxi/core/localization/vtaxi_localization_service.dart';
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
import '../model/origin_destination_model.dart';
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

class _PickupPointScreenState extends State<PickupPointScreen>
    with SingleTickerProviderStateMixin {
  Completer<GoogleMapController> _controller = Completer();
  late final AnimationController _pickupPulseController;
  late final Animation<double> _pickupPulse;
  OriginDestinationModel? originDestinationModel;
  String rideTypeId = "";
  String paymentType = "cash";

  @override
  void initState() {
    super.initState();
    _pickupPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0,
      upperBound: 1,
    )..repeat(reverse: true);
    _pickupPulse = CurvedAnimation(
      parent: _pickupPulseController,
      curve: Curves.easeInOut,
    );

    if (Get.arguments != null) {
      final arg = Get.arguments as Map;
      pickUpLatLng.value = arg['pickUpLatLng'] as LatLng;
      originDestinationModel =
          arg['originDestination'] as OriginDestinationModel?;
      rideTypeId = arg['rideTypeId']?.toString() ?? "";
      paymentType = arg['paymentType']?.toString() ?? "cash";

      userSelectLatLng = pickUpLatLng.value;
      updateCameraPosition();

      Future.microtask(() {
        title.value = Utils()
            .getString(
              originDestinationModel?.oAddress ??
                  homeController.selectedLocationModel.oAddress ??
                  "",
            )
            .first;
        subTitle.value = Utils()
            .getString(
              originDestinationModel?.oAddress ??
                  homeController.selectedLocationModel.oAddress ??
                  "",
            )
            .last;
      });
    }
  }


  @override
  void dispose() {
    _pickupPulseController.dispose();
    super.dispose();
  }

  Future<void> updateCameraPosition() async {
    await Future.delayed(Duration(milliseconds: 500));
    GoogleMapController controller = await _controller.future;

    CameraPosition cameraPosition = CameraPosition(
      target: pickUpLatLng.value,
      zoom: 17.5,
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
                    height: 365.h,
                    child: Obx(
                      () => GoogleMap(
                        padding: EdgeInsets.only(top: 40.h),
                        initialCameraPosition: CameraPosition(
                          target: pickUpLatLng.value,
                          zoom: 17.5,
                        ),
                        mapToolbarEnabled: false,
                        zoomControlsEnabled: false,
                        mapType: MapType.normal,
                        onMapCreated: (controller) {
                          if (!_controller.isCompleted) {
                            _controller.complete(controller);
                          }
                          unawaited(updateCameraPosition());
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
                          color: AppColors.brandNavy,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brandNavy.withValues(alpha: .16),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
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
                  AnimatedBuilder(
                    animation: _pickupPulse,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Transform.scale(
                            scale: .96 + (_pickupPulse.value * .08),
                            child: Container(
                              width: 74.w,
                              height: 74.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.mainPrimaryColor.withValues(
                                  alpha: .10 + (_pickupPulse.value * .10),
                                ),
                              ),
                            ),
                          ),
                          Image.asset(
                            IconAsset.pickupMarker,
                            width: 60.w,
                            height: 60.w,
                          ),
                          Positioned(
                            top: -42.h,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 11.w,
                                vertical: 7.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.brandNavy,
                                borderRadius: BorderRadius.circular(999.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.blackColor.withValues(
                                      alpha: .14,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.my_location_rounded,
                                    color: AppColors.mainPrimaryColor,
                                    size: 16.w,
                                  ),
                                  5.horizontalSpace,
                                  CommonText(
                                    string: VTaxiLocalizationService.text(
                                      'vtaxi.pickup.you_are_here',
                                      'Most itt vagy',
                                    ),
                                    color: AppColors.mainPrimaryColor,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),

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
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandNavy,
                    ),
                    5.verticalSpace,
                    CommonText(
                      string: VTaxiLocalizationService.text(
                        'vtaxi.pickup.adjust_pin_hint',
                        'Mozgasd a térképet, hogy a pin pontosan ott legyen, ahol várni fogsz a taxira.',
                      ),
                      fontSize: 12.sp,
                      color: AppColors.textCaptionColor,
                      softWrap: true,
                      height: 1.35,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 9.h),
                      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 9.h),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: AppColors.whiteColor,
                        border: Border.all(
                          color: AppColors.brandNavy.withValues(alpha: .10),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandNavy.withValues(alpha: .055),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                              string: title.value,
                              fontWeight: FontWeight.w500,
                              fontSize: 15.sp,
                            ),
                            2.verticalSpace,
                            CommonText(
                              string: subTitle.value,
                              fontWeight: FontWeight.w400,
                              fontSize: 13.sp,
                              color: AppColors.textCaptionColor,
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    CommonText(
                      string: AppString.saveLocationAs.tr,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    12.verticalSpace,
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
                                            "Például: 8200 Veszprém, Kossuth Lajos utca 1.",
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
                                        borderColor: AppColors.brandNavy,
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
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(24.r),
                                border: Border.all(
                                  color: AppColors.mainPrimaryColor.withValues(alpha: .32),
                                ),
                              ),

                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomImage(
                                    image: iconList[index],
                                    color: AppColors.brandNavy,
                                  ),
                                  8.horizontalSpace,
                                  CommonText(
                                    string: nameList[index],
                                    color: AppColors.brandNavy,
                                    fontWeight: FontWeight.w600,
                                  ),
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
              text: "Rendelés véglegesítése",
              isLoader: homeController.finalizingBooking.value,
              isDisabled: homeController.finalizingBooking.value,
              onTap: () async {
                final draft = originDestinationModel;
                final pickup = userSelectLatLng;
                if (draft == null ||
                    pickup == null ||
                    draft.dLatLng == null ||
                    rideTypeId.isEmpty) {
                  AppSnackBar.showErrorSnackBar(
                    message:
                        "A rendelés adatai hiányosak. Kérjük, kezdje újra a címválasztást.",
                    isError: true,
                  );
                  return;
                }

                final pickupAddress = isChangeAddress.value
                    ? "${title.value}, ${subTitle.value}"
                    : (draft.oAddress ?? "${title.value}, ${subTitle.value}");

                await homeController.finalizePassengerBooking(
                  origin: pickupAddress,
                  destination: draft.dAddress ?? "",
                  originLatLng: pickup,
                  destinationLatLng: draft.dLatLng!,
                  bookingContactId: draft.userNameId ?? 0,
                  rideTypeId: rideTypeId,
                  paymentMethod: paymentType,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
