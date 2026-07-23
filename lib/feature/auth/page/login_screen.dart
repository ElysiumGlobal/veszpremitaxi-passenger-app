import 'dart:io';

import 'package:e_taxi/feature/auth/controller/auth_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/validation_utils.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/app_country_picker.dart';
import '../../../utils/app_string.dart';
import '../../../utils/constants.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfeild.dart';
import '../../../widgets/webview_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authController = Get.put(AuthController());
  RxBool isPhone = true.obs;

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
        body: Padding(
          padding: EdgeInsets.only(bottom: 0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  ImagesAsset.loginBg,
                  height: 482.h,
                  width: double.maxFinite,
                  fit: BoxFit.cover,
                ),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8.r),
                    ),
                  ),
                  transform: Matrix4.translationValues(0, -40.h, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        string: AppString.welcomeBack.tr,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      8.verticalSpace,

                      /// todo:phone
                      Obx(
                        () => isPhone.value
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CommonText(
                                    string: AppString
                                        .yourRideStartHereJustNumber
                                        .tr,
                                    softWrap: true,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondaryColor,
                                  ),
                                  24.verticalSpace,

                                  CommonText(
                                    string: AppString.mobileNumber.tr,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12.sp,
                                  ),
                                  4.verticalSpace,
                                  Container(
                                    height: 56.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(6.r),
                                      ),
                                      border: Border.all(
                                        color: AppColors.textFieldBorderColor,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Obx(
                                          () => CountryPickerWidget(
                                            phoneController:
                                                TextEditingController(),
                                            country: _authController
                                                .selectedDialogCountry
                                                .value,
                                          ).paddingOnly(right: 10.w),
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            cursorColor:
                                                AppColors.mainPrimaryColor,
                                            controller:
                                                _authController.phoneController,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: AppColors.textPrimaryColor,
                                            ),
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 18.h,
                                                  ),
                                              hintStyle: TextStyle(
                                                color: AppColors.hintTextColor,
                                                fontSize: 14.sp,
                                              ),
                                              hintText: "301234567",
                                              border: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                            ),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(
                                                16,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  32.verticalSpace,
                                  CustomButton(
                                    text: AppString.verify.tr,
                                    textColor: AppColors.textPrimaryColor,

                                    onTap: () async {
                                      if (!_authController.phoneController.text
                                          .phoneValid(
                                            _authController.phoneController.text
                                                .trim(),
                                            _authController.countryCode.value,
                                          )) {
                                        return;
                                      }

                                      await _authController.sendOtp();
                                    },
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// todo: email
                                  CommonText(
                                    string: AppString.backOnRoadSignIn.tr,
                                    softWrap: true,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondaryColor,
                                  ),
                                  32.verticalSpace,
                                  CustomTextField(
                                    title: AppString.email.tr,
                                    controller: _authController.emailController,
                                    hintText: AppString.enterYourEmail.tr,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  8.verticalSpace,

                                  CustomTextField(
                                    title: AppString.password.tr,
                                    controller:
                                        _authController.passwordController,
                                    hintText: AppString.enterYourPassword.tr,
                                    isPasswordField: true,
                                  ),

                                  4.verticalSpace,

                                  Align(
                                    alignment: AlignmentGeometry.centerRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigation.pushNamed(
                                          Routes.forgotPasswordScreen,
                                        );
                                      },
                                      child: CommonText(
                                        string: AppString.forgotPassword.tr,
                                        color: AppColors.mainPrimaryColor,
                                      ),
                                    ),
                                  ),
                                  16.verticalSpace,
                                  CustomButton(
                                    text: AppString.verify.tr,
                                    onTap: () async {
                                      if (!_authController.emailController.text
                                              .trim()
                                              .isValidEmail() ||
                                          !_authController
                                              .passwordController
                                              .text
                                              .trim()
                                              .isValidPassword()) {
                                        return;
                                      }
                                      _authController.emailLogin();
                                    },
                                  ),
                                ],
                              ),
                      ),

                      /// todo: multiLogin
                      32.verticalSpace,

                      CommonLoginButton(
                        image: IconAsset.google,
                        title: AppString.continueWithGoogle.tr,
                        onTap: () {
                          _authController.googleLogin();
                        },
                      ),
                      if (Platform.isIOS)
                        CommonLoginButton(
                          image: IconAsset.apple,
                          title: AppString.continueWithApple.tr,
                          onTap: () async {
                            _authController.appleLogin();
                          },
                        ),
                      Obx(
                        () => isPhone.value
                            ? CommonLoginButton(
                                image: IconAsset.email,
                                title: AppString.continueWithEmail.tr,
                                onTap: () {
                                  _authController.emailController.clear();
                                  _authController.phoneController.clear();
                                  _authController.passwordController.clear();
                                  isPhone.value = !isPhone.value;
                                },
                              )
                            : CommonLoginButton(
                                image: IconAsset.phone,
                                title: AppString.continueWithPhone.tr,
                                onTap: () {
                                  _authController.emailController.clear();
                                  _authController.phoneController.clear();
                                  _authController.passwordController.clear();
                                  isPhone.value = !isPhone.value;
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          bottom: Utils().checkPlatForm,
          child: Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: "${AppString.loginInAgreeOur.tr}\n",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.titleTextColor,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: AppString.termOfService,
                    style: TextStyle(
                      color: AppColors.mainPrimaryColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Get.to(
                          () => WebviewScreen(
                            webUrl: AppConstant().termsCondition,
                          ),
                        );
                      },
                  ),
                  TextSpan(text: ' ${AppString.and} '),
                  TextSpan(
                    text: AppString.privacyPolicy,
                    style: TextStyle(
                      color: AppColors.mainPrimaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Get.to(
                          () => WebviewScreen(
                            webUrl: AppConstant().privacyPolicy,
                          ),
                        );
                      },
                  ),
                ],
              ),
            ),
          ),
        ),
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
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.textFieldBorderColor, width: 1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomImage(image: image, fit: BoxFit.cover),
            16.horizontalSpace,
            CommonText(
              string: title,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      ),
    );
  }
}
