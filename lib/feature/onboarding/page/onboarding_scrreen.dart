import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_preferences.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../utils/app_string.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({super.key});

  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens> {
  final List<String> title = [
    AppString.onBoardingOneTitle.tr,
    AppString.onBoardingSecoundTitle.tr,
    AppString.onBoardingThirdTitle.tr,
  ];

  final List<String> subTitle = [
    AppString.onBoardingOneSubTitle.tr,
    AppString.onBoardingSecoundSubTitle.tr,
    AppString.onBoardingThirdSubTitle.tr,
  ];

  final List<String> imageList = [
    ImagesAsset.onBoarding1,
    ImagesAsset.onBoarding2,
    ImagesAsset.onBoarding3,
  ];

  RxInt currentPage = 0.obs;

  final pageController = PageController(initialPage: 0);

  void setOnboarding() async {
    AppPreference.setBoolean(AppPreference.onboardingDone, value: true);
    Navigation.replace(Routes.loginScreen);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: SizedBox(
          height: Get.height,
          child: Stack(
            children: [
              SizedBox(
                height: 635.h,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: 3,
                  onPageChanged: (value) {
                    currentPage.value = value;
                  },
                  itemBuilder: (context, index) {
                    return Obx(
                      () => Image.asset(
                        imageList[currentPage.value],
                        height: 635.h,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Obx(
                  () => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 130),
                            margin: EdgeInsets.only(right: 4),
                            height: currentPage.value == index ? 8.w : 4.w,
                            width: currentPage.value == index ? 8.w : 4.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentPage.value == index
                                  ? AppColors.mainPrimaryColor
                                  : AppColors.hintTextColor,
                            ),
                          );
                        }),
                      ),
                      22.verticalSpace,
                      SafeArea(
                        top: false,
                        bottom: Utils().checkPlatForm,
                        child: Container(
                          width: double.infinity,
                          height: 267.h,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12.r),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CommonText(
                                string: title[currentPage.value],
                                fontWeight: FontWeight.w500,
                                fontSize: 22.sp,
                              ),
                              28.verticalSpace,
                              CommonText(
                                string: subTitle[currentPage.value],
                                softWrap: true,
                                fontSize: 16.sp,
                                textAlign: TextAlign.center,
                                color: AppColors.textPrimaryColor,
                              ),
                              Spacer(),
                              Row(
                                children: [
                                  16.horizontalSpace,
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setOnboarding();
                                      },
                                      child: CommonText(
                                        string: currentPage.value < 2
                                            ? AppString.skip.tr
                                            : "",
                                        fontSize: 16.sp,
                                        color: AppColors.textCaptionColor,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (currentPage.value < 2) {
                                        currentPage.value++;
                                        pageController.animateToPage(
                                          currentPage.value,
                                          duration: Duration(milliseconds: 200),
                                          curve: Curves.bounceInOut,
                                        );
                                        // pageController.jumpToPage(currentPage.value++);
                                      } else {
                                        setOnboarding();
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 500),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24.w,
                                        vertical: 8.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.mainPrimaryColor,
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          CommonText(
                                            string: currentPage.value < 2
                                                ? AppString.next.tr
                                                : AppString.getStart.tr,
                                            fontSize: 16.sp,
                                          ),
                                          10.horizontalSpace,
                                          SvgPicture.asset(
                                            IconAsset.arrowRightIcon,
                                            height: 24.w,
                                            width: 24.w,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
