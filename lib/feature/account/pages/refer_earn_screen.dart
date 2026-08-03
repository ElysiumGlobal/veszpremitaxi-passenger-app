import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:e_taxi/feature/account/controller/account_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/constants.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../utils/app_string.dart';
import '../../../utils/utils.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_button.dart';

class ReferEarnScreen extends StatefulWidget {
  const ReferEarnScreen({super.key});

  @override
  State<ReferEarnScreen> createState() => _ReferEarnScreenState();
}

class _ReferEarnScreenState extends State<ReferEarnScreen> {
  final accountController = Get.find<AccountController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      appBar: CustomAppBar(title: AppString.referEarn.tr, centerTitle: false),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              40.verticalSpace,
              Center(
                child: CustomImage(image: ImagesAsset.referEarn, ht: 280.h),
              ),
              23.verticalSpace,
              CommonText(
                string:
                    "Refer your friends & earn ${Utils.formatCurrency("100")}!",
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
              ),

              8.verticalSpace,
              CommonText(
                string:
                    "Your friend gets 10% off on their first order.  Share your code now!",
                softWrap: true,
                textAlign: TextAlign.center,
                color: AppColors.textCaptionColor,
              ),
              33.verticalSpace,
              Align(
                alignment: Alignment.centerLeft,
                child: CommonText(
                  string: AppString.yourReferCode.tr,
                  fontSize: 16.sp,
                ),
              ),
              12.verticalSpace,
              DottedBorder(
                options: RectDottedBorderOptions(
                  dashPattern: [5, 5],
                  strokeWidth: 1,
                  color: AppColors.textFieldBorderColor,
                ),
                child: Container(
                  color: AppColors.whiteColor,
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonText(
                        string:
                            "${accountController.userModel.value?.referralCode}",
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(
                              text:
                                  "${accountController.userModel.value?.referralCode}",
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppString.copyClipboard.tr)),
                          );
                        },
                        child: Container(
                          height: 28.h,
                          width: 28.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            color: AppColors.whiteGrey,
                          ),
                          alignment: Alignment.center,
                          child: CustomImage(
                            image: IconAsset.copy,
                            ht: 20.h,
                            wt: 20.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              16.verticalSpace,
              CustomButton(
                onTap: () {
                  final box = context.findRenderObject() as RenderBox?;
                  String link = Platform.isAndroid
                      ? Constants().androidLink
                      : Constants().iosLink;
                  SharePlus.instance.share(
                    ShareParams(
                      text:
                          "${Constants().appName}, Referral Code : ${accountController.userModel.value?.referralCode ?? ""}\n\n$link",

                      sharePositionOrigin:
                          box!.localToGlobal(Offset.zero) & box.size,
                    ),
                  );
                },
                text: AppString.shareCode.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
