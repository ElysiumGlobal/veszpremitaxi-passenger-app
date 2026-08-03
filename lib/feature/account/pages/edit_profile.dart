import 'dart:io';

import 'package:e_taxi/feature/account/controller/account_controller.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:e_taxi/utils/validation_utils.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_string.dart';
import '../../../utils/assets.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/cacheNetworkImage.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/common_widget.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfeild.dart';
import '../../../widgets/custome_img.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final accountController = Get.find<AccountController>();
  Rxn<XFile> profileImage = Rxn<XFile>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    nameController.text = accountController.userModel.value?.name ?? "";
    emailController.text = accountController.userModel.value?.email ?? "";
    phoneController.text = accountController.userModel.value?.phone ?? "";
    dobController.text = Utils().serverToShow(
      accountController.userModel.value?.dateOfBirth ?? "",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      appBar: CustomAppBar(title: AppString.editProfile.tr, centerTitle: false),
      body: SingleChildScrollView(
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: AlignmentGeometry.center,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      height: 110.h,
                      width: 110.h,
                      padding: EdgeInsets.all(5.h),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.mainPrimaryColor,
                          width: 3.h,
                        ),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(110.r),
                        child: profileImage.value == null
                            ? NetworkImageWidget(
                                image:
                                    accountController
                                        .userModel
                                        .value
                                        ?.profilePhoto ??
                                    "",
                                ht: 97.h,
                                wt: 97.h,
                                radius: 110.h,
                              )
                            : Image.file(
                                File(profileImage.value?.path ?? ""),
                                fit: BoxFit.cover,
                                height: 97.h,
                                width: 97.h,
                              ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () async {
                        final image = await CustomWidget.takeImage(
                          ImageSource.gallery,
                        );

                        if (image != null) {
                          profileImage.value = image;
                        }
                      },
                      child: CustomImage(
                        image: IconAsset.edit1,
                        ht: 32.h,
                        wt: 32.h,
                      ),
                    ),
                  ],
                ),
              ),
              30.verticalSpace,

              CustomTextField(
                title: AppString.name.tr,
                controller: nameController,
                textinputformate: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                ],
              ),
              16.verticalSpace,
              CustomTextField(
                readOnly: true,
                title: AppString.mobileNumber.tr,
                controller: phoneController,
              ),
              16.verticalSpace,
              CustomTextField(
                title: AppString.email.tr,
                titlestarWidget: CommonText(
                  string: " (${AppString.optional.tr})",
                  color: AppColors.textCaptionColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                ),
                hintText: "E.g Demo@gmail.com",
                controller: emailController,
                readOnly:
                    accountController.userModel.value?.loginDevice != "phone",
              ),
              16.verticalSpace,
              CustomTextField(
                title: AppString.dob.tr,
                controller: dobController,
                prefixIcon: IconAsset.calender,
                readOnly: true,
                onTap: () async {
                  String? date = await accountController.selectDate(
                    Utils().stringToDateTime(dobController.text),
                  );
                  if (date != null) {
                    dobController.text = date;
                  }
                },
                hintText: "01/01/1995",
              ),
            ],
          ).paddingAll(16.w),
        ),
      ),

      bottomNavigationBar: SafeArea(
        bottom: Utils().checkPlatForm,
        child: CustomButton(
          text: AppString.updateAndSave.tr,
          onTap: () async {
            if (nameController.text.isEmpty) {
              AppSnackBar.showErrorSnackBar(
                message: AppString.pleaseEnterName.tr,
              );
              return;
            }
            if (emailController.text.trim().isNotEmpty &&
                !emailController.text.trim().isValidEmail()) {
              return;
            }

            final res = await accountController.updateProfile(
              imagePath: profileImage.value?.path ?? "",
              name: nameController.text.trim(),
              dob: Utils().dateSendServer(dobController.text.trim()),
              email: emailController.text.trim(),
            );

            if (res.isNotEmpty) {
              Navigation.pop();
              AppSnackBar.showErrorSnackBar(
                message: "A profil frissítése sikerült.",
              );
            }
          },
        ).paddingOnly(left: 16.w, right: 16.w, bottom: 16.w),
      ),
    );
  }
}
