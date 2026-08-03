import 'package:e_taxi/feature/account/controller/account_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../utils/app_string.dart';
import '../../../utils/utils.dart';
import '../../../widgets/dialog.dart';
import '../../auth/widget/subtitle_title_widget.dart';
import '../../auth/widget/view_image.dart';

class DocumentProfileScreen extends StatefulWidget {
  const DocumentProfileScreen({super.key});

  @override
  State<DocumentProfileScreen> createState() => _DocumentProfileScreenState();
}

class _DocumentProfileScreenState extends State<DocumentProfileScreen> {
  final accountController = Get.find<AccountController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      accountController.getUserData(checkDocument: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppString.document.tr, centerTitle: false),
      body: SafeArea(
        bottom: Utils().checkPlatForm,

        child: SingleChildScrollView(
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.verticalSpace,
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: AppColors.whiteColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SubtitleTitleWidget(
                        title: AppString.make.tr,
                        subTitle:
                            accountController.userModel.value?.vehicle?.brand ??
                            "",
                        sectitle: AppString.model.tr,
                        secsubTitle:
                            accountController.userModel.value?.vehicle?.model ??
                            "",
                        thirdtitle: AppString.year.tr,
                        thirdsubTitle:
                            accountController.userModel.value?.vehicle?.year ??
                            "",
                      ),
                      Divider(
                        color: AppColors.textFieldBorderColor,
                      ).paddingSymmetric(vertical: 10.h),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CommonText(
                                    string: AppString.registerNumber.tr,
                                    color: AppColors.textCaptionColor,
                                  ),
                                  6.verticalSpace,
                                  CommonText(
                                    string:
                                        accountController
                                            .userModel
                                            .value
                                            ?.vehicle
                                            ?.registrationNumber ??
                                        "",
                                  ),
                                ],
                              ),
                            ),
                            VerticalDivider(
                              color: AppColors.textFieldBorderColor,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CommonText(
                                    string: AppString.rideType.tr,
                                    color: AppColors.textCaptionColor,
                                  ),
                                  CommonText(
                                    string:
                                        "${accountController.userModel.value?.vehicle?.rideTypeName ?? ""}",
                                    color: AppColors.textCaptionColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                16.verticalSpace,

                if ((accountController.userModel.value?.vehicleDocuments ?? [])
                    .isNotEmpty)
                  CommonText(
                    string: AppString.vehicleDoc.tr,
                    fontSize: 16.sp,
                  ).paddingOnly(bottom: 6.h),
                ...(accountController.userModel.value?.vehicleDocuments ?? []).map((
                  e,
                ) {
                  return GestureDetector(
                    onTap: () async {
                      if ((e.status == "pending" &&
                              (e.fileFrontUrl ?? "").isEmpty) ||
                          e.status == "rejected") {
                        showImageUploadDia(
                          file: Rx(accountController.userDoc[e.type] ?? null),
                          title: e.type ?? "",
                          subTitle: "",
                          uploadTap: () async {
                            final image = await Utils().getImage();
                            if (image != null) {
                              accountController.userDoc.putIfAbsent(
                                "${e.type}",
                                () => XFile(""),
                              );
                              accountController.userDoc["${e.type}"] = image;
                              Get.back();
                            }
                          },
                          viewTap: () {
                            Get.back();
                            Get.to(
                              () => ViewImage(
                                image:
                                    accountController
                                        .userDoc["${e.type}"]
                                        ?.path ??
                                    "",
                                title: (e.name ?? "") == "Selfi"
                                    ? "Selfie"
                                    : e.name ?? "",
                              ),
                            );
                          },
                        );
                      } else {
                        Get.to(
                          () => ViewImage(
                            image: e.fileFrontUrl ?? "",
                            title: e.type ?? "",
                          ),
                        );
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.w),
                          margin: EdgeInsets.only(bottom: 16.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.textFieldBorderColor,
                            ),
                            color: AppColors.whiteColor,
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 40.h,
                                width: 40.h,
                                padding: EdgeInsets.all(8.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24.r),
                                  color: getBgColor(e.status ?? ""),
                                ),
                                alignment: Alignment.center,
                                child: (e.status == "pending")
                                    ? CustomImage(image: IconAsset.infoCircle1)
                                    : CustomImage(image: IconAsset.copyRight),
                              ),
                              10.horizontalSpace,
                              Expanded(
                                child: CommonText(
                                  string: (e.name ?? "") == "Selfi"
                                      ? "Selfie"
                                      : e.name ?? "",
                                ),
                              ),
                              10.horizontalSpace,
                              Icon(CupertinoIcons.right_chevron),
                            ],
                          ),
                        ),
                        if ((e.rejectionReason ?? "").isNotEmpty) ...{
                          CommonText(
                            string:
                                "${AppString.reason.tr} : ${e.rejectionReason ?? ""}",
                            color: AppColors.errorColor,
                            softWrap: true,
                          ).paddingOnly(top: 4.h),
                        },
                      ],
                    ),
                  );
                }).toList(),
                if ((accountController.userModel.value?.documents ?? [])
                    .isNotEmpty)
                  CommonText(
                    string: AppString.driverDoc.tr,
                    fontSize: 16.sp,
                  ).paddingOnly(bottom: 6.h),
                ...(accountController.userModel.value?.documents ?? []).map((
                  e,
                ) {
                  return GestureDetector(
                    onTap: () async {
                      if ((e.status == "pending" &&
                              (e.fileFrontUrl ?? "").isEmpty) ||
                          e.status == "rejected") {
                        showImageUploadDia(
                          file: Rx(accountController.userDoc[e.type] ?? null),
                          title: e.type ?? "",
                          subTitle: "",
                          uploadTap: () async {
                            final image = await Utils().getImage();
                            if (image != null) {
                              accountController.userDoc.putIfAbsent(
                                "${e.type}",
                                () => XFile(""),
                              );
                              accountController.userDoc["${e.type}"] = image;
                              Get.back();
                            }
                          },
                          viewTap: () {
                            Get.back();
                            Get.to(
                              () => ViewImage(
                                image:
                                    accountController
                                        .userDoc["${e.type}"]
                                        ?.path ??
                                    "",
                                title: (e.name ?? "") == "Selfi"
                                    ? "Selfie"
                                    : e.name ?? "",
                              ),
                            );
                          },
                        );
                      } else {
                        Get.to(
                          () => ViewImage(
                            image: e.fileFrontUrl ?? "",
                            title: e.type ?? "",
                          ),
                        );
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.w),
                          margin: EdgeInsets.only(bottom: 16.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.textFieldBorderColor,
                            ),
                            color: AppColors.whiteColor,
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 40.h,
                                width: 40.h,
                                padding: EdgeInsets.all(8.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24.r),
                                  color: getBgColor(e.status ?? ""),
                                ),
                                alignment: Alignment.center,
                                child: (e.status == "pending")
                                    ? CustomImage(image: IconAsset.infoCircle1)
                                    : CustomImage(image: IconAsset.copyRight),
                              ),
                              10.horizontalSpace,
                              Expanded(
                                child: CommonText(
                                  string: (e.name ?? "") == "Selfi"
                                      ? "Selfie"
                                      : e.name ?? "",
                                ),
                              ),
                              10.horizontalSpace,
                              Icon(CupertinoIcons.right_chevron),
                            ],
                          ),
                        ),
                        if ((e.rejectionReason ?? "").isNotEmpty) ...{
                          CommonText(
                            string:
                                "${AppString.reason.tr} : ${e.rejectionReason ?? ""}",
                            color: AppColors.errorColor,
                            softWrap: true,
                          ).paddingOnly(top: 4.h),
                        },
                      ],
                    ),
                  );
                }).toList(),

                Obx(
                  () => accountController.userDoc.isEmpty
                      ? SizedBox.shrink()
                      : CustomButton(
                          text: AppString.submit.tr,
                          onTap: () {
                            if (accountController.userDoc.isEmpty) {
                              return;
                            }

                            List<String> nameList = accountController
                                .userDoc
                                .keys
                                .map((file) => file)
                                .toList();
                            List<String> imageList = accountController
                                .userDoc
                                .values
                                .map((file) => file.path)
                                .toList();
                            accountController.uploadDoc(
                              fileNameList: nameList,
                              imageList: imageList,
                            );
                          },
                        ).paddingSymmetric(vertical: 16.h),
                ),
              ],
            ).paddingSymmetric(horizontal: 16.w),
          ),
        ),
      ),
    );
  }

  Color getBgColor(String value) {
    switch (value) {
      case "pending":
        return AppColors.warningBgColor;
      case "rejected":
        return AppColors.errorBgColor;
      default:
        return AppColors.whiteGrey;
    }
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
          4.verticalSpace,
          CommonText(
            string: "${AppString.uploadDoc.tr} $title",
            color: AppColors.mainPrimaryColor,
            fontWeight: FontWeight.w500,
            fontSize: 16.sp,
            softWrap: true,
          ).paddingSymmetric(vertical: 4.h),
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
