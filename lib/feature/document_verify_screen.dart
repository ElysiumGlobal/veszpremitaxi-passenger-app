import 'dart:io';

import 'package:camera/camera.dart';
import 'package:e_taxi/feature/account/controller/account_controller.dart';
import 'package:e_taxi/feature/auth/service/auth_service.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/common_api_caller.dart';
import 'package:e_taxi/utils/loading_mixin.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/service/firebase_notification_new.dart';
import '../utils/app_string.dart';
import '../utils/navigation_utils/navigation.dart';
import '../utils/navigation_utils/routes.dart';
import '../widgets/cacheNetworkImage.dart';
import 'auth/widget/camera_screen.dart';

class DocVerifyCheckScreen extends StatefulWidget {
  const DocVerifyCheckScreen({super.key});

  @override
  State<DocVerifyCheckScreen> createState() => _DocVerifyCheckScreenState();
}

class _DocVerifyCheckScreenState extends State<DocVerifyCheckScreen>
    with LoadingMixin, LoadingApiMixin {
  final profileController = Get.put(AccountController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      profileController.getUserData(isLoading: true);
      FireBaseNotification().notificationPermission();
    });
  }

  RxMap<String, XFile> userDoc = <String, XFile>{}.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppString.document.tr, centerTitle: false),
      body: SingleChildScrollView(
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                title: AppString.registerNumber.tr,
                titlestarWidget: Container(
                  margin: EdgeInsets.only(left: 6.w),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    color: getBgColor(
                      profileController
                              .userModel
                              .value
                              ?.vehicle
                              ?.registrationStatus ??
                          "",
                    ),
                  ),
                  child: CommonText(
                    string:
                        profileController
                            .userModel
                            .value
                            ?.vehicle
                            ?.registrationStatus ??
                        "",
                    color: getTextColor(
                      profileController
                              .userModel
                              .value
                              ?.vehicle
                              ?.registrationStatus ??
                          "",
                    ),
                  ),
                ),
                hintText: "GJ-00-DD-0000",
                controller: TextEditingController(
                  text:
                      profileController
                          .userModel
                          .value
                          ?.vehicle
                          ?.registrationNumber ??
                      "",
                ),
                readOnly:
                    !(profileController
                            .userModel
                            .value
                            ?.vehicle
                            ?.registrationStatus ==
                        "rejected"),
                onChanged: (v) {
                  licenceNumber = v;
                },
              ).paddingOnly(bottom: 16.h),
              ...(profileController.userModel.value?.vehicleDocuments ?? []).map((
                e,
              ) {
                return Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.whiteColor,
                  ),

                  margin: EdgeInsets.only(bottom: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        string: (e.name ?? "") == "Selfi"
                            ? "Selfie"
                            : e.name ?? "",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      8.verticalSpace,
                      Stack(
                        children: [
                          Obx(
                            () => userDoc['${e.type}'] != null
                                ? Image.file(
                                    File(userDoc['${e.type}']!.path),
                                    height: 150.h,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : NetworkImageWidget(
                                    image: e.fileFrontUrl ?? "",
                                    wt: double.infinity,
                                    ht: 150.h,
                                    radius: 12.r,
                                    errorImage: ImagesAsset.profile,
                                  ),
                          ),
                          Positioned(
                            top: 5.w,
                            right: 5.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.w,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.r),
                                color: getBgColor(e.status ?? ""),
                              ),
                              child: CommonText(
                                string: e.status ?? "",
                                color: getTextColor(e.status ?? ""),
                              ),
                            ),
                          ),
                          if (e.status == "rejected" ||
                              (e.status == "pending" &&
                                  (e.fileFrontUrl ?? "").isEmpty))
                            Positioned(
                              top: 5.w,
                              left: 5.w,
                              child: GestureDetector(
                                onTap: () async {
                                  if (e.type == "selfi") {
                                    var camera = await Permission.camera.status;
                                    var microphone =
                                        await Permission.microphone.status;

                                    if (!(camera.isGranted &&
                                        microphone.isGranted)) {
                                      camera = await Permission.camera
                                          .request();
                                      microphone = await Permission.microphone
                                          .request();

                                      if (!(camera.isGranted &&
                                          microphone.isGranted)) {
                                        camera = await Permission.camera
                                            .request();
                                        microphone = await Permission.microphone
                                            .request();

                                        if (!(camera.isGranted &&
                                            microphone.isGranted)) {
                                          await openAppSettings();
                                        }
                                      }
                                    }

                                    if (camera.isGranted &&
                                        microphone.isGranted) {
                                      final result = await Get.to(
                                        () => CameraScreen(),
                                      );

                                      if (result != null) {
                                        userDoc.putIfAbsent(
                                          "${e.type}",
                                          () => XFile(""),
                                        );
                                        userDoc["${e.type}"] = result;
                                      }
                                    }
                                  } else {
                                    final image = await Utils().getImage();
                                    if (image != null) {
                                      userDoc.putIfAbsent(
                                        "${e.type}",
                                        () => XFile(""),
                                      );
                                      userDoc["${e.type}"] = image;
                                    }
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.whiteColor.withValues(
                                      alpha: .5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: CustomImage(
                                    image: IconAsset.edit,
                                    ht: 20.w,
                                    wt: 20.w,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      if ((e.rejectionReason ?? "").isNotEmpty &&
                          e.status == "rejected")
                        CommonText(
                          string:
                              "${AppString.reason.tr} : ${e.rejectionReason ?? ""}",
                          color: AppColors.errorColor,
                          softWrap: true,
                        ).paddingOnly(top: 3.h),
                    ],
                  ),
                );
              }).toList(),
              ...(profileController.userModel.value?.documents ?? []).map((e) {
                return Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.whiteColor,
                  ),

                  margin: EdgeInsets.only(bottom: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        string: (e.name ?? "") == "Selfi"
                            ? "Selfie"
                            : e.name ?? "",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      8.verticalSpace,
                      Stack(
                        children: [
                          Obx(
                            () => userDoc['${e.type}'] != null
                                ? Image.file(
                                    File(userDoc['${e.type}']!.path),
                                    height: 150.h,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : NetworkImageWidget(
                                    image: e.fileFrontUrl ?? "",
                                    wt: double.infinity,
                                    ht: 150.h,
                                    radius: 12.r,
                                    errorImage: ImagesAsset.profile,
                                  ),
                          ),
                          Positioned(
                            top: 5.w,
                            right: 5.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.w,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.r),
                                color: getBgColor(e.status ?? ""),
                              ),
                              child: CommonText(
                                string: e.status ?? "",
                                color: getTextColor(e.status ?? ""),
                              ),
                            ),
                          ),
                          if (e.status == "rejected" ||
                              (e.status == "pending" &&
                                  (e.fileFrontUrl ?? "").isEmpty))
                            Positioned(
                              top: 5.w,
                              left: 5.w,
                              child: GestureDetector(
                                onTap: () async {
                                  if (e.type == "selfi") {
                                    var camera = await Permission.camera.status;
                                    var microphone =
                                        await Permission.microphone.status;
                                    print("Status::${camera}");
                                    print("Status::${microphone}");

                                    if (!(camera.isGranted &&
                                        microphone.isGranted)) {
                                      camera = await Permission.camera
                                          .request();
                                      microphone = await Permission.microphone
                                          .request();

                                      if (!(camera.isGranted &&
                                          microphone.isGranted)) {
                                        camera = await Permission.camera
                                            .request();
                                        microphone = await Permission.microphone
                                            .request();

                                        if (!(camera.isGranted &&
                                            microphone.isGranted)) {
                                          await openAppSettings();
                                        }
                                      }
                                    }

                                    if (camera.isGranted &&
                                        microphone.isGranted) {
                                      final result = await Get.to(
                                        () => CameraScreen(),
                                      );

                                      if (result != null) {
                                        userDoc.putIfAbsent(
                                          "${e.type}",
                                          () => XFile(""),
                                        );
                                        userDoc["${e.type}"] = result;
                                      }
                                    }
                                  } else {
                                    final image = await Utils().getImage();
                                    if (image != null) {
                                      userDoc.putIfAbsent(
                                        "${e.type}",
                                        () => XFile(""),
                                      );
                                      userDoc["${e.type}"] = image;
                                    }
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.whiteColor.withValues(
                                      alpha: .5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: CustomImage(
                                    image: IconAsset.edit,
                                    ht: 20.w,
                                    wt: 20.w,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      if ((e.rejectionReason ?? "").isNotEmpty &&
                          e.status == "rejected")
                        CommonText(
                          string:
                              "${AppString.reason.tr} : ${e.rejectionReason ?? ""}",
                          color: AppColors.errorColor,
                          softWrap: true,
                        ).paddingOnly(top: 3.h),
                    ],
                  ),
                );
              }).toList(),
            ],
          ).paddingAll(16.h),
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: Utils().checkPlatForm,

        child: CustomButton(
          text: AppString.submit.tr,
          onTap: () async {
            try {
              if (licenceNumber.isNotEmpty) {
                final value = await profileController.licenplateUpdate(
                  licence: licenceNumber,
                );

                if (value) {
                  licenceNumber = "";
                }
              }

              if ((profileController.userModel.value?.isVerified ?? '0') ==
                  "1") {
                Navigation.replaceAll(Routes.homeScreen);
              } else if (userDoc.isEmpty) {
                await profileController.getUserData(isLoading: true);
                if ((profileController.userModel.value?.isVerified ?? "0") ==
                    "1") {
                  Navigation.replaceAll(Routes.homeScreen);
                }
              } else {
                List<String> allPaths = userDoc.values
                    .map((file) => file.path)
                    .toList();
                List<String> imageName = userDoc.keys
                    .map((file) => file)
                    .toList();

                handleLoading(true);

                await processApi(
                  () => AuthService.registerThird(
                    imageList: allPaths,
                    make: "",
                    model: "",
                    year: "",
                    imageFileName: imageName,
                  ),
                  result: (data) async {
                    await profileController.getUserData(isLoading: true).then((
                      value,
                    ) {
                      if ((profileController.userModel.value?.isVerified ??
                              "0") ==
                          "1") {
                        Navigation.replaceAll(Routes.homeScreen);
                      }
                      userDoc.clear();
                    });
                  },
                );

                handleLoading(false);
              }
            } catch (e) {
              handleLoading(false);
            }
          },
        ).paddingOnly(left: 16.w, right: 16.w, bottom: 16.w),
      ),
    );
  }

  String licenceNumber = "";

  Color getTextColor(String value) {
    switch (value) {
      case "approved":
        return AppColors.successColor;
      case "rejected":
        return AppColors.errorColor;
      default:
        return AppColors.warningColor;
    }
  }

  Color getBgColor(String value) {
    switch (value) {
      case "approved":
        return AppColors.sucessContainer;
      case "rejected":
        return AppColors.errorBgColor;
      default:
        return AppColors.warningBgColor;
    }
  }
}
