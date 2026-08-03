import 'dart:io';

import 'package:e_taxi/core/service/firebase_notification_new.dart';
import 'package:e_taxi/feature/auth/controller/auth_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/constants.dart';
import 'package:e_taxi/utils/validation_utils.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:e_taxi/widgets/dotted_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../utils/app_country_picker.dart';
import '../../../../utils/app_string.dart';
import '../../../../utils/assets.dart';
import '../../../../utils/navigation_utils/navigation.dart';
import '../../../../utils/navigation_utils/routes.dart';
import '../../../../utils/utils.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/webview_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  RxBool isPhone = true.obs;
  final _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                34.verticalSpace,
                CommonText(
                  string: AppString.signInStart.tr,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w500,
                  softWrap: true,
                ),
                8.verticalSpace,
                Obx(
                  () => CommonText(
                    string: isPhone.value
                        ? AppString.usePhoneNumberAccount.tr
                        : AppString.useEmailAccount.tr,
                    fontSize: 16.sp,
                    color: AppColors.textCaptionColor,
                    softWrap: true,
                  ),
                ),
                32.verticalSpace,

                Obx(
                  () => isPhone.value
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                              string: AppString.mobileNumber,
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
                                      phoneController: TextEditingController(),
                                      country: _authController
                                          .selectedDialogCountry
                                          .value,
                                    ).paddingOnly(right: 10.w),
                                  ),
                                  Expanded(
                                    child: Theme(
                                      data: ThemeData(
                                        textSelectionTheme:
                                            TextSelectionThemeData(
                                              selectionHandleColor:
                                                  AppColors.mainPrimaryColor,
                                              selectionColor:
                                                  AppColors.transparent,
                                            ),
                                      ),
                                      child: TextFormField(
                                        cursorColor: AppColors.mainPrimaryColor,
                                        controller:
                                            _authController.phoneController,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: AppColors.textPrimaryColor,
                                        ),
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 18.h,
                                          ),
                                          hintStyle: TextStyle(
                                            color: AppColors.hintTextColor,
                                            fontSize: 14.sp,
                                          ),
                                          hintText: "9988776655",
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(16),
                                        ],
                                        onChanged: (value) {},
                                      ),
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
                                    .trim()
                                    .phoneValid(
                                      _authController.phoneController.text
                                          .trim(),
                                      _authController.countryCode.value,
                                    )) {
                                  print(
                                    "TOKEN::${FireBaseNotification().FcmToken}",
                                  );
                                  return;
                                }
                                _authController.firebaseOtpSend();
                              },
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            CustomTextField(
                              title: AppString.email.tr,
                              controller: TextEditingController(),
                              hintText: "Demo@gmail.com",
                              prefixIcon: IconAsset.email,
                              onChanged: (value) {
                                _authController.email = value;
                              },
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                            16.verticalSpace,
                            CustomTextField(
                              title: AppString.password.tr,
                              controller: TextEditingController(),
                              hintText: "Test@123",
                              prefixIcon: IconAsset.password,
                              isPasswordField: true,
                              onChanged: (value) {
                                _authController.password = value;
                              },
                            ),
                            2.verticalSpace,
                            GestureDetector(
                              onTap: () {
                                Navigation.pushNamed(
                                  Routes.forgotPasswordScreen,
                                );
                              },
                              child: Align(
                                alignment: AlignmentGeometry.centerRight,
                                child: CommonText(
                                  string: AppString.forgotPassword.tr,
                                ),
                              ),
                            ),
                            32.verticalSpace,
                            CustomButton(
                              text: AppString.verify.tr,
                              textColor: AppColors.textPrimaryColor,
                              onTap: () async {
                                if (!_authController.email.isValidEmail() ||
                                    !_authController.password
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

                48.verticalSpace,
                SizedBox(
                  height: 20.h,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: DottedWidget()),
                      24.horizontalSpace,
                      CommonText(
                        string: AppString.orLoginWith.tr,
                        color: AppColors.bodyText,
                      ),
                      24.horizontalSpace,
                      Expanded(child: DottedWidget()),
                    ],
                  ),
                ),
                38.verticalSpace,
                CommonLoginButton(
                  image: IconAsset.google,
                  title: AppString.continueWithGoogle.tr,
                  onTap: () {
                    _authController.phoneController.clear();
                    _authController.password = "";
                    _authController.email = "";

                    _authController.googleLogin();
                  },
                ),
                if (Platform.isIOS)
                  CommonLoginButton(
                    image: IconAsset.apple,
                    title: AppString.continueWithApple.tr,
                    onTap: () async {
                      _authController.phoneController.clear();
                      _authController.password = "";
                      _authController.email = "";

                      _authController.appleLogin();
                    },
                  ),
                Obx(
                  () => CommonLoginButton(
                    image: isPhone.value == false
                        ? IconAsset.phoneFill
                        : IconAsset.email,
                    title: isPhone.value
                        ? AppString.continueWithEmail.tr
                        : AppString.continueWithPhone.tr,
                    onTap: () {
                      _authController.phoneController.clear();
                      _authController.password = "";
                      _authController.email = "";
                      isPhone.value = !isPhone.value;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: Utils().checkPlatForm,
        child: Container(
          margin: EdgeInsets.only(bottom: 24.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: AppString.loginInAgreeOur.tr + "\n",
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
                        () => WebviewScreen(webUrl: Constants().termsCondition),
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
                        () => WebviewScreen(webUrl: Constants().privacyPolicy),
                      );
                    },
                ),
              ],
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
        height: 56.h,
        margin: EdgeInsets.only(bottom: 8.h),

        decoration: BoxDecoration(
          border: Border.all(color: AppColors.textFieldBorderColor, width: 1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomImage(image: image, fit: BoxFit.cover, ht: 24.w, wt: 24.w),
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
