import 'package:e_taxi/feature/onboarding/controller/onboarding_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/app_preferences.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final OnBoardingController _controller = Get.find<OnBoardingController>();

  static const List<String> _imageUrls = [
    'https://veszpremitaxi.hu/wp-content/uploads/2026/05/ceges.png',
    'https://veszpremitaxi.hu/wp-content/uploads/2026/05/vtaxi3.png',
    'https://veszpremitaxi.hu/wp-content/uploads/2026/05/soforszoglalat.png',
  ];

  static const List<String> _eyebrows = [
    'VESZPRÉMI TAXI',
    'TAXI ÉJJEL-NAPPAL',
    'VESZPRÉMI TAXI CSAPAT',
  ];

  static const List<String> _titles = [
    'Veszprém Vármegye First Class szolgáltatója',
    'Taxi Éjjel-Nappal',
    'Valós idejű támogatás, navigáció, igazi csapatmunka',
  ];

  Future<void> _finishOnboarding() async {
    await AppPreference.setBoolean(
      AppPreference.onboardingDone,
      value: true,
    );
    Navigation.replace(Routes.registerScreen);
  }

  void _nextPage() {
    if (_controller.pageIndex.value < _imageUrls.length - 1) {
      _controller.pageController.animateToPage(
        _controller.pageIndex.value + 1,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    _finishOnboarding();
  }

  Widget _buildBackground(String imageUrl) {
    return Positioned.fill(
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            color: const Color(0xFF151515),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              color: AppColors.mainPrimaryColor,
              strokeWidth: 2.5,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFF151515),
            alignment: Alignment.center,
            child: Icon(
              Icons.local_taxi_rounded,
              size: 92.w,
              color: AppColors.mainPrimaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlide(BuildContext context, int index) {
    final double safeTop = MediaQuery.paddingOf(context).top;
    final double safeBottom = MediaQuery.paddingOf(context).bottom;

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBackground(_imageUrls[index]),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.34, 0.68, 1.0],
                colors: [
                  Color(0x24000000),
                  Color(0x0D000000),
                  Color(0x94000000),
                  Color(0xF2000000),
                ],
              ),
            ),
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0x29000000),
                  Color(0x00000000),
                  Color(0x1A000000),
                ],
              ),
            ),
          ),
        ),
        if (index != _imageUrls.length - 1)
          Positioned(
            top: safeTop + 16.h,
            right: 20.w,
            child: GestureDetector(
              onTap: _finishOnboarding,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 9.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.32),
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                ),
                child: Text(
                  'Kihagyás',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          left: 24.w,
          right: 24.w,
          bottom: safeBottom + 108.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24.w,
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: AppColors.mainPrimaryColor,
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                  ),
                  8.horizontalSpace,
                  Text(
                    _eyebrows[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.mainPrimaryColor,
                      fontSize: 10.5.sp,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.35,
                    ),
                  ),
                ],
              ),
              10.verticalSpace,
              Text(
                _titles[index],
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: index == 1 ? 30.sp : 27.sp,
                  height: 1.07,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                  shadows: const [
                    Shadow(
                      color: Color(0xB3000000),
                      blurRadius: 18,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double safeBottom = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: _imageUrls.length,
              controller: _controller.pageController,
              onPageChanged: (value) {
                _controller.pageIndex.value = value;
              },
              itemBuilder: _buildSlide,
            ),
            Positioned(
              left: 24.w,
              right: 34.w,
              bottom: safeBottom + 22.h,
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(_imageUrls.length, (index) {
                        final bool isActive =
                            _controller.pageIndex.value == index;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: EdgeInsets.only(right: 7.w),
                          width: isActive ? 23.w : 7.w,
                          height: 7.h,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.mainPrimaryColor
                                : Colors.white.withValues(alpha: 0.46),
                            borderRadius: BorderRadius.circular(99.r),
                          ),
                        );
                      }),
                    ),
                    GestureDetector(
                      onTap: _nextPage,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 104.w,
                        height: 48.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.mainPrimaryColor,
                          borderRadius: BorderRadius.circular(15.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.mainPrimaryColor.withValues(
                                alpha: 0.28,
                              ),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Text(
                          _controller.pageIndex.value ==
                                  _imageUrls.length - 1
                              ? 'Belépés'
                              : 'Tovább',
                          style: TextStyle(
                            color: const Color(0xFF17120A),
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                          ),
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
    );
  }
}
