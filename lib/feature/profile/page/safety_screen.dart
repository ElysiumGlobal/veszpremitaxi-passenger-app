import 'package:country_pickers/country.dart' as country;
import 'package:country_pickers/country_pickers.dart';
import 'package:e_taxi/feature/home/widget/dialog.dart';
import 'package:e_taxi/feature/profile/controller/profile_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:e_taxi/utils/validation_utils.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../../../utils/app_country_picker.dart';
import '../../../utils/app_string.dart';
import '../../../utils/log_utils.dart';
import '../../../widgets/appbar.dart';

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      profileController.getEmergencyContact();
    });
  }

  List iconList = [
    ImagesAsset.ambulance,
    ImagesAsset.police,
    ImagesAsset.liveLocation,
    ImagesAsset.trustContact,
  ];

  final profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      appBar: CustomAppBar(title: AppString.safety.tr, centerTitle: false),
      body: SafeArea(
        bottom: Utils().checkPlatForm,
        child: Column(
          children: [
            CommonText(
              string:
                  "We’re committed to keeping you protected on every ride. Learn how our safety features — like live tracking, verified drivers, and SOS support — work together for your peace of mind.",
              softWrap: true,
            ),

            24.verticalSpace,

            MasonryGridView.count(
              crossAxisSpacing: 16.w,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12.h,
              itemCount: 4,
              crossAxisCount: 2,
              itemBuilder: (context, index) {
                return CustomImage(image: iconList[index], ht: 131.h);
              },
            ),
            19.verticalSpace,

            GestureDetector(
              onTap: () {
                AppDialog.commonBottomSheetWidget(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CommonText(
                        string: AppString.emergencyContact.tr,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      16.verticalSpace,
                      CommonText(
                        string: AppString.youSave5Contact.tr,
                        softWrap: true,
                      ),
                      16.verticalSpace,

                      Obx(
                        () => ListView.separated(
                          separatorBuilder: (context, index) =>
                              16.verticalSpace,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: profileController.contactList.length,
                          itemBuilder: (context, index) {
                            final data = profileController.contactList[index];

                            return GestureDetector(
                              onTap: () {
                                Utils().launchDialer(data.mobileNumber ?? "");
                                LogUtils.printAction("TAP");
                              },

                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    12.r,
                                  ),
                                  border: Border.all(
                                    color: AppColors.textFieldBorderColor,
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Utils().launchDialer(
                                      data.mobileNumber ?? "",
                                    );
                                    LogUtils.printAction("TAP");
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 40.h,
                                        width: 40.h,
                                        decoration: BoxDecoration(
                                          color: AppColors.textFieldBorderColor,

                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: CommonText(
                                          string: (data.name ?? "").isNotEmpty
                                              ? (data.name ?? "")[0]
                                                    .toUpperCase()
                                              : "",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15.sp,
                                        ),
                                      ),
                                      18.horizontalSpace,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CommonText(
                                              string: data.name ?? "",
                                              fontSize: 16.sp,
                                            ),
                                            4.verticalSpace,
                                            CommonText(
                                              string: data.mobileNumber ?? "",
                                              fontSize: 14.sp,
                                              color: AppColors.textCaptionColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                      18.horizontalSpace,

                                      GestureDetector(
                                        onTap: () async {
                                          AppDialog.commonDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                            ),
                                            childs: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CommonText(
                                                  string: AppString
                                                      .deleteContact
                                                      .tr,
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                16.verticalSpace,
                                                CommonText(
                                                  string: AppString
                                                      .areYouSureDeleteContact
                                                      .tr,
                                                  softWrap: true,
                                                  textAlign: TextAlign.center,
                                                ),
                                                16.verticalSpace,
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: CustomButton(
                                                        text: AppString.no.tr,
                                                        onTap: () {
                                                          Get.back();
                                                        },
                                                        buttonColor: AppColors
                                                            .transparent,
                                                        borderColor: AppColors
                                                            .blackColor,
                                                      ),
                                                    ),
                                                    16.horizontalSpace,
                                                    Expanded(
                                                      child: CustomButton(
                                                        text: AppString.yes.tr,
                                                        onTap: () async {
                                                          final res =
                                                              await profileController
                                                                  .deleteEmergency(
                                                                    data.id ??
                                                                        0,
                                                                    index,
                                                                  );
                                                          if (res.isNotEmpty) {
                                                            Get.back();
                                                            AppSnackBar.showErrorSnackBar(
                                                              message:
                                                                  res['message'],
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        child: Container(
                                          height: 40.h,
                                          width: 40.h,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.errorBgColor,
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            CupertinoIcons.delete,
                                            color: AppColors.errorColor,
                                            size: 20.h,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      24.verticalSpace,

                      Obx(
                        () => CustomButton(
                          text: profileController.contactList.isEmpty
                              ? AppString.add.tr
                              : AppString.addMore.tr,
                          onTap: () {
                            if (profileController.contactList.length == 5) {
                              AppSnackBar.showErrorSnackBar(
                                message: "Not add more then 5 contacts",
                                isError: true,
                              );
                              return;
                            }

                            TextEditingController nameController =
                                TextEditingController();
                            TextEditingController phoneController =
                                TextEditingController();

                            final Rx<country.Country> selectedDialogCountry =
                                CountryPickerUtils.getCountryByPhoneCode(
                                  "36",
                                ).obs;

                            String code = "+36";

                            AppDialog.commonBottomSheetWidget(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: CommonText(
                                      string: AppString.addContact.tr,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18.sp,
                                    ),
                                  ),
                                  24.verticalSpace,
                                  CustomTextField(
                                    controller: nameController,
                                    hintText: AppString.fullName.tr,
                                    title: AppString.name.tr,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  16.verticalSpace,

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
                                          () => CountryPickerWidget1(
                                            phoneController:
                                                TextEditingController(),
                                            country:
                                                selectedDialogCountry.value,
                                            onTap: (v) {
                                              code = "+${v.phoneCode}";

                                              selectedDialogCountry.value =
                                                  CountryPickerUtils.getCountryByPhoneCode(
                                                    v.phoneCode,
                                                  );
                                            },
                                          ).paddingOnly(right: 10.w),
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            cursorColor:
                                                AppColors.mainPrimaryColor,
                                            controller: phoneController,
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
                                              hintText: "9988776655",
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

                                  24.verticalSpace,
                                  CustomButton(
                                    onTap: () async {
                                      if (nameController.text
                                              .trim()
                                              .textDataIsNotValid(
                                                AppString
                                                    .pleaseEnterFirstName
                                                    .tr,
                                              ) ||
                                          !phoneController.text.phoneValid(
                                            phoneController.text,
                                            code,
                                          )) {
                                        return;
                                      }

                                      final res = await profileController
                                          .addEmergencyContact(
                                            name: nameController.text.trim(),
                                            phone:
                                                "$code ${phoneController.text.trim()}",
                                          );

                                      if (res.isNotEmpty) {
                                        Get.back();
                                        AppSnackBar.showErrorSnackBar(
                                          message: res['message'],
                                        );
                                      }
                                    },
                                    text: AppString.add.tr,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textFieldBorderColor),
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText(
                      string: AppString.addContact.tr,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                    ),
                    CustomImage(image: IconAsset.arrowRightIcon1),
                  ],
                ),
              ),
            ),
          ],
        ).paddingAll(16.w),
      ),
    );
  }
}
