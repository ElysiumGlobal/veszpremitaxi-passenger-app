import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_string.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/custom_button.dart';

class NetworkInfo {
  static final Connectivity _connectivity = Connectivity();
  static RxBool isTryAgainLoading = false.obs;

  static Future<bool> checkInternet({bool showPopUp = false}) async {
    final List<ConnectivityResult> connectivityResult = await _connectivity
        .checkConnectivity();
    final bool isNetworkAvailable =
        (connectivityResult.contains(ConnectivityResult.wifi)) ||
        (connectivityResult.contains(ConnectivityResult.mobile));
    if (showPopUp && (!isNetworkAvailable)) {
      Get.to(() => NoInternetScreen(), transition: Transition.fadeIn);
    }
    log("checkInternet: $isNetworkAvailable");
    return isNetworkAvailable;
  }

  static void setListener() {
    checkInternet(showPopUp: true);
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      if ((result.contains(ConnectivityResult.wifi)) ||
          (result.contains(ConnectivityResult.mobile))) {
        if (Get.currentRoute == '/NoInternetScreen') {
          Get.back();
        }
      } else {
        log("onConnectivityChanged: $result");

        if (Get.currentRoute != '/NoInternetScreen') {
          Get.to(() => NoInternetScreen(), transition: Transition.fadeIn);
        }
      }
    });
  }
}

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.whiteGrey,
        body: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomImage(image: ImagesAsset.noInternet),
              24.verticalSpace,
              CommonText(
                string: AppString.noInternetConnection.tr,
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
              12.verticalSpace,
              CommonText(
                string: AppString.unableToConnectToTheNetwork.tr,
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
              12.verticalSpace,
              Obx(
                () => CustomButton(
                  text: AppString.tryAgain.tr,
                  isLoader: NetworkInfo.isTryAgainLoading.value,
                  onTap: NetworkInfo.isTryAgainLoading.value == true
                      ? null
                      : () async {
                          NetworkInfo.isTryAgainLoading(true);
                          final bool isNetworkAvailable =
                              await NetworkInfo.checkInternet();
                          if (isNetworkAvailable) {
                            if (Get.currentRoute == '/NoInternetScreen') {
                              Get.back();
                            }
                          }
                          await Future.delayed(
                            const Duration(milliseconds: 1000),
                          );
                          NetworkInfo.isTryAgainLoading(false);
                        },
                ).paddingAll(16.w),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
