import 'package:country_pickers/utils/utils.dart';
import 'package:e_taxi/feature/auth/controller/auth_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/log_utils.dart';
import 'package:e_taxi/utils/validation_utils.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/app_country_picker.dart';
import '../../../utils/app_string.dart';
import '../../../utils/utils.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/custom_textfeild.dart';
import '../../../widgets/custome_dropdown.dart';
import '../model/email_password.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
    });
  }

  AuthPhoneEmailModel model = AuthPhoneEmailModel();

  void initData() {
    try {
      if (Get.arguments != null) {
        model = Get.arguments;
        _authController.rEmailController.text = model.email;
        _authController.passwordController.text = model.password;
        if (model.phone != "") {
          String code = model.countryCode.split("+").last;
          _authController.phoneController.text = model.phone;
          _authController.countryCode.value = model.countryCode;
          _authController.selectedDialogCountry.value =
              CountryPickerUtils.getCountryByPhoneCode(code);
        }
      }
    } catch (e, st) {
      LogUtils.printError("ADADAD ::$e\n\n$st");
    }
  }

  final _authController = Get.put<AuthController>(AuthController());
  List<String> genderList = [AppString.male, AppString.female, AppString.other];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.whiteGrey,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.whiteGrey,
        body: SafeArea(
          bottom: Utils().checkPlatForm,
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 64.h,
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      height: 48.h,
                      width: 48.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.whiteGrey,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: Offset(0, 1),
                            color: AppColors.blackColor.withValues(alpha: .4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: CustomImage(image: IconAsset.arrowLeftIcon),
                    ),
                  ),
                ),
                16.verticalSpace,
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          string: AppString.createYourProfile.tr,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        8.verticalSpace,
                        CommonText(
                          string: AppString.signUpFewSimpleStep.tr,
                          softWrap: true,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondaryColor,
                        ),
                        34.verticalSpace,

                        CustomTextField(
                          controller: _authController.fullNameController,
                          hintText: "Enter your full name",
                          title: AppString.fullName.tr,

                          textinputformate: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z ]'),
                            ),
                          ],
                        ),
                        16.verticalSpace,

                        CustomTextField(
                          controller: _authController.rEmailController,
                          hintText: "Enter your email",
                          title: AppString.email.tr,
                          readOnly: _authController.loginType != "phone",
                        ),
                        16.verticalSpace,
                        CommonText(
                          string: AppString.mobileNumber,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                        ),
                        4.verticalSpace,
                        IgnorePointer(
                          ignoring: _authController.loginType == "phone",
                          child: Container(
                            height: 56.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6.r),
                              ),
                              border: Border.all(
                                color: AppColors.textFieldBorderColor,
                              ),
                              color: AppColors.whiteColor,
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
                                  child: TextFormField(
                                    cursorColor: AppColors.mainPrimaryColor,
                                    controller: _authController.phoneController,
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
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(16),
                                    ],

                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        16.verticalSpace,

                        CommonText(
                          string: AppString.gender.tr,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                        ),
                        4.verticalSpace,
                        CutomeDropDownButton1(
                          value: _authController.gender,
                          hintValue: AppString.male.tr,
                          listData: genderList,
                          onChange: (event) {
                            _authController.gender.value = event ?? "";
                          },
                        ),

                        16.verticalSpace,

                        CustomTextField(
                          controller: _authController.referralController,
                          hintText: "25TY522",
                          title: AppString.referralCode.tr,
                        ),
                        75.verticalSpace,
                        CustomButton(
                          text: AppString.joinNow.tr,
                          onTap: () async {
                            if (_authController.fullNameController.text
                                .trim()
                                .textDataIsNotValid(
                                  AppString.fullNameRequired.tr,
                                )) {
                              LogUtils.printAction("HERE");
                              return;
                            }

                            if (_authController.loginType != "phone" &&
                                !_authController.rEmailController.text
                                    .trim()
                                    .isValidEmail()) {
                              return;
                            }

                            if (!_authController.phoneController.text
                                .phoneValid(
                                  _authController.phoneController.text.trim(),
                                  _authController.countryCode.value,
                                )) {
                              return;
                            }

                            _authController.userRegister();
                          },
                        ),
                        15.verticalSpace,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
