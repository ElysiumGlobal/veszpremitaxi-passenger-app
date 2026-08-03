import 'dart:async';

import 'package:e_taxi/feature/account/controller/account_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../../document_verify_screen.dart';
import '../widget/icon_widget.dart';

class AccountDeactiveScreen extends StatefulWidget {
  const AccountDeactiveScreen({super.key});

  @override
  State<AccountDeactiveScreen> createState() => _AccountDeactiveScreenState();
}

class _AccountDeactiveScreenState extends State<AccountDeactiveScreen> {
  LatLng demoLaeLong = LatLng(21.1702, 72.8311);

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      getProfile();
      getLocation();
    });
  }

  Future<void> getProfile() async {
    await accountController.getUserData();

    if ((accountController.userModel.value?.isVerified ?? '0') == "1") {
      Navigation.replaceAll(Routes.homeScreen);
    }
  }

  final accountController = Get.put(AccountController());

  Future<void> getLocation() async {
    _marker.value.add(
      Marker(
        markerId: MarkerId("current"),

        icon: Utils().driverIcon ??
            Utils().carIcon ??
            BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueYellow,
            ),
        position: demoLaeLong,
      ),
    );
    try {
      final location = await Geolocator.getCurrentPosition();
      _marker.value.removeWhere(
        (element) => element.markerId.value == "current",
      );
      _marker.value.add(
        Marker(
          markerId: MarkerId("current"),

          icon: Utils().driverIcon ??
            Utils().carIcon ??
            BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueYellow,
            ),
          position: LatLng(location.latitude, location.longitude),
        ),
      );

      await Future.delayed(Duration(milliseconds: 300));

      GoogleMapController controller = await _controller.future;

      CameraPosition cameraPosition = CameraPosition(
        target: LatLng(location.latitude, location.longitude),
        zoom: 13,
      );

      await controller.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );
    } catch (e) {}
  }

  Rx<Set<Marker>> _marker = Rx<Set<Marker>>({});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: Utils().checkPlatForm,

        child: SizedBox(
          height: Get.height,
          width: Get.width,
          child: Stack(
            children: [
              Obx(
                () => GoogleMap(
                  compassEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: demoLaeLong,
                    zoom: 13,
                  ),
                  onMapCreated: (controller) {
                    Future.delayed(Duration(milliseconds: 500), () {
                      _controller.complete(controller);
                    });
                  },

                  onCameraMove: (position) {},
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  onCameraIdle: () {},

                  mapType: MapType.normal,

                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{}
                    ..add(
                      Factory<PanGestureRecognizer>(
                        () =>
                            PanGestureRecognizer()
                              ..onUpdate = (dragUpdateDetails) {},
                      ),
                    )
                    ..add(
                      Factory<ScaleGestureRecognizer>(
                        () =>
                            ScaleGestureRecognizer()
                              ..onStart = (dragUpdateDetails) {},
                      ),
                    )
                    ..add(
                      Factory<TapGestureRecognizer>(
                        () => TapGestureRecognizer(),
                      ),
                    )
                    ..add(
                      Factory<VerticalDragGestureRecognizer>(
                        () =>
                            VerticalDragGestureRecognizer()
                              ..onDown = (dragUpdateDetails) {},
                      ),
                    ),

                  markers: _marker.value,
                ),
              ),
              Positioned(
                top: 24.h,
                left: 16.w,
                right: 16.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconWidgets(icon: IconAsset.menu, onTap: () {}),
                    GestureDetector(
                      onTap: () {
                        Navigation.replaceAll(Routes.registerScreen);
                      },
                      child: Container(
                        height: 44.h,
                        width: 44.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.whiteColor,
                        ),
                        child: Icon(Icons.logout_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        getProfile();
                      },
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.r),
                          color: AppColors.greyColor,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomImage(
                              image: ImagesAsset.drivingCar,
                              ht: 32.w,
                              wt: 32.w,
                              color: AppColors.whiteColor,
                            ),
                            10.horizontalSpace,
                            CommonText(
                              string: AppString.goOnline.tr,
                              fontSize: 22.sp,
                              color: AppColors.whiteColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    24.verticalSpace,
                    Container(
                      padding: EdgeInsets.all(16.w),
                      color: AppColors.whiteColor,
                      width: double.infinity,
                      child: Column(
                        children: [
                          CommonText(
                            string: AppString.accountUnderReview.tr,
                            fontSize: 22.sp,
                          ),
                          8.verticalSpace,
                          CommonText(
                            string: AppString.verifyYourDocument.tr,
                            fontSize: 14.sp,
                            softWrap: true,
                            color: AppColors.bodyText,
                          ),
                          16.verticalSpace,
                          CustomButton(
                            text: AppString.contactSupport.tr,
                            onTap: () {
                              Get.to(() => DocVerifyCheckScreen());
                            },
                          ),
                          8.verticalSpace,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
