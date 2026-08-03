import 'package:e_taxi/feature/auth/controller/register_controller.dart';
import 'package:e_taxi/feature/auth/widget/selection_section_widget.dart';
import 'package:e_taxi/feature/auth/widget/view_image.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/validation_utils.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:e_taxi/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../utils/app_string.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_button.dart';
import '../widget/camera_screen.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  Rx<XFile?> licenceImg = Rxn<XFile>();
  Rx<XFile?> rcImg = Rxn<XFile>();
  Rx<XFile?> insuranceImg = Rxn<XFile>();
  Rx<XFile?> liveSelfiImg = Rxn<XFile>();

  TextEditingController modelController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController makeController = TextEditingController();

  RxMap<String, XFile> userDoc = <String, XFile>{}.obs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller.getDocList();
  }

  final controller = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: AppString.document.tr,
        leading: SizedBox(width: 16.w),
        leadingSize: 16.w,
      ),
      body: Column(
        children: [
          SelectionSectionWidget(index: 3),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.textFieldBorderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          string: AppString.selectedVehicle.tr,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),

                        CustomTextField(
                          autoFocus: true,
                          title: AppString.make.tr,
                          controller: makeController,
                          hintText: "Honda",
                          textInputAction: TextInputAction.next,
                          onOutTap: (event) {
                            FocusScope.of(context).unfocus();
                          },
                        ),
                        8.verticalSpace,

                        CustomTextField(
                          title: AppString.model.tr,
                          hintText: "Civic",
                          controller: modelController,

                          textInputAction: TextInputAction.next,
                          onOutTap: (event) {
                            FocusScope.of(context).unfocus();
                          },
                        ),
                        8.verticalSpace,

                        CustomTextField(
                          title: AppString.year.tr,
                          hintText: "2020",
                          controller: yearController,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          textinputformate: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],

                          onOutTap: (event) {
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      ],
                    ),
                  ).paddingSymmetric(vertical: 24.h),

                  Obx(
                    () =>
                        (controller.reqDocList.value?.data?.documents ?? [])
                            .isNotEmpty
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if ((controller.reqDocList.value?.data?.documents
                                      ?.any(
                                        (element) => element.type == "driver",
                                      ) ??
                                  false))
                                CommonText(
                                  string: AppString.driverDoc.tr,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ...(controller
                                          .reqDocList
                                          .value
                                          ?.data
                                          ?.documents ??
                                      [])
                                  .map((e) {
                                    return e.type == "driver"
                                        ? Obx(
                                            () => e.name == "selfi"
                                                ? customWidget(
                                                    title:
                                                        AppString.liveSelfie.tr,
                                                    subtitle: AppString
                                                        .openCameraLive
                                                        .tr,
                                                    onTap: () async {
                                                      var camera =
                                                          await Permission
                                                              .camera
                                                              .status;
                                                      var microphone =
                                                          await Permission
                                                              .microphone
                                                              .status;

                                                      if (!(camera.isGranted &&
                                                          microphone
                                                              .isGranted)) {
                                                        camera =
                                                            await Permission
                                                                .camera
                                                                .request();
                                                        microphone =
                                                            await Permission
                                                                .microphone
                                                                .request();

                                                        if (!(camera
                                                                .isGranted &&
                                                            microphone
                                                                .isGranted)) {
                                                          camera =
                                                              await Permission
                                                                  .camera
                                                                  .request();
                                                          microphone =
                                                              await Permission
                                                                  .microphone
                                                                  .request();

                                                          if (!(camera
                                                                  .isGranted &&
                                                              microphone
                                                                  .isGranted)) {
                                                            await openAppSettings();
                                                          }
                                                        }
                                                      }

                                                      if (camera.isGranted &&
                                                          microphone
                                                              .isGranted) {
                                                        final result =
                                                            await Get.to(
                                                              () =>
                                                                  CameraScreen(),
                                                            );

                                                        if (result != null) {
                                                          userDoc.putIfAbsent(
                                                            "${e.name}",
                                                            () => XFile(""),
                                                          );
                                                          userDoc["${e.name}"] =
                                                              result;
                                                        }
                                                      }
                                                    },
                                                    isUpload:
                                                        userDoc[e.name] != null,
                                                  )
                                                : customWidget(
                                                    title: e.name ?? "",
                                                    subtitle:
                                                        "Upload ${e.name}",
                                                    isUpload:
                                                        userDoc[e.key] != null,
                                                    onTap: () {
                                                      showImageUploadDia(
                                                        title: e.name ?? "",
                                                        subTitle:
                                                            e.description ?? "",
                                                        file: Rx<XFile?>(
                                                          userDoc[e.key],
                                                        ),
                                                        uploadTap: () async {
                                                          final image =
                                                              await Utils()
                                                                  .getImage();
                                                          if (image != null) {
                                                            userDoc.putIfAbsent(
                                                              "${e.key}",
                                                              () => XFile(""),
                                                            );
                                                            userDoc["${e.key}"] =
                                                                image;
                                                            Get.back();
                                                          }
                                                        },
                                                        viewTap: () {
                                                          Get.back();
                                                          Get.to(
                                                            () => ViewImage(
                                                              image:
                                                                  userDoc[e.key]
                                                                      ?.path ??
                                                                  "",
                                                              title: AppString
                                                                  .drivingLicense
                                                                  .tr,
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                          )
                                        : SizedBox.shrink();
                                  })
                                  .toList(),

                              if ((controller.reqDocList.value?.data?.documents
                                      ?.any(
                                        (element) => element.type == "vehicle",
                                      ) ??
                                  false))
                                CommonText(
                                  string: AppString.vehicleDoc.tr,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ).paddingOnly(top: 12.h),
                              ...(controller
                                          .reqDocList
                                          .value
                                          ?.data
                                          ?.documents ??
                                      [])
                                  .map((e) {
                                    return e.type == "vehicle"
                                        ? Obx(
                                            () => e.name == "selfi"
                                                ? customWidget(
                                                    title:
                                                        AppString.liveSelfie.tr,
                                                    subtitle: AppString
                                                        .openCameraLive
                                                        .tr,
                                                    onTap: () async {
                                                      var camera =
                                                          await Permission
                                                              .camera
                                                              .status;
                                                      var microphone =
                                                          await Permission
                                                              .microphone
                                                              .status;

                                                      if (!(camera.isGranted &&
                                                          microphone
                                                              .isGranted)) {
                                                        camera =
                                                            await Permission
                                                                .camera
                                                                .request();
                                                        microphone =
                                                            await Permission
                                                                .microphone
                                                                .request();

                                                        if (!(camera
                                                                .isGranted &&
                                                            microphone
                                                                .isGranted)) {
                                                          camera =
                                                              await Permission
                                                                  .camera
                                                                  .request();
                                                          microphone =
                                                              await Permission
                                                                  .microphone
                                                                  .request();

                                                          if (!(camera
                                                                  .isGranted &&
                                                              microphone
                                                                  .isGranted)) {
                                                            await openAppSettings();
                                                          }
                                                        }
                                                      }

                                                      if (camera.isGranted &&
                                                          microphone
                                                              .isGranted) {
                                                        final result =
                                                            await Get.to(
                                                              () =>
                                                                  CameraScreen(),
                                                            );

                                                        if (result != null) {
                                                          userDoc.putIfAbsent(
                                                            "${e.name}",
                                                            () => XFile(""),
                                                          );
                                                          userDoc["${e.name}"] =
                                                              result;
                                                        }
                                                      }
                                                    },
                                                    isUpload:
                                                        userDoc[e.name] != null,
                                                  )
                                                : customWidget(
                                                    title: e.name ?? "",
                                                    subtitle:
                                                        "Upload ${e.name}",
                                                    isUpload:
                                                        userDoc[e.key] != null,
                                                    onTap: () {
                                                      showImageUploadDia(
                                                        title: e.name ?? "",
                                                        subTitle:
                                                            e.description ?? "",
                                                        file: Rx<XFile?>(
                                                          userDoc[e.key],
                                                        ),
                                                        uploadTap: () async {
                                                          final image =
                                                              await Utils()
                                                                  .getImage();
                                                          if (image != null) {
                                                            userDoc.putIfAbsent(
                                                              "${e.key}",
                                                              () => XFile(""),
                                                            );
                                                            userDoc["${e.key}"] =
                                                                image;
                                                            Get.back();
                                                          }
                                                        },
                                                        viewTap: () {
                                                          Get.back();
                                                          Get.to(
                                                            () => ViewImage(
                                                              image:
                                                                  userDoc[e.key]
                                                                      ?.path ??
                                                                  "",
                                                              title: AppString
                                                                  .drivingLicense
                                                                  .tr,
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                          )
                                        : SizedBox.shrink();
                                  })
                                  .toList(),
                            ],
                          )
                        : SizedBox.shrink(),
                  ),

                  24.verticalSpace,
                  CommonText(
                    string: AppString.identityVeri.tr,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  customWidget(
                    title: AppString.govId.tr,
                    subtitle: AppString.uploadGovId.tr,
                    onTap: () {
                      Navigation.pushNamed(Routes.uploadScreen);
                    },
                    isUpload: false,
                  ),
                  Obx(
                    () => customWidget(
                      title: AppString.liveSelfie.tr,
                      subtitle: AppString.openCameraLive.tr,
                      onTap: () async {
                        var camera = await Permission.camera.status;
                        var microphone = await Permission.microphone.status;
                        print("Status::${camera}");
                        print("Status::${microphone}");

                        if (!(camera.isGranted && microphone.isGranted)) {
                          camera = await Permission.camera.request();
                          microphone = await Permission.microphone.request();

                          if (!(camera.isGranted && microphone.isGranted)) {
                            camera = await Permission.camera.request();
                            microphone = await Permission.microphone.request();

                            if (!(camera.isGranted && microphone.isGranted)) {
                              await openAppSettings();
                              return;
                            }
                          }
                        }

                        if (camera.isGranted && microphone.isGranted) {
                          debugPrint(
                            ">>>>${camera.isGranted}>>>>${microphone.isGranted}",
                          );
                          final result = await Get.to(() => CameraScreen());
                          if (result != null) {
                            liveSelfiImg.value = result;
                          }
                        }
                      },
                      isUpload: liveSelfiImg.value != null,
                    ),
                  ),


                  24.verticalSpace,
                ],
              ).paddingSymmetric(horizontal: 16.w),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        bottom: Utils().checkPlatForm,

        child: CustomButton(
          text: AppString.submit.tr,
          onTap: () {
            if (makeController.text.trim().textDataIsNotValid(
                  AppString.pleaseEnterVehicleDetails.tr,
                ) ||
                modelController.text.trim().textDataIsNotValid(
                  AppString.pleaseEnterVehicleDetails.tr,
                ) ||
                yearController.text.trim().textDataIsNotValid(
                  AppString.pleaseEnterVehicleDetails.tr,
                )) {
              return;
            }

            if (checkDoc() == false) {
              AppSnackBar.showErrorSnackBar(message: errorShow, isError: true);
              return;
            } else if (liveSelfiImg.value == null) {
              AppSnackBar.showErrorSnackBar(
                message: AppString.pleaseUploadLiveSelfi.tr,
                isError: true,
              );
              return;
            }

            List<String> nameList = userDoc.keys.map((file) => file).toList();
            List<String> imageList = userDoc.values
                .map((file) => file.path)
                .toList();

            nameList.add("selfi");
            imageList.add(liveSelfiImg.value?.path ?? "");
            controller.documentUpload(
              year: yearController.text.trim(),
              model: modelController.text.trim(),
              make: makeController.text.trim(),
              fileNameList: nameList,
              imageList: imageList,
            );
          },
        ).paddingOnly(left: 16.w, right: 16.w, bottom: 24.h),
      ),
    );
  }

  String errorShow = "";

  bool checkDoc() {
    for (var type in controller.requiredMap.keys) {
      for (var doc in controller.requiredMap[type]!) {
        if (!userDoc.containsKey(doc.key)) {
          errorShow = "${doc.name} is required!";
          return false;
        }
      }
    }
    return true;
  }

  void showImageUploadDia({
    required String title,
    required String subTitle,
    required Rx<XFile?> file,
    required VoidCallback uploadTap,
    required VoidCallback viewTap,
  }) {
    FocusScope.of(context).unfocus();
    AppDialog.commonDialog(
      childs: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 40.h,
            width: 40.h,
            decoration: BoxDecoration(
              color: AppColors.titleTextColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            alignment: Alignment.center,
            child: CustomImage(image: ImagesAsset.docSvg, ht: 24.h, wt: 24.h),
          ),
          CommonText(
            string: title,
            color: AppColors.mainPrimaryColor,
            fontWeight: FontWeight.w500,
            fontSize: 16.sp,
          ).paddingSymmetric(vertical: 4.h),
          CommonText(
            string: subTitle,
            color: AppColors.bodyText,
            softWrap: true,
          ),
          16.verticalSpace,
          GestureDetector(
            onTap: uploadTap,
            child: Container(
              height: 40.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: AppColors.primaryContainer,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CommonText(string: AppString.uploadDoc.tr, fontSize: 16.sp),
                  4.horizontalSpace,
                  Icon(Icons.arrow_forward_ios, size: 18),
                ],
              ),
            ),
          ),

          if (file.value != null)
            GestureDetector(
              onTap: viewTap,
              child: Container(
                height: 40.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: AppColors.primaryContainer,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CommonText(
                      string: AppString.viewDocument.tr,
                      fontSize: 16.sp,
                    ),
                  ],
                ),
              ),
            ).paddingOnly(top: 16.h),
        ],
      ),
    );
  }

  Widget customWidget({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isUpload,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        margin: EdgeInsets.only(top: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: AppColors.whiteColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    string: title,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  CommonText(
                    string: isUpload ? AppString.docUploaded.tr : subtitle,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: isUpload
                        ? AppColors.successColor
                        : AppColors.bodyText,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}
