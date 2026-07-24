import 'dart:io';

import 'package:e_taxi/feature/auth/controller/auth_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/build_config.dart';
import 'package:e_taxi/utils/constants.dart';
import 'package:e_taxi/utils/navigation_utils/navigation.dart';
import 'package:e_taxi/utils/navigation_utils/routes.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:e_taxi/utils/validation_utils.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:e_taxi/widgets/webview_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = Get.put(AuthController());

  Future<void> _continueWithEmail() async {
    final email = _authController.emailController.text.trim();
    final password = _authController.passwordController.text.trim();

    if (!email.isValidEmail()) return;
    if (password.isEmpty) {
      showError(AppString.pleaseEnterYourPassword.tr);
      return;
    }
    if (password.length < 6) {
      showError(AppString.passwordLengthMustBeAtLeast6CharacterLong.tr);
      return;
    }

    await _authController.emailLogin();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.brandNavy,
        body: GestureDetector(
          onTap: () => Utils.hideKeyboardInApp(context),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHero(),
                Transform.translate(
                  offset: Offset(0, -34.h),
                  child: _buildLoginCard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return SizedBox(
      height: 330.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(ImagesAsset.loginBg, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x33031B33),
                  Color(0x66031B33),
                  AppColors.brandNavy,
                ],
                stops: [0, 0.5, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 58.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    ImagesAsset.vapPassengerLogo,
                    width: 116.w,
                    fit: BoxFit.contain,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VESZPRÉMI TAXI',
                        style: TextStyle(
                          color: AppColors.mainPrimaryColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.1,
                        ),
                      ),
                      8.verticalSpace,
                      Text(
                        'Hova mehetünk?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34.sp,
                          height: 1.05,
                          fontWeight: FontWeight.w700,
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
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 548.h),
      padding: EdgeInsets.fromLTRB(20.w, 26.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Belépés vagy regisztráció',
              style: TextStyle(
                color: AppColors.titleTextColor,
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            8.verticalSpace,
            Text(
              'Add meg az e-mail-címedet és a jelszavadat. Új utasként a következő lépésben létrehozhatod a profilodat.',
              style: TextStyle(
                color: AppColors.textCaptionColor,
                fontSize: 14.sp,
                height: 1.45,
              ),
            ),
            26.verticalSpace,
            CustomTextField(
              title: 'E-mail-cím',
              controller: _authController.emailController,
              hintText: 'pelda@email.hu',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              radius: 10.r,
              textfielHeight: 58.h,
              focusedColor: AppColors.mainPrimaryColor,
            ),
            14.verticalSpace,
            CustomTextField(
              title: 'Jelszó',
              controller: _authController.passwordController,
              hintText: 'Legalább 6 karakter',
              isPasswordField: true,
              radius: 10.r,
              textfielHeight: 58.h,
              focusedColor: AppColors.mainPrimaryColor,
              onSaved: (_) => _continueWithEmail(),
            ),
            8.verticalSpace,
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigation.pushNamed(Routes.forgotPasswordScreen);
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.brandNavy,
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
                ),
                child: const Text('Elfelejtett jelszó'),
              ),
            ),
            10.verticalSpace,
            CustomButton(
              height: 58.h,
              text: 'Folytatás e-maillel',
              buttonColor: AppColors.mainPrimaryColor,
              textColor: AppColors.brandNavy,
              fontWeight: FontWeight.w700,
              borderRadius: BorderRadius.circular(12.r),
              onTap: _continueWithEmail,
            ),
            if (BuildConfig.googleLoginEnabled ||
                (Platform.isIOS && BuildConfig.appleLoginEnabled)) ...[
              24.verticalSpace,
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text(
                      'vagy',
                      style: TextStyle(
                        color: AppColors.textCaptionColor,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              18.verticalSpace,
            ],
            if (BuildConfig.googleLoginEnabled)
              CommonLoginButton(
                image: IconAsset.google,
                title: 'Folytatás Google-fiókkal',
                onTap: _authController.googleLogin,
              ),
            if (Platform.isIOS && BuildConfig.appleLoginEnabled)
              CommonLoginButton(
                image: IconAsset.apple,
                title: 'Folytatás Apple-fiókkal',
                onTap: _authController.appleLogin,
              ),
            20.verticalSpace,
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20.w,
                    color: AppColors.brandNavy,
                  ),
                  10.horizontalSpace,
                  Expanded(
                    child: Text(
                      'A telefonszámodat később, a profilodban kérjük el. Ehhez nem küldünk SMS-kódot.',
                      style: TextStyle(
                        color: AppColors.brandNavy,
                        fontSize: 13.sp,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            24.verticalSpace,
            _buildLegalText(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalText() {
    final baseStyle = TextStyle(
      fontSize: 12.sp,
      color: AppColors.textCaptionColor,
      height: 1.45,
    );
    final linkStyle = baseStyle.copyWith(
      color: AppColors.brandNavy,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: baseStyle,
        text: 'A folytatással elfogadod az ',
        children: [
          TextSpan(
            text: 'Általános Szerződési Feltételeket',
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Get.to(
                  () => WebviewScreen(webUrl: AppConstant().termsCondition),
                );
              },
          ),
          const TextSpan(text: ' és az '),
          TextSpan(
            text: 'Adatvédelmi tájékoztatót.',
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Get.to(
                  () => WebviewScreen(webUrl: AppConstant().privacyPolicy),
                );
              },
          ),
        ],
      ),
    );
  }
}

class CommonLoginButton extends StatelessWidget {
  const CommonLoginButton({
    required this.image,
    required this.title,
    required this.onTap,
    super.key,
  });

  final String image;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.h,
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.textFieldBorderColor),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomImage(image: image, ht: 22.w, wt: 22.w, fit: BoxFit.contain),
            12.horizontalSpace,
            CommonText(
              string: title,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}
