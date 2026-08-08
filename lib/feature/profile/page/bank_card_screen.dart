import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BankCardScreen extends StatelessWidget {
  const BankCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      appBar: CustomAppBar(
        centerTitle: false,
        title: AppString.bankCard.tr,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                string: AppString.bankCardIntro.tr,
                fontSize: 14.sp,
                color: AppColors.textCaptionColor,
                softWrap: true,
              ),
              16.verticalSpace,
              _CardPreview(),
              16.verticalSpace,
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.textFieldBorderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 42.w,
                          width: 42.w,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.credit_card_rounded,
                            size: 24.w,
                            color: AppColors.brandNavy,
                          ),
                        ),
                        12.horizontalSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                string: AppString.noBankCard.tr,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              6.verticalSpace,
                              CommonText(
                                string: AppString.noBankCardText.tr,
                                fontSize: 13.sp,
                                color: AppColors.textCaptionColor,
                                softWrap: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    18.verticalSpace,
                    CustomButton(
                      text: AppString.addBankCard.tr,
                      textColor: AppColors.titleTextColor,
                      onTap: () => _showSetupInfo(context),
                    ),
                  ],
                ),
              ),
              16.verticalSpace,
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.textFieldBorderColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 20.w,
                      color: AppColors.brandNavy,
                    ),
                    10.horizontalSpace,
                    Expanded(
                      child: CommonText(
                        string: AppString.bankCardSecurityText.tr,
                        fontSize: 13.sp,
                        color: AppColors.textCaptionColor,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSetupInfo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (bottomSheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 22.h),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4.h,
                  width: 42.w,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                22.verticalSpace,
                Container(
                  height: 58.w,
                  width: 58.w,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.credit_card_rounded,
                    size: 30.w,
                    color: AppColors.brandNavy,
                  ),
                ),
                16.verticalSpace,
                CommonText(
                  string: AppString.addBankCard.tr,
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                ),
                10.verticalSpace,
                CommonText(
                  string: AppString.bankCardSetupText.tr,
                  fontSize: 14.sp,
                  color: AppColors.textCaptionColor,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
                22.verticalSpace,
                CustomButton(
                  width: double.infinity,
                  text: AppString.close.tr,
                  onTap: () => Navigator.of(bottomSheetContext).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CardPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 190.h,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandNavy, AppColors.brandNavyLight],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandNavy.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonText(
                string: 'VTAXI',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.whiteColor,
              ),
              Container(
                height: 38.w,
                width: 50.w,
                decoration: BoxDecoration(
                  color: AppColors.mainPrimaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.credit_card_rounded,
                  color: AppColors.brandNavy,
                  size: 26.w,
                ),
              ),
            ],
          ),
          const Spacer(),
          CommonText(
            string: '••••  ••••  ••••  ••••',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.whiteColor,
            letterSpacing: 1.5,
          ),
          20.verticalSpace,
          Row(
            children: [
              Expanded(
                child: _CardMeta(
                  label: AppString.cardHolder.tr,
                  value: '—',
                ),
              ),
              20.horizontalSpace,
              _CardMeta(
                label: AppString.cardExpiry.tr,
                value: '—/—',
                alignEnd: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardMeta extends StatelessWidget {
  const _CardMeta({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.whiteColor.withValues(alpha: 0.68),
            letterSpacing: 0.8,
          ),
        ),
        4.verticalSpace,
        CommonText(
          string: value,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.whiteColor,
        ),
      ],
    );
  }
}
