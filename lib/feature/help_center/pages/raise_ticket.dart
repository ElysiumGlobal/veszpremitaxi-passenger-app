import 'dart:io';

import 'package:e_taxi/feature/help_center/controller/helpCenter_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../utils/app_string.dart';
import '../../../utils/assets.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custome_img.dart';

class RaiseTickerScreen extends StatefulWidget {
  final String title;
  final String subject;

  const RaiseTickerScreen({
    required this.title,
    required this.subject,
    super.key,
  });

  @override
  State<RaiseTickerScreen> createState() => _RaiseTickerScreenState();
}

class _RaiseTickerScreenState extends State<RaiseTickerScreen> {
  RxList<XFile> imageList = <XFile>[].obs;
  String des = "";
  final _helpController = Get.find<HelpCenterController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerTitle: false,
        title: AppString.supportTicket.tr,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: AppColors.whiteColor,
              border: Border.all(color: AppColors.textFieldBorderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  string: widget.title,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                Divider(color: AppColors.textFieldBorderColor),
                CommonText(
                  string: AppString.describeDetails.tr,
                  fontWeight: FontWeight.w500,
                ),
                4.verticalSpace,
                CustomTextField(
                  controller: TextEditingController(),
                  hintText: "Enter the issue...",
                  onChanged: (v) {
                    des = v;
                  },
                ),
              ],
            ),
          ),
          24.verticalSpace,

          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: AppColors.whiteColor,
              border: Border.all(color: AppColors.textFieldBorderColor),
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
                    if (imageList.length < 3) {
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
            ),
          ),
        ],
      ).paddingOnly(left: 16.w, right: 16.w, top: 24.h),
      bottomNavigationBar: SafeArea(
        bottom: Utils().checkPlatForm,

        child: CustomButton(
          text: AppString.submitTicket.tr,
          onTap: () async {
            if (des.isEmpty) {
              AppSnackBar.showErrorSnackBar(
                message: AppString.pleaseEnterDes.tr,
                isError: true,
              );
              return;
            }
            Map data = await _helpController.raiseTicket(
              des: des,
              title: widget.subject,
              imagePath: imageList.isEmpty
                  ? []
                  : imageList.map((element) => element.path).toList(),
            );
            if (data.isNotEmpty) {
              Get.back();
              AppSnackBar.showErrorSnackBar(message: data['message']);
              _helpController.getContactSupport();
            }
          },
        ).paddingOnly(left: 16.w, right: 16.w, bottom: 16.w),
      ),
    );
  }
}
