import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/app_string.dart';
import '../../../utils/utils.dart';
import '../../../widgets/appbar.dart';
import '../model/support_model.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({required this.category, super.key});

  final Category category;

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppString.faqs.tr, centerTitle: false),
      body: SafeArea(
        bottom: Utils().checkPlatForm,

        child: ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemBuilder: (context, index) {
            final data = widget.category.topics?[index];
            return tileWidget(
              title: "${index + 1}. ${data?.title ?? ""}",
              subTitle: data?.description ?? "",
            );
          },
          separatorBuilder: (context, index) {
            return 16.verticalSpace;
          },
          itemCount: (widget.category.topics ?? []).length,
        ),
      ),
    );
  }

  Widget tileWidget({required String title, required String subTitle}) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: AppColors.transparent),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: AppColors.whiteColor,
        ),
        child: ExpansionTile(
          title: CommonText(
            string: "$title?",
            fontWeight: FontWeight.w500,
            softWrap: true,
            fontSize: 14.sp,
          ),
          children: [
            CommonText(
              string: subTitle,
              fontSize: 12.sp,
              color: AppColors.headlineColor,
              softWrap: true,
            ).paddingOnly(bottom: 6.h, left: 12.w, right: 12.w),
          ],
        ),
      ),
    );
  }
}
