import 'package:e_taxi/feature/auth/controller/auth_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_country_picker.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PhoneRequiredScreen extends StatefulWidget {
  const PhoneRequiredScreen({super.key});

  @override
  State<PhoneRequiredScreen> createState() => _PhoneRequiredScreenState();
}

class _PhoneRequiredScreenState extends State<PhoneRequiredScreen> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
    _authController.phoneController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: AppColors.whiteGrey,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: AppColors.whiteGrey,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 24.h),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 520.w),
                  child: Container(
                    padding: EdgeInsets.all(22.w),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blackColor.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CommonText(
                          string: 'Telefonszám megadása',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryColor,
                        ),
                        10.verticalSpace,
                        CommonText(
                          string:
                              'A fuvar megrendeléséhez szükségünk van egy elérhető telefonszámra. Ezt a sofőr csak szükség esetén használja.',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondaryColor,
                          softWrap: true,
                        ),
                        28.verticalSpace,
                        CommonText(
                          string: 'Mobiltelefonszám',
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                        6.verticalSpace,
                        Container(
                          height: 58.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
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
                                      .selectedDialogCountry.value,
                                ).paddingOnly(right: 10.w),
                              ),
                              Obx(
                                () => CommonText(
                                  string: _authController.countryCode.value,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              10.horizontalSpace,
                              Expanded(
                                child: TextFormField(
                                  autofocus: true,
                                  controller: _authController.phoneController,
                                  cursorColor: AppColors.mainPrimaryColor,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(15),
                                  ],
                                  onFieldSubmitted: (_) =>
                                      _authController.completeRequiredPhone(),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: AppColors.textPrimaryColor,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '301234567',
                                    hintStyle: TextStyle(
                                      color: AppColors.textSecondaryColor,
                                      fontSize: 15.sp,
                                    ),
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 18.h,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        24.verticalSpace,
                        CustomButton(
                          width: double.infinity,
                          text: 'Mentés és folytatás',
                          onTap: _authController.completeRequiredPhone,
                        ),
                        14.verticalSpace,
                        Center(
                          child: TextButton(
                            onPressed: _authController.logoutFromPhoneGate,
                            child: Text(
                              'Kijelentkezés',
                              style: TextStyle(
                                color: AppColors.textSecondaryColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
