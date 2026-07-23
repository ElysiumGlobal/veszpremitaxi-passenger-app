import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/app_preferences.dart';
import '../../../utils/app_string.dart';
import '../../../utils/utils.dart';
import '../../../widgets/appbar.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  List iconList = [ImagesAsset.uk, ImagesAsset.india, ImagesAsset.aerabic];
  List titleList = [
    "English",
    "Hindi",
    "Arebic",
    "Portuguese",
    "Hebrew",
    "Russian",
  ];
  List subtitleList = [
    "English",
    "हिंदी",
    "عربي",
    "Português",
    "עִברִית",
    "Русский",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      appBar: CustomAppBar(title: AppString.language.tr, centerTitle: false),
      body: SafeArea(
        bottom: Utils().checkPlatForm,
        child: Padding(
          padding: EdgeInsets.all(16.w),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                string: AppString.welcome.tr,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
              CommonText(string: AppString.pleaseSelectLang.tr),
              16.verticalSpace,
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    return commonWidget(
                      title: titleList[index],
                      subTitle: subtitleList[index],
                      icon: iconList[index],
                      onTap: () async {
                        AppPreference.setInt(
                          AppPreference.languageIndex,
                          index,
                        );
                        Utils.updateLanguage(index);
                        setState(() {});
                      },
                    );
                  },
                  separatorBuilder: (context, index) => 12.verticalSpace,
                  itemCount: iconList.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget commonWidget({
    required String title,
    required String subTitle,
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.w),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: AppColors.textFieldBorderColor),
        ),
        child: Row(
          children: [
            CustomImage(image: icon, ht: 36.h, wt: 61.w),
            8.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  CommonText(
                    string: title,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                  4.verticalSpace,
                  CommonText(
                    string: subTitle,
                    fontWeight: FontWeight.w500,
                    color: AppColors.hintTextColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
