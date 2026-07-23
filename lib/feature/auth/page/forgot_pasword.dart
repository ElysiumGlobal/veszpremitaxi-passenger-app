import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/build_config.dart';
import 'package:e_taxi/utils/validation_utils.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/app_string.dart';
import '../../../utils/log_utils.dart';
import '../../../widgets/app_snackbar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.whiteGrey,
      appBar: CustomAppBar(
        centerTitle: false,
        title: AppString.forgotPassword.tr,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            string: AppString.forgotPassword.tr,
            fontWeight: FontWeight.w500,
            fontSize: 22.sp,
          ),
          30.verticalSpace,
          CustomTextField(
            controller: emailController,
            hintText: "John@gmail.com",
          ),
        ],
      ).paddingAll(16.w),
      bottomNavigationBar: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.w,
            left: 16.w,
            right: 16.w,
          ),
          child: CustomButton(
            text: AppString.submit.tr,
            onTap: () async {
              if (!emailController.text.trim().isValidEmail()) {
                return;
              }

              if (!BuildConfig.firebaseEnabled) return;

              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: emailController.text.trim(),
                );
                Get.back();
                AppSnackBar.showErrorSnackBar(
                  message:
                      "We have sent you a email on ${emailController.text.trim()}",
                );
              } catch (e) {
                LogUtils.printAction("Send forgot email error::$e");
              }
            },
          ),
        ),
      ),
    );
  }
}
