import 'dart:io';

import 'package:e_taxi/feature/home/widget/dialog.dart';
import 'package:e_taxi/feature/profile/controller/profile_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_preferences.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/constants.dart';
import 'package:e_taxi/utils/navigation_utils/navigation.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

import '../../../utils/app_string.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/cachenetworkimage.dart';
import '../../../widgets/webview_screen.dart';
import '../../home/controller/home_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List iconList = [
    IconAsset.notification,
    IconAsset.safety,
    IconAsset.refer,
    IconAsset.language,
    IconAsset.rate,
    IconAsset.share,
    IconAsset.contact,
    IconAsset.about,
    IconAsset.privacy,
    IconAsset.term,
    IconAsset.delete,
  ];

  final profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      appBar: CustomAppBar(
        title: AppString.profile.tr,
        centerTitle: false,
        leading: SizedBox(width: 16.w),
        leadingSize: 16.w,
        titleTextSize: 20.sp,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: RefreshIndicator(
          onRefresh: () async {
            await profileController.getUserData(isRedirect: true);
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                12.verticalSpace,
                Obx(
                  () => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: AppColors.whiteColor,
                      border: Border.all(color: AppColors.mainPrimaryColor),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100.r),

                          child: NetworkImageWidget(
                            image:
                                profileController
                                    .userModel
                                    .value
                                    ?.profilePhoto ??
                                "",
                            ht: 62.w,
                            wt: 62.w,
                          ),
                        ),
                        10.horizontalSpace,
                        Expanded(
                          child: Obx(
                            () => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonText(
                                  string:
                                      profileController.userModel.value?.name ??
                                      "",
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                8.verticalSpace,
                                CommonText(
                                  string:
                                      profileController
                                          .userModel
                                          .value
                                          ?.phone ??
                                      "",
                                  fontSize: 14.sp,
                                ),
                              ],
                            ),
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
                            child: CustomImage(image: IconAsset.edit),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                12.verticalSpace,

                commonWidget(
                  image: IconAsset.notification,
                  title: AppString.notification.tr,
                  onTap: () {
                    Navigation.pushNamed(Routes.notificationScreen);
                  },
                ),
                12.verticalSpace,
                commonWidget(
                  image: IconAsset.safety,
                  title: AppString.safety.tr,
                  onTap: () {
                    Navigation.pushNamed(Routes.safetyScreen);
                  },
                ),
                12.verticalSpace,

                commonWidget(
                  image: IconAsset.refer,
                  title: AppString.referEarn.tr,
                  onTap: () {
                    Navigation.pushNamed(Routes.referScreen);
                  },
                ),
                12.verticalSpace,

                commonWidget(
                  image: IconAsset.language,
                  title: AppString.language.tr,
                  onTap: () {
                    Navigation.pushNamed(Routes.languageScreen);
                  },
                ),
                12.verticalSpace,

                commonWidget(
                  image: IconAsset.rate,
                  title: AppString.rateApp.tr,
                  onTap: () async {
                    final InAppReview inAppReview = InAppReview.instance;

                    await inAppReview.openStoreListing(
                      appStoreId: AppConstant().appStoreId,
                    );
                  },
                ),
                12.verticalSpace,

                commonWidget(
                  image: IconAsset.share,
                  title: AppString.shareApp.tr,
                  onTap: () {
                    String link = Platform.isAndroid
                        ? AppConstant().androidLink
                        : AppConstant().iosLink;

                    final box = context.findRenderObject() as RenderBox?;

                    print(">>>>>>>>>>$link");
                    SharePlus.instance.share(
                      ShareParams(
                        text:
                            "${AppConstant().appName}, Referral Code : ${profileController.userModel.value?.referralCode ?? ""}\n\n$link",
                        sharePositionOrigin:
                            box!.localToGlobal(Offset.zero) & box.size,
                      ),
                    );
                  },
                ),
                12.verticalSpace,

                commonWidget(
                  image: IconAsset.contact,
                  title: AppString.contctUs.tr,
                  onTap: () {
                    Get.to(
                      () => WebviewScreen(webUrl: AppConstant().contactUs),
                    );
                  },
                ),
                12.verticalSpace,

                commonWidget(
                  image: IconAsset.about,
                  title: AppString.aboutUs.tr,
                  onTap: () {
                    Get.to(() => WebviewScreen(webUrl: AppConstant().aboutUs));
                  },
                ),
                12.verticalSpace,

                commonWidget(
                  image: IconAsset.safety,
                  title: AppString.privacyPolicy.tr,
                  onTap: () {
                    Get.to(
                      () => WebviewScreen(webUrl: AppConstant().privacyPolicy),
                    );
                  },
                ),
                12.verticalSpace,

                commonWidget(
                  image: IconAsset.term,
                  title: AppString.termCondition.tr,
                  onTap: () {
                    Get.to(
                      () => WebviewScreen(webUrl: AppConstant().termsCondition),
                    );
                  },
                ),
                12.verticalSpace,

                commonWidget(
                  image: IconAsset.delete,
                  title: AppString.deleteAccount.tr,
                  onTap: () {
                    AppDialog.commonDialog(
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
                              Navigation.pop();
                              final res = await profileController
                                  .deleteAccount();
                              if (res.isNotEmpty) {
                                await AppPreference.clearSharedPreferences();
                                Get.delete<HomeController>(force: true);
                                Navigation.replaceAll(Routes.loginScreen);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                16.verticalSpace,
                CustomButton(
                  text: AppString.logOut.tr,
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
                              Navigation.pop();
                              final res = await profileController
                                  .logOutAccount();
                              if (res.isNotEmpty) {
                                await AppPreference.clearSharedPreferences();
                                Get.delete<HomeController>(force: true);
                                Navigation.replaceAll(Routes.loginScreen);
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
            ),
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
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.textFieldBorderColor),
          color: AppColors.whiteColor,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(6.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: AppColors.whiteGrey,
              ),
              alignment: Alignment.center,
              child: CustomImage(
                image: image,
                ht: 24.h,
                wt: 24.h,
                fit: BoxFit.cover,
                color: AppColors.blackColor,
              ),
            ),
            10.horizontalSpace,
            CommonText(string: title, fontSize: 16.sp),
          ],
        ),
      ),
    );
  }
}
