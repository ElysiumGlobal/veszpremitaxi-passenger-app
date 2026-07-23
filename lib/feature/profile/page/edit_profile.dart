import 'dart:io';

import 'package:e_taxi/feature/profile/controller/profile_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/validation_utils.dart';
import 'package:e_taxi/widgets/cachenetworkimage.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../utils/app_string.dart';
import '../../../utils/log_utils.dart';
import '../../../utils/utils.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/common_widget.dart';
import '../../../widgets/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    nameController.text = profileController.userModel.value?.name ?? "";
    phoneController.text = profileController.userModel.value?.phone ?? "";
    emailController.text = profileController.userModel.value?.email ?? "";
    addressController.text = profileController.userModel.value?.address ?? "";
  }

  final profileController = Get.find<ProfileController>();

  Rxn<XFile> profileImage = Rxn<XFile>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
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
                                    profileController
                                        .userModel
                                        .value
                                        ?.profilePhoto ??
                                    "",
                                ht: 97.h,
                                wt: 97.h,
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
                title: AppString.email.tr,
                controller: emailController,

                readOnly:
                    profileController.userModel.value?.loginDevice != "phone",
              ),
              16.verticalSpace,

              CustomTextField(
                readOnly: true,
                title: AppString.phoneNumber.tr,
                controller: phoneController,
              ),
              16.verticalSpace,

              CustomTextField(
                title: AppString.address.tr,
                controller: addressController,
              ),
            ],
          ).paddingAll(16.w),
        ),
      ),

      bottomNavigationBar: SafeArea(
        bottom: Utils().checkPlatForm,

        child: CustomButton(
          text: AppString.updateAndSave.tr,
          onTap: () {
            if (nameController.text.trim().textDataIsNotValid(
              AppString.fullNameRequired.tr,
            )) {
              LogUtils.printAction("HERE");
              return;
            }

            if (emailController.text.trim().isNotEmpty &&
                !emailController.text.trim().isValidEmail()) {
              return;
            }

            profileController.updateProfile(
              name: nameController.text.tr,
              email: emailController.text.trim(),
              address: addressController.text.tr,
              imagePath: profileImage.value?.path ?? "",
            );
          },
        ).paddingOnly(left: 16.w, right: 16.w, bottom: 16.w),
      ),
    );
  }
}
