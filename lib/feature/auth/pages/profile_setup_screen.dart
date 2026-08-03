import 'dart:io';

import 'package:country_phone_validator/country_phone_validator.dart';
import 'package:country_pickers/country.dart' as country;
import 'package:country_pickers/utils/utils.dart';
import 'package:e_taxi/feature/auth/controller/register_controller.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:e_taxi/utils/validation_utils.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_country_picker.dart';
import '../../../utils/app_string.dart';
import '../../../utils/assets.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custome_img.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      setData();
    });
  }

  void setData() {
    var arg = Get.arguments;

    countryCode = (arg['countryCode'] ?? "").isEmpty
        ? "+91"
        : arg['countryCode'];
    mobileController.text = arg['phone'];
    emailController.text = arg['email'];
    nameController.text = arg['name'] ?? "";
    if (mobileController.text.isNotEmpty) {
      isPhone.value = true;
      Future.microtask(() {
        selectedDialogCountry.value = CountryPickerUtils.getCountryByPhoneCode(
          countryCode.replaceAll("+", ""),
        );
      });
    }
  }

  String countryCode = "+91";

  final GlobalKey<FormState> profileGk = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController referController = TextEditingController();

  RxBool isDobError = false.obs;
  RxBool isNameError = false.obs;
  RxBool isPhoneError = false.obs;

  final controller = Get.put(RegisterController());

  RxBool isPhone = false.obs;

  final Rx<country.Country> selectedDialogCountry =
      CountryPickerUtils.getCountryByPhoneCode("91").obs;

  String nameError = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: AppString.profile.tr,
        leading: SizedBox(width: 16.w),
        leadingSize: 16.w,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
            height: 72.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              border: Border(
                top: BorderSide(color: AppColors.textFieldBorderColor),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 40.h,
                  width: 40.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.mainPrimaryColor,
                  ),
                  alignment: Alignment.center,
                  child: CustomImage(image: IconAsset.done, ht: 20.h, wt: 20.h),
                ),
                Container(
                  margin: EdgeInsetsGeometry.symmetric(horizontal: 4.w),
                  width: 16.w,
                  height: 1,
                  color: AppColors.titleTextColor,
                ),
                CustomImage(
                  image: ImagesAsset.selectedProfile,
                  ht: 40.h,
                  wt: 40.h,
                ),
                Container(
                  margin: EdgeInsetsGeometry.symmetric(horizontal: 4.w),
                  width: 16.w,
                  height: 1,
                  color: AppColors.titleTextColor,
                ),
                CustomImage(image: ImagesAsset.car, ht: 40.h, wt: 40.h),
                Container(
                  margin: EdgeInsetsGeometry.symmetric(horizontal: 4.w),
                  width: 16.w,
                  height: 1,
                  color: AppColors.titleTextColor,
                ),
                CustomImage(image: ImagesAsset.document, ht: 40.h, wt: 40.h),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: profileGk,
                child: Column(
                  children: [
                    24.verticalSpace,
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Obx(
                          () => Container(
                            height: 148.w,
                            width: 148.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.textFieldBorderColor,
                            ),
                            child: controller.profileImage.value != null
                                ? ClipRRect(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      120,
                                    ),
                                    child: Image.file(
                                      File(
                                        controller.profileImage.value?.path ??
                                            "",
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            controller.getProfileImage();
                          },
                          child: Container(
                            height: 40.h,
                            width: 40.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.mainPrimaryColor,
                            ),
                            alignment: Alignment.center,
                            child: CustomImage(
                              image: IconAsset.editFill,
                              ht: 20.h,
                              wt: 20.h,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    24.verticalSpace,

                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            autoFocus: true,
                            title: AppString.name.tr,
                            controller: nameController,
                            prefixIcon: IconAsset.nameProfile,
                            hintText: "John Doe",
                            fillColor: isNameError.value
                                ? AppColors.errorBgColor
                                : AppColors.whiteColor,
                            enableColor: isNameError.value
                                ? AppColors.errorColor
                                : null,
                            focusedColor: isNameError.value
                                ? AppColors.errorColor
                                : null,
                            textinputformate: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z ]'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value.isNotEmpty && value.length >= 3) {
                                isNameError.value = false;
                              }
                            },
                          ),
                          isNameError.value
                              ? CommonText(
                                  string: AppString.pleaseEnterName.tr,
                                  color: AppColors.errorColor,
                                ).paddingOnly(top: 2.h)
                              : SizedBox.shrink(),
                        ],
                      ),
                    ),

                    16.verticalSpace,
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IgnorePointer(
                            ignoring: isPhone.value,
                            child: Container(
                              height: 56.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(6.r),
                                ),
                                border: Border.all(
                                  color: isPhoneError.value
                                      ? AppColors.errorColor
                                      : AppColors.textFieldBorderColor,
                                ),

                                color: isPhoneError.value
                                    ? AppColors.errorBgColor
                                    : AppColors.whiteColor,
                              ),

                              child: Row(
                                children: [
                                  Obx(
                                    () => CountryPickerWidget1(
                                      padding: 10.w,
                                      phoneController: TextEditingController(),
                                      country: selectedDialogCountry.value,
                                      onTap: (v) {
                                        countryCode = "+${v.phoneCode}";
                                        selectedDialogCountry.value =
                                            CountryPickerUtils.getCountryByPhoneCode(
                                              v.phoneCode,
                                            );

                                        isPhoneError.value =
                                            !CountryUtils.validatePhoneNumber(
                                              mobileController.text.trim(),
                                              countryCode,
                                            );
                                      },
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
                                        controller: mobileController,
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
                                        onChanged: (value) {
                                          isPhoneError.value =
                                              !(CountryUtils.validatePhoneNumber(
                                                mobileController.text.trim(),
                                                countryCode,
                                              ));
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Obx(
                            () => isPhoneError.value
                                ? CommonText(
                                    string: AppString.pleaseEnterValidNumber.tr,
                                    color: AppColors.errorColor,
                                  ).paddingOnly(top: 2.h)
                                : SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                    16.verticalSpace,
                    Obx(
                      () => CustomTextField(
                        title: AppString.email.tr,
                        titlestarWidget: CommonText(
                          string: isPhone.value == false
                              ? ""
                              : " (${AppString.optional.tr})",
                          color: AppColors.textCaptionColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                        ),
                        controller: emailController,
                        prefixIcon: IconAsset.email,
                        hintText: "E.g Demo@gmail.com",
                        readOnly: isPhone.value == false,
                      ),
                    ),
                    16.verticalSpace,
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            title: AppString.dob.tr,
                            controller: dobController,
                            prefixIcon: IconAsset.calender,
                            readOnly: true,
                            onTap: () async {
                              String? date = await controller.selectDate();
                              if (date != null) {
                                dobController.text = date;
                                isDobError.value = false;
                              }
                            },
                            fillColor: isDobError.value
                                ? AppColors.errorBgColor
                                : AppColors.whiteColor,
                            enableColor: isDobError.value
                                ? AppColors.errorColor
                                : null,
                            focusedColor: isDobError.value
                                ? AppColors.errorColor
                                : null,
                            hintText: "01/01/1995",
                          ),
                          isDobError.value
                              ? CommonText(
                                  string: AppString.youMustBe18.tr,
                                  color: AppColors.errorColor,
                                ).paddingOnly(top: 2.h)
                              : SizedBox.shrink(),
                        ],
                      ),
                    ),

                    16.verticalSpace,
                    CustomTextField(
                      title: AppString.referCode.tr,
                      titlestarWidget: CommonText(
                        string: " (${AppString.optional.tr})",
                        color: AppColors.textCaptionColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                      ),
                      controller: referController,
                      prefixIcon: IconAsset.tag,
                      hintText: "E.g FRISTDRIVE",
                    ),
                    16.verticalSpace,
                  ],
                ).paddingSymmetric(horizontal: 16.w),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        bottom: Utils().checkPlatForm,

        child: CustomButton(
          text: AppString.continueString.tr,
          sufixIconWidget: true,
          onTap: () {
            if (nameController.text.isEmpty) {
              nameError = AppString.pleaseEnterName.tr;
              isNameError.value = !isNameError.value;
            } else if (!CountryUtils.validatePhoneNumber(
              mobileController.text.trim(),
              countryCode,
            )) {
              isPhoneError.value = true;
            } else if (dobController.text.isEmpty) {
              isDobError.value = true;
            } else if (emailController.text.trim().isNotEmpty &&
                !emailController.text.trim().isValidEmail()) {
              return;
            } else if (dobController.text.isEmpty) {
              isDobError.value = true;
            } else {
              controller.profileDateUpload(
                name: nameController.text.trim(),
                email: emailController.text.trim(),
                phone: mobileController.text.trim(),
                dob: Utils().dateSendServer(dobController.text.trim()),
                referCode: referController.text.trim(),
                countryCode: countryCode,
              );
            }
          },
        ).paddingOnly(left: 16.w, right: 16.w, bottom: 24.w),
      ),
    );
  }
}
