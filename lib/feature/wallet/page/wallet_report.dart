import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:e_taxi/feature/wallet/controller/wallet_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../utils/app_string.dart';
import '../../../utils/assets.dart';
import '../../../utils/utils.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custome_img.dart';

class WalletReportScreen extends StatefulWidget {
  const WalletReportScreen({
    required this.bookingId,
    required this.tranactionId,
    super.key,
  });

  final String bookingId;
  final String tranactionId;

  @override
  State<WalletReportScreen> createState() => _WalletReportScreenState();
}

class _WalletReportScreenState extends State<WalletReportScreen> {
  List<String> _title = [
    AppString.passengerNotShow,
    AppString.incorrectCancelFeeChange,
    AppString.routeBlockTrafficIssues,
    AppString.riderShareWrongLocation,
    AppString.navigationAppError,
    AppString.other,
  ];
  RxInt selectedIndex = 0.obs;
  final walletController = Get.find<WalletController>();

  String reason = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppString.reportIssue.tr, centerTitle: false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.maxFinite,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.textFieldBorderColor),
              ),
              child: Column(
                children: [
                  CommonText(
                    string: AppString.pleaseSelectReasonForReportingFee.tr,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    softWrap: true,
                  ),
                  Divider(
                    color: AppColors.textFieldBorderColor,
                  ).paddingSymmetric(vertical: 12.h),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Obx(
                        () => checkBoxWidget(
                          onTap: () {
                            selectedIndex.value = index;
                          },
                          title: _title[index].tr,
                          isSelected: selectedIndex.value == index,
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => 16.verticalSpace,
                    itemCount: _title.length,
                  ),

                  Obx(
                    () => selectedIndex.value == _title.length - 1
                        ? CustomTextField(
                            controller: TextEditingController(),
                            hintText: "Enter the reason",
                            onChanged: (v) {
                              reason = v;
                            },
                          ).paddingOnly(top: 16.h)
                        : SizedBox.shrink(),
                  ),
                  16.verticalSpace,
                  DottedBorder(
                    options: RectDottedBorderOptions(
                      dashPattern: [5, 5],
                      strokeWidth: 1,
                      color: AppColors.textFieldBorderColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          string: AppString.uploadScreenshot.tr,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                        16.verticalSpace,

                        Obx(
                          () => imageList.isEmpty
                              ? SizedBox.shrink()
                              : SizedBox(
                                  height: 116.h,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    padding: EdgeInsets.only(bottom: 16.h),
                                    itemBuilder: (context, index) {
                                      return Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          Image.file(
                                            (File(imageList[index].path)),
                                            height: 100.h,
                                            width: 110.w,
                                            fit: BoxFit.cover,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              imageList.removeAt(index);
                                            },
                                            child: Container(
                                              height: 24.w,
                                              width: 24.w,
                                              decoration: BoxDecoration(
                                                color: AppColors.whiteColor,
                                                shape: BoxShape.circle,
                                              ),
                                              alignment: Alignment.center,
                                              child: CustomImage(
                                                image: IconAsset.close,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return 16.horizontalSpace;
                                    },
                                    itemCount: imageList.length,
                                  ),
                                ),
                        ),
                        CustomButton(
                          buttonColor: AppColors.textFieldBorderColor,
                          text: AppString.uploadFile.tr,
                          prefixIconWidget: CustomImage(
                            image: IconAsset.add,
                            ht: 20.h,
                            wt: 20.h,
                          ).paddingOnly(right: 4.w),
                          onTap: () async {
                            if (imageList.length <= 3) {
                              XFile? image = await Utils().getImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                imageList.add(image);
                                imageList.refresh();
                              }
                            }
                          },
                        ),
                      ],
                    ).paddingAll(8.w),
                  ),
                ],
              ),
            ),
          ],
        ).paddingAll(16.w),
      ),
      bottomNavigationBar: SafeArea(
        bottom: Utils().checkPlatForm,

        child: CustomButton(
          text: AppString.submit.tr,
          onTap: () async {
            if (selectedIndex.value == _title.length - 1 && reason.isEmpty) {
              AppSnackBar.showErrorSnackBar(
                message: AppString.enterYourReason.tr,
                isError: true,
              );
              return;
            } else if (selectedIndex.value != _title.length - 1) {
              reason = "default";
            }

            final res = await walletController.earningReportIssue(
              disputeReason: _title[selectedIndex.value],
              imageList: imageList.map((element) => element.path).toList(),
              bookingId: widget.bookingId,
              msg: reason,
              transactionId: widget.tranactionId,
            );
            if (res.isNotEmpty) {
              Get.back();
              AppSnackBar.showErrorSnackBar(message: res['message']);
            }
          },
        ).paddingOnly(left: 16.w, right: 16.w, bottom: 16.w),
      ),
    );
  }

  RxList<XFile> imageList = <XFile>[].obs;

  Widget checkBoxWidget({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            height: 24.h,
            width: 24.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.r),
              color: isSelected ? AppColors.greenColor : AppColors.whiteColor,
              border: Border.all(
                color: isSelected
                    ? AppColors.transparent
                    : AppColors.titleTextColor,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.done, size: 12, color: AppColors.whiteColor),
          ),
          12.horizontalSpace,
          CommonText(
            string: title,
            fontSize: 14.sp,
            softWrap: true,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ],
      ),
    );
  }
}
