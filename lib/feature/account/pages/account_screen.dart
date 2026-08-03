import 'dart:io';

import 'package:e_taxi/feature/account/controller/account_controller.dart';
import 'package:e_taxi/utils/constants.dart';
import 'package:e_taxi/utils/log_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_preferences.dart';
import '../../../utils/app_string.dart';
import '../../../utils/assets.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/cacheNetworkImage.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custome_img.dart';
import '../../../widgets/dialog.dart';
import '../../../widgets/webview_screen.dart';
import 'cash_point_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final accountController = Get.find<AccountController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppString.account.tr,
        centerTitle: false,
      ),
      body: SafeArea(
        bottom: Utils().checkPlatForm,

        child: RefreshIndicator(
          onRefresh: () async {
            await accountController.getUserData(
              checkDocument: true,
              rideRedirect: true,
            );
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.whiteColor,
                    border: Border.all(color: AppColors.mainPrimaryColor),
                  ),
                  child: Obx(
                    () => Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),

                          child: NetworkImageWidget(
                            image:
                                accountController
                                    .userModel
                                    .value
                                    ?.profilePhoto ??
                                "",
                            ht: 62.w,
                            wt: 62.w,
                            radius: 50.r,
                          ),
                        ),
                        10.horizontalSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                string:
                                    accountController.userModel.value?.name ??
                                    "",
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              8.verticalSpace,
                              CommonText(
                                string:
                                    "${accountController.userModel.value?.countryCode} ${accountController.userModel.value?.phone}",
                                fontSize: 14.sp,
                              ),
                            ],
                          ),
                        ),
                        10.horizontalSpace,
                        GestureDetector(
                          onTap: () {
                            Navigation.pushNamed(Routes.editProfileScreen);
                          },
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: AppColors.whiteGrey,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: CustomImage(
                              image: IconAsset.edit,
                              wt: 24.h,
                              ht: 24.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                24.verticalSpace,
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.w,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.whiteColor,
                    border: Border.all(color: AppColors.textFieldBorderColor),
                  ),
                  child: Column(
                    children: [
                      commonWidget(
                        image: IconAsset.document,
                        title: AppString.document.tr,
                        onTap: () {
                          Navigation.pushNamed(Routes.documentProfileScreen);
                        },
                      ),

                      Divider(
                        color: AppColors.textFieldBorderColor,
                      ).paddingSymmetric(vertical: 5.h),
                      commonWidget(
                        image: IconAsset.locationTick,
                        title: AppString.savedLocation.tr,
                        onTap: () {
                          Navigation.pushNamed(Routes.saveLocationScreen);
                        },
                      ),
                      Divider(
                        color: AppColors.textFieldBorderColor,
                      ).paddingSymmetric(vertical: 5.h),
                      commonWidget(
                        image: IconAsset.statusUp,
                        title: AppString.myPerformance.tr,
                        onTap: () {
                          Navigation.pushNamed(Routes.preferenceScreen);
                        },
                      ),
                    ],
                  ),
                ),
                16.verticalSpace,

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.w,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.whiteColor,
                    border: Border.all(color: AppColors.textFieldBorderColor),
                  ),
                  child: Column(
                    children: [
                      commonWidget(
                        image: IconAsset.gift,
                        title: AppString.referEarn.tr,
                        onTap: () {
                          Navigation.pushNamed(Routes.referEarnScreen);
                        },
                      ),
                      Divider(
                        color: AppColors.textFieldBorderColor,
                      ).paddingSymmetric(vertical: 5.h),
                      commonWidget(
                        image: IconAsset.notification,
                        title: AppString.notification.tr,
                        onTap: () {
                          Navigation.pushNamed(Routes.notificationScreen);
                        },
                      ),
                      Divider(
                        color: AppColors.textFieldBorderColor,
                      ).paddingSymmetric(vertical: 5.h),
                      commonWidget(
                        image: IconAsset.languageSquare,
                        title: AppString.language.tr,
                        onTap: () {
                          Navigation.pushNamed(Routes.languageScreen);
                        },
                      ),

                      Divider(
                        color: AppColors.textFieldBorderColor,
                      ).paddingSymmetric(vertical: 5.h),
                      commonWidget(
                        image: IconAsset.languageSquare,
                        title: AppString.cashCollectionPoint.tr,
                        onTap: () {
                          Get.to(() => CashCollectionPointScreen());
                        },
                      ),
                    ],
                  ),
                ),
                16.verticalSpace,

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.w,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.whiteColor,
                    border: Border.all(color: AppColors.textFieldBorderColor),
                  ),
                  child: Column(
                    children: [
                      commonWidget(
                        image: IconAsset.callAdd,
                        title: AppString.contactUS.tr,
                        onTap: () {
                          Get.to(
                            () => WebviewScreen(webUrl: Constants().contactUs),
                          );
                        },
                      ),
                      Divider(
                        color: AppColors.textFieldBorderColor,
                      ).paddingSymmetric(vertical: 5.h),
                      commonWidget(
                        image: IconAsset.share,
                        title: AppString.shareApp.tr,
                        onTap: () {
                          final box = context.findRenderObject() as RenderBox?;

                          String link = Platform.isAndroid
                              ? Constants().androidLink
                              :Constants().iosLink;
                          SharePlus.instance.share(
                            ShareParams(
                              text:
                                  "${Constants().appName}, Referral Code : ${accountController.userModel.value?.referralCode ?? ""}\n\n$link",
                              sharePositionOrigin:
                                  box!.localToGlobal(Offset.zero) & box.size,
                            ),
                          );
                        },
                      ),
                      Divider(
                        color: AppColors.textFieldBorderColor,
                      ).paddingSymmetric(vertical: 5.h),
                      commonWidget(
                        image: IconAsset.ranking,
                        title: AppString.rateUs.tr,
                        onTap: () async {
                          try {
                            final InAppReview inAppReview =
                                InAppReview.instance;
                            await inAppReview.openStoreListing(
                              appStoreId: Constants().appStoreId,
                            );
                          } catch (e, st) {
                            LogUtils.printError("ERROR ::$e,$st");
                          }
                        },
                      ),
                    ],
                  ),
                ),
                16.verticalSpace,

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.w,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.whiteColor,
                    border: Border.all(color: AppColors.textFieldBorderColor),
                  ),
                  child: Column(
                    children: [
                      commonWidget(
                        image: IconAsset.callAdd,
                        title: AppString.privacyPolicy.tr,
                        onTap: () {
                          Get.to(
                            () => WebviewScreen(
                              webUrl: Constants().privacyPolicy,
                            ),
                          );
                        },
                      ),
                      Divider(
                        color: AppColors.textFieldBorderColor,
                      ).paddingSymmetric(vertical: 5.h),
                      commonWidget(
                        image: IconAsset.note,
                        title: AppString.termOfService.tr,
                        onTap: () {
                          Get.to(
                            () => WebviewScreen(
                              webUrl: Constants().termsCondition,
                            ),
                          );
                        },
                      ),
                      Divider(
                        color: AppColors.textFieldBorderColor,
                      ).paddingSymmetric(vertical: 5.h),
                      commonWidget(
                        image: IconAsset.infoCircle1,
                        title: AppString.aboutUs.tr,
                        onTap: () {
                          Get.to(
                            () => WebviewScreen(webUrl: Constants().aboutUs),
                          );
                        },
                      ),
                      Divider(
                        color: AppColors.textFieldBorderColor,
                      ).paddingSymmetric(vertical: 5.h),
                      commonWidget(
                        image: IconAsset.delete,
                        title: AppString.deleteAccount.tr,
                        onTap: () {
                          AppDialog.commonDialog(
                            barrierDismiss: false,
                            childs: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomImage(
                                  image: ImagesAsset.deleteImage,
                                  ht: 168.h,
                                ),
                                16.verticalSpace,
                                CommonText(
                                  string: AppString.waitDeleteAccount.tr,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                12.verticalSpace,
                                CommonText(
                                  string: AppString.deleteAccountText.tr,
                                  fontSize: 14.sp,
                                  color: AppColors.textCaptionColor,
                                ),
                                16.verticalSpace,
                                CustomButton(
                                  text: AppString.noTakeMeBack.tr,
                                  onTap: () {
                                    Navigation.pop();
                                  },
                                ),
                                16.verticalSpace,
                                CustomButton(
                                  text: AppString.yesDeleteEverything.tr,
                                  buttonColor: AppColors.whiteColor,
                                  borderColor: AppColors.titleTextColor,
                                  onTap: () async {
                                    var map;

                                    if (accountController
                                                .userModel
                                                .value
                                                ?.email ==
                                            "driver@yopmail.com" ||
                                        accountController
                                                .userModel
                                                .value
                                                ?.email ==
                                            "dwight@yopmail.com" ||
                                        accountController
                                                .userModel
                                                .value
                                                ?.email ==
                                            "reacher@yopmail.com") {
                                      map = await accountController
                                          .userAccountLogout();
                                    } else {
                                      map = await accountController
                                          .userAccountDelete();
                                    }

                                    if (map.isNotEmpty) {
                                      Navigation.pop();
                                      await AppPreference.clearSharedPreferences();
                                      Navigation.replaceAll(
                                        Routes.registerScreen,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                16.verticalSpace,

                CustomButton(
                  text: AppString.logOutAccount.tr,
                  prefixIconWidget: Container(
                    margin: EdgeInsets.only(right: 12.w),
                    height: 30.h,
                    width: 30.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: AppColors.blackColor,
                    ),
                    alignment: Alignment.center,
                    child: CustomImage(
                      image: IconAsset.logout,
                      ht: 18.h,
                      wt: 18.h,
                    ),
                  ),
                  onTap: () {
                    AppDialog.commonDialog(
                      barrierDismiss: false,
                      childs: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomImage(
                            image: ImagesAsset.logoutImage,
                            ht: 168.h,
                          ),
                          16.verticalSpace,
                          CommonText(
                            string: AppString.dontLeaveHanging.tr,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          12.verticalSpace,
                          CommonText(
                            string: AppString.logOutString.tr,
                            fontSize: 14.sp,
                            color: AppColors.textCaptionColor,
                          ),
                          16.verticalSpace,
                          CustomButton(
                            text: AppString.cancelIStay.tr,
                            onTap: () async {
                              Navigation.pop();
                            },
                          ),
                          16.verticalSpace,
                          CustomButton(
                            text: AppString.yesLogOut.tr,
                            buttonColor: AppColors.whiteColor,
                            borderColor: AppColors.titleTextColor,
                            onTap: () async {
                              final map = await accountController
                                  .userAccountLogout();
                              if (map.isNotEmpty) {
                                Navigation.pop();
                                await AppPreference.clearSharedPreferences();
                                Navigation.replaceAll(Routes.registerScreen);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                20.verticalSpace,
              ],
            ).paddingSymmetric(horizontal: 16.w, vertical: 24.w),
          ),
        ),
      ),
    );
  }

  Widget commonWidget({
    required String image,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.whiteGrey,
            ),
            alignment: Alignment.center,
            child: CustomImage(
              image: image,
              ht: 18.w,
              wt: 18.w,
              color: AppColors.blackColor,
            ),
          ),
          10.horizontalSpace,
          CommonText(
            string: title,
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}
