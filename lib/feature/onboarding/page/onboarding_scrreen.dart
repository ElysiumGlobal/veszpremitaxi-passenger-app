import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_preferences.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/navigation_utils/navigation.dart';
import 'package:e_taxi/utils/navigation_utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({super.key});

  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens> {
  static const _slides = <_OnboardingSlide>[
    _OnboardingSlide(
      eyebrow: 'VESZPRÉMI TAXI',
      title: 'Taxirendelés egyszerűen',
      subtitle:
          'Add meg, honnan indulsz és hová tartasz. A rendelés többi részét az alkalmazás végigvezeti.',
      image: ImagesAsset.onBoarding1,
    ),
    _OnboardingSlide(
      eyebrow: 'VESZPRÉM ÉS KÖRNYÉKE',
      title: 'Helyi csapat, gyors kiállás',
      subtitle:
          'Városi fuvar, előrendelés vagy hosszabb út – ugyanabból az alkalmazásból.',
      image: ImagesAsset.onBoarding2,
    ),
    _OnboardingSlide(
      eyebrow: '0–24 SZOLGÁLTATÁS',
      title: 'Éjjel-nappal számíthatsz ránk',
      subtitle:
          'Kulturált autók, helyismerettel rendelkező sofőrök és közvetlen veszprémi támogatás.',
      image: ImagesAsset.loginBg,
    ),
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await AppPreference.setBoolean(AppPreference.onboardingDone, value: true);
    Navigation.replace(Routes.loginScreen);
  }

  void _next() {
    if (_currentPage == _slides.length - 1) {
      _finish();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.brandNavy,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.brandNavy,
        body: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(slide.image, fit: BoxFit.cover),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x33000000),
                            Color(0x22000000),
                            Color(0xCC031B33),
                            AppColors.brandNavy,
                          ],
                          stops: [0, 0.42, 0.76, 1],
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 168.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              slide.eyebrow,
                              style: TextStyle(
                                color: AppColors.mainPrimaryColor,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.2,
                              ),
                            ),
                            12.verticalSpace,
                            Text(
                              slide.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34.sp,
                                height: 1.05,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            16.verticalSpace,
                            Text(
                              slide.subtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 16.sp,
                                height: 1.42,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finish,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 22.w,
                      vertical: 14.h,
                    ),
                  ),
                  child: const Text('Kihagyás'),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 24.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: List.generate(_slides.length, (index) {
                            final active = index == _currentPage;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                              margin: EdgeInsets.only(right: 7.w),
                              width: active ? 28.w : 8.w,
                              height: 8.h,
                              decoration: BoxDecoration(
                                color: active
                                    ? AppColors.mainPrimaryColor
                                    : Colors.white.withValues(alpha: 0.38),
                                borderRadius: BorderRadius.circular(99.r),
                              ),
                            );
                          }),
                        ),
                      ),
                      SizedBox(
                        height: 52.h,
                        child: FilledButton(
                          onPressed: _next,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.mainPrimaryColor,
                            foregroundColor: AppColors.brandNavy,
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            _currentPage == _slides.length - 1
                                ? 'Kezdjük'
                                : 'Tovább',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.image,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final String image;
}
