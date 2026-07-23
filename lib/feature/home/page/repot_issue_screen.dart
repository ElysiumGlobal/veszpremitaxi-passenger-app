import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_button.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerTitle: false,
        title: AppString.reportIssues.tr,
      ),
      bottomNavigationBar: SafeArea(
        bottom: Utils().checkPlatForm,
        child: Padding(
          padding: EdgeInsets.all(16.w),

          child: CustomButton(
            text: AppString.submit.tr,
            onTap: () {
              Navigation.replaceAll(Routes.dashboardScreen);
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),

          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: AppColors.whiteColor,
            ),
            child: Column(
              children: [
                CommonText(
                  string: AppString.pleaseSelectReason.tr,
                  fontWeight: FontWeight.w500,
                  fontSize: 16.sp,
                  softWrap: true,
                ),
                Divider(color: AppColors.textFieldBorderColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
