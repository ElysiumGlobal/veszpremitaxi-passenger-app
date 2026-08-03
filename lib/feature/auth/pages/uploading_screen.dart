import 'dart:io';

import 'package:e_taxi/feature/auth/controller/register_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../widgets/custom_button.dart';

class UploadingScreen extends StatefulWidget {
  const UploadingScreen({super.key});

  @override
  State<UploadingScreen> createState() => _UploadingScreenState();
}

class _UploadingScreenState extends State<UploadingScreen> {
  final controller = Get.find<RegisterController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(centerTitle: false, title: AppString.govId.tr),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w).copyWith(right: 0),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  textWidget(AppString.uploadClearDoc.tr),
                  10.verticalSpace,
                  textWidget(AppString.docAreVisiable.tr),
                  10.verticalSpace,
                  textWidget(AppString.onlyjpgPng.tr),
                  10.verticalSpace,
                  textWidget(AppString.maxSize.tr),
                  10.verticalSpace,
                  textWidget(AppString.multiSideDoc.tr),
                  10.verticalSpace,
                  textWidget(AppString.notExpire.tr),
                  10.verticalSpace,
                  textWidget(AppString.notUploadFake.tr),
                ],
              ),
            ).paddingSymmetric(vertical: 24.h),

            CommonText(
              string: AppString.govIdInstructions.tr,
              fontSize: 16.sp,
              softWrap: true,
            ),
            16.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => controller.docFront.value != null
                        ? Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.file(
                                File(controller.docFront.value?.path ?? ""),
                                height: 96.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              GestureDetector(
                                onTap: () {
                                  controller.docFront.value = null;
                                },
                                child: Container(
                                  height: 24.w,
                                  width: 24.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteColor,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: CustomImage(image: IconAsset.close),
                                ),
                              ),
                            ],
                          )
                        : docWidget(AppString.uploadFront.tr, () async {
                            final img = await Utils().getImage();
                            if (img != null) {
                              controller.docFront.value = img;
                            }
                          }),
                  ),
                ),
                16.horizontalSpace,

                Expanded(
                  child: Obx(
                    () => controller.docBack.value != null
                        ? Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.file(
                                File(controller.docBack.value?.path ?? ""),
                                height: 96.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              GestureDetector(
                                onTap: () {
                                  controller.docBack.value = null;
                                  controller.govDocUpload = false;
                                },
                                child: Container(
                                  height: 24.w,
                                  width: 24.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteColor,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: CustomImage(image: IconAsset.close),
                                ),
                              ),
                            ],
                          )
                        : docWidget(AppString.uploadBack.tr, () async {
                            final img = await Utils().getImage();
                            if (img != null) {
                              controller.docBack.value = img;
                            }
                          }),
                  ),
                ),
              ],
            ),
          ],
        ).paddingSymmetric(horizontal: 16.w),
      ),
      bottomNavigationBar: SafeArea(
        bottom: Utils().checkPlatForm,

        child: CustomButton(
          text: AppString.uploadDoc.tr,
          onTap: () async {
            if (controller.docFront.value == null) {
              AppSnackBar.showErrorSnackBar(
                message: AppString.pleaseUploadFrontDoc.tr,
              );
              return;
            } else if (controller.docBack.value == null) {
              AppSnackBar.showErrorSnackBar(
                message: AppString.pleaseUploadBackDoc.tr,
              );
              return;
            }

            final res = await controller.govIdUpload([
              controller.docFront.value?.path ?? "",
              controller.docBack.value?.path ?? "",
            ]);

            if (res) {
              Get.back();
              AppSnackBar.showErrorSnackBar(
                message: "Document Upload Successfully",
              );
            }
          },
        ).paddingOnly(left: 16.w, right: 16.w, bottom: 24.h),
      ),
    );
  }

  Widget textWidget(String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 8.h,
          width: 8.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.mainPrimaryColor,
          ),
        ),
        12.horizontalSpace,
        Expanded(
          child: CommonText(
            string: title,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Widget docWidget(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 96.h,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.mainPrimaryColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomImage(image: ImagesAsset.docSvg, ht: 32.h, wt: 32.h),
            12.verticalSpace,
            CommonText(string: title, fontSize: 14.sp),
          ],
        ),
      ),
    );
  }
}
