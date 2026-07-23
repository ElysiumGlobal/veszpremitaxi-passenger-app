import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.whiteGrey,
        body: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).viewPadding.top + 56.h),
                CustomImage(
                  image: ImagesAsset.locationGet,
                  wt: double.infinity,
                ),
                SizedBox(height: MediaQuery.of(context).viewPadding.top + 56.h),

                CommonText(
                  string: AppString.turnOnLocation.tr,
                  fontWeight: FontWeight.w500,
                  fontSize: 22.sp,
                ),

                8.verticalSpace,

                CommonText(
                  string: AppString.weUseLocationFasterPicker.tr,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  color: AppColors.textSecondaryColor,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),

                Spacer(),
                Column(
                  children: [
                    CustomButton(
                      text: AppString.turnOnLocationService.tr,
                      onTap: () {
                        Navigation.pushNamed(Routes.registerScreen);
                      },
                    ),
                    16.verticalSpace,
                    CustomButton(
                      buttonColor: AppColors.transparent,
                      text: AppString.notNow.tr,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
