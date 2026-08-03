import 'package:e_taxi/feature/auth/pages/location_setup/location_set_screen.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';

class AccountReviewScreen extends StatefulWidget {
  const AccountReviewScreen({super.key});

  @override
  State<AccountReviewScreen> createState() => _AccountReviewScreenState();
}

class _AccountReviewScreenState extends State<AccountReviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomImage(image: ImagesAsset.note, ht: 200.h),
          32.verticalSpace,
          TitleSubTitleWidget(
            title: AppString.applicationSubmited.tr,
            subTitle: AppString.underReviewUpdate.tr,
          ),
        ],
      ).paddingSymmetric(horizontal: 16.w),

      bottomNavigationBar: SafeArea(
        bottom: Utils().checkPlatForm,
        child: CustomButton(
          text: AppString.exploreApp.tr,
          onTap: () {
            Navigation.replaceAll(Routes.accountDeActiveScreen);
          },
        ).paddingOnly(left: 16.w, right: 16.w, bottom: 24.h),
      ),
    );
  }
}
