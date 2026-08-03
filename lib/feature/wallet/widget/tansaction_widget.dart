import 'package:e_taxi/utils/utils.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/app_colors.dart';
import '../model/driver_transaction_model.dart';
import '../model/earning_transaction_mode.dart';
import '../model/wallet_transaction_model.dart';

class TransactionWidget extends StatelessWidget {
  const TransactionWidget({required this.data, super.key});

  final RecentTransaction? data;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                string: data?.description ?? "",
                fontWeight: FontWeight.w600,
                softWrap: true,
              ),
              4.verticalSpace,
              CommonText(
                string: data?.time ?? "",
                fontSize: 12.sp,
                color: AppColors.textCaptionColor,
              ),
            ],
          ),
        ),
        6.horizontalSpace,
        CommonText(
          string: Utils.formatCurrency("${data?.amount ?? ""}"),
          color: (data?.isPositive == 1)
              ? AppColors.successColor
              : AppColors.errorColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }
}

class TransactionWidget1 extends StatelessWidget {
  const TransactionWidget1({
    required this.data,
    required this.onTap,
    super.key,
  });

  final Transaction? data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  string: "${data?.type ?? ""} ${data?.description ?? ""}",
                  fontWeight: FontWeight.w600,
                  softWrap: true,
                ),
                4.verticalSpace,
                CommonText(
                  string: data?.time ?? "",
                  fontSize: 12.sp,
                  color: AppColors.textCaptionColor,
                ),
              ],
            ),
          ),
          6.horizontalSpace,

          CommonText(
            string: "${data?.amount ?? ""}",
            color: (data?.isPositive ?? false)
                ? AppColors.successColor
                : AppColors.errorColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}

class TransactionWidget2 extends StatelessWidget {
  const TransactionWidget2({
    required this.data,
    required this.onTap,
    super.key,
  });

  final TransactionTransaction? data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  string: data?.description ?? "",
                  fontWeight: FontWeight.w600,
                  softWrap: true,
                ),
                4.verticalSpace,
                CommonText(
                  string: data?.time ?? "",
                  fontSize: 12.sp,
                  color: AppColors.textCaptionColor,
                ),
              ],
            ),
          ),
          6.horizontalSpace,
          CommonText(
            string: "${data?.amount ?? ""}",
            color: (data?.isPositive == 1)
                ? AppColors.successColor
                : AppColors.errorColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}
