import 'package:e_taxi/feature/wallet/controller/wallet_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../utils/assets.dart';
import '../../../utils/utils.dart';
import '../../../widgets/no_data_widget.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final walletController = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      appBar: CustomAppBar(
        title: AppString.wallet.tr,
        centerTitle: false,
        leading: SizedBox(width: 16.w),
        leadingSize: 16.w,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Obx(
          () => walletController.isLoading.value
              ? Skeletonizer(
                  enabled: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 120.h,
                        width: double.infinity,
                        color: AppColors.whiteColor,
                      ),
                      16.verticalSpace,

                      Skeletonizer(
                        child: Container(
                          height: Get.height * .4,
                          width: double.infinity,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(top: 12.h, bottom: 24.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: AppColors.textFieldBorderColor,
                        ),
                        color: AppColors.whiteColor,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CommonText(
                            string: Utils.formatCurrency(
                              "${walletController.walletModel.value?.data?.walletInfo?.availableBalance ?? "0"}",
                            ),
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          8.verticalSpace,
                          CommonText(
                            string: AppString.currentBalanceAvailable.tr,
                            color: AppColors.textCaptionColor,
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                    16.verticalSpace,

                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.textFieldBorderColor,
                          ),
                          color: AppColors.whiteColor,
                        ),
                        child:
                            (walletController
                                        .walletModel
                                        .value
                                        ?.data
                                        ?.transactions
                                        ?.data ??
                                    [])
                                .isEmpty
                            ? RefreshIndicator(
                                onRefresh: () async {
                                  await walletController.getWalletData();
                                },
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return SingleChildScrollView(
                                      physics: AlwaysScrollableScrollPhysics(),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: constraints.maxHeight,
                                        ),
                                        child: IntrinsicHeight(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Spacer(),
                                              NoDataWidget(
                                                icon: ImagesAsset.noData,
                                                title: AppString
                                                    .noDataAvailable
                                                    .tr,
                                                subTitle: AppString
                                                    .weNotFindAnything
                                                    .tr,
                                                onTap: () {},
                                              ),
                                              Spacer(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () async {
                                  await walletController.getWalletData();
                                },
                                child: ListView.builder(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemCount:
                                      (walletController
                                                  .walletModel
                                                  .value
                                                  ?.data
                                                  ?.transactions
                                                  ?.data ??
                                              [])
                                          .length,
                                  itemBuilder: (context, index) {
                                    final model = walletController
                                        .walletModel
                                        .value
                                        ?.data
                                        ?.transactions
                                        ?.data?[index];
                                    return Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(12.w),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                            border: Border.all(
                                              color: AppColors
                                                  .textFieldBorderColor,
                                            ),
                                            color: AppColors.whiteGrey,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: CommonText(
                                                  string: model?.month ?? "",
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                              CommonText(
                                                string: Utils.formatCurrency(
                                                  model?.totalAmount,
                                                ),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14.sp,
                                              ),
                                            ],
                                          ),
                                        ),
                                        12.verticalSpace,
                                        ListView.separated(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemBuilder: (context, subIndex) {
                                            final data = walletController
                                                .walletModel
                                                .value
                                                ?.data
                                                ?.transactions
                                                ?.data?[index]
                                                .transactions?[subIndex];
                                            return Row(
                                              key: ValueKey("$index $subIndex"),
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,

                                                    children: [
                                                      CommonText(
                                                        string:
                                                            data?.description ??
                                                            "",
                                                        fontSize: 14.sp,
                                                        softWrap: true,
                                                      ),
                                                      4.verticalSpace,
                                                      CommonText(
                                                        string:
                                                            "${data?.date ?? ""}, ${data?.time ?? ""}",
                                                        fontSize: 14.sp,
                                                        color: AppColors
                                                            .textCaptionColor,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                8.horizontalSpace,
                                                Column(
                                                  children: [
                                                    CommonText(
                                                      string:
                                                          Utils.formatCurrency(
                                                            data?.amount,
                                                          ),
                                                      fontSize: 16.sp,
                                                      color:
                                                          ((data?.isRefunded ??
                                                                      0) ==
                                                                  1 ||
                                                              (data?.referralBonus ??
                                                                      0) ==
                                                                  1)
                                                          ? AppColors
                                                                .successColor
                                                          : AppColors
                                                                .titleTextColor,
                                                    ),
                                                    if ((data?.status ?? "") ==
                                                        "failed")
                                                      CommonText(
                                                        string: "failed",
                                                        fontSize: 12.sp,
                                                        color: AppColors
                                                            .errorColor,
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                          separatorBuilder: (context, index) =>
                                              12.verticalSpace,
                                          itemCount:
                                              (walletController
                                                          .walletModel
                                                          .value
                                                          ?.data
                                                          ?.transactions
                                                          ?.data?[index]
                                                          .transactions ??
                                                      [])
                                                  .length,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
