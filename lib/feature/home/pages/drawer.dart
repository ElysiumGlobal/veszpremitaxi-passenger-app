import 'package:e_taxi/feature/account/controller/account_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/cacheNetworkImage.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  final accountController = Get.find<AccountController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.whiteColor,
      child: SafeArea(
        bottom: Utils().checkPlatForm,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            30.verticalSpace,
            Obx(
              () => Row(
                children: [
                  NetworkImageWidget(
                    image:
                        accountController.userModel.value?.profilePhoto ?? "",
                    ht: 64.h,
                    wt: 64.h,
                    radius: 50.r,
                  ),
                  24.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          string: accountController.userModel.value?.name ?? "",
                          fontWeight: FontWeight.w600,
                          fontSize: 22.sp,
                        ),
                        4.verticalSpace,
                        Row(
                          children: [
                            CustomImage(
                              image: ImagesAsset.selectedStar,
                              color: AppColors.titleTextColor,
                              ht: 16.h,
                              wt: 16.h,
                            ),
                            4.horizontalSpace,
                            CommonText(
                              string:
                                  "${accountController.userModel.value?.driverProfile?.rating ?? "0"}",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            dividerWidget(),

            commonWidget(
              image: ImagesAsset.drivingCar,
              title: AppString.tripActivity.tr,
              subtitle: AppString.completTripCancelTrip.tr,
              onTap: () {
                Get.back();
                Navigation.pushNamed(Routes.tripActivityScreen);
              },
            ),
            dividerWidget(),

            commonWidget(
              image: IconAsset.earning,
              title: AppString.earnings.tr,
              subtitle: AppString.walletWithdrawHistory.tr,
              onTap: () {
                Get.back();
                Navigation.pushNamed(Routes.earningScreen);
              },
            ),
            dividerWidget(),

            commonWidget(
              image: IconAsset.reward,
              title: AppString.incentive.tr,
              subtitle: AppString.dailyIncentiveChallenge.tr,
              onTap: () {
                Get.back();
                Navigation.pushNamed(Routes.incentiveScreen);
              },
            ),
            dividerWidget(),

            commonWidget(
              image: IconAsset.support24,
              title: AppString.helpCenter.tr,
              subtitle: AppString.getSupportEmergencyTicket.tr,
              onTap: () {
                Get.back();
                Navigation.pushNamed(Routes.helpCenterScreen);
              },
            ),
            dividerWidget(),

            commonWidget(
              image: IconAsset.userAcc,
              title: AppString.account.tr,
              subtitle: AppString.manageProfile.tr,
              onTap: () {
                Get.back();
                Navigation.pushNamed(Routes.accountScreen);
              },
            ),
            dividerWidget(),
          ],
        ).paddingSymmetric(horizontal: 16.w),
      ),
    );
  }

  Widget commonWidget({
    required String image,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 40.h,
            width: 40.h,
            decoration: BoxDecoration(
              color: AppColors.whiteGrey,
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: CustomImage(
              image: image,
              ht: 24.h,
              wt: 24.h,
              color: AppColors.titleTextColor,
            ),
          ),
          12.horizontalSpace,
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
                  string: subtitle,
                  softWrap: true,
                  color: AppColors.textCaptionColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget dividerWidget() {
    return Container(
      width: double.infinity,
      height: 1.h,
      color: AppColors.textFieldBorderColor,
      margin: EdgeInsets.symmetric(vertical: 16.h),
    );
  }
}
