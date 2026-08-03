import 'package:e_taxi/feature/wallet/controller/wallet_controller.dart';
import 'package:e_taxi/utils/constants.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:e_taxi/widgets/dotted_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_string.dart';
import '../../../utils/assets.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custome_img.dart';
import '../../../widgets/no_data_widget.dart';
import '../../../widgets/webview_screen.dart';
import '../widget/title_subtitle.dart';
import 'earning_transaction_screen.dart';

class EarningDetailsScreen extends StatefulWidget {
  const EarningDetailsScreen({super.key});

  @override
  State<EarningDetailsScreen> createState() => _EarningDetailsScreenState();
}

class _EarningDetailsScreenState extends State<EarningDetailsScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Get.arguments != null) {
      model = Get.arguments;

      if ((model.bookingCode ?? "").isNotEmpty) {
        walletController.getEarningDetailsData(
          bookingCode: model.bookingCode ?? "",
        );
      } else {
        if (model.type == 2) {
          walletController.getEarningCancellationFee(
            transactionId: model.transactionId ?? "",
          );
        } else {
          walletController.getEarningRefund(
            transactionId: model.transactionId ?? "",
          );
        }
      }
    }
  }

  EarningDetailsDataModel model = EarningDetailsDataModel();

  final walletController = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppString.earningDetails.tr,
        centerTitle: false,
        actions: [
          if ((model.type ?? 1) == 1)
            GestureDetector(
              onTap: () {
                final box = context.findRenderObject() as RenderBox?;

                SharePlus.instance.share(
                  ShareParams(
                    title: "PDF-jelentés",
                    uri: Uri.parse(
                      "${walletController.earningDetailsModel.value?.data?.downloadLink ?? ""}",
                    ),
                    sharePositionOrigin:
                        box!.localToGlobal(Offset.zero) & box.size,
                  ),
                );
              },
              child: CustomImage(image: IconAsset.shareIcon),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        bottom: Utils().checkPlatForm,

        child: Obx(
          () => Skeletonizer(
            enabled: walletController.earningDetailsLoading.value,
            child: CustomButton(
              text: ((model.type ?? 1) == 1)
                  ? AppString.downloadReceipt.tr
                  : ((model.type ?? 1) == 2)
                  ? AppString.reportIssue.tr
                  : AppString.contactSupport.tr,
              onTap: walletController.earningDetailsLoading.value
                  ? null
                  : () {
                      if ((model.type ?? 1) == 1) {
                        Utils().downloadPdf(
                          "${walletController.earningDetailsModel.value?.data?.downloadLink ?? ""}",
                          "${walletController.earningDetailsModel.value?.data?.bookingCode}",
                        );
                      } else if ((model.type ?? 1) == 2) {
                        Navigation.pushNamed(
                          Routes.walletReportScreen,
                          params: {
                            'bookingId':
                                "${walletController.earningCancelModel.value?.data?.bookingId ?? ""}",
                            "transactionId":
                                "${walletController.earningCancelModel.value?.data?.transactionId ?? ""}",
                          },
                        );
                      } else {
                        Get.to(
                          () => WebviewScreen(webUrl: Constants().contactUs),
                        );
                      }
                    },
            ).paddingOnly(left: 16.w, right: 16.w, bottom: 16.w),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Obx(
          () => walletController.earningDetailsLoading.value
              ? Skeletonizer(
                  enabled: true,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              CommonText(string: "ASdad", fontSize: 26.sp),
                              4.verticalSpace,
                              CommonText(string: "Asdad asd sdf "),
                              4.verticalSpace,

                              Container(
                                width: 100,
                                height: 70,
                                color: AppColors.whiteColor,
                              ),
                              16.verticalSpace,
                              commonRow(
                                title: "AS",
                                subTitle: "Dsf",
                              ).paddingSymmetric(vertical: 8),
                              commonRow(
                                title: "AS",
                                subTitle: "Dsf",
                              ).paddingSymmetric(vertical: 8),
                              commonRow(
                                title: "AS",
                                subTitle: "Dsf",
                              ).paddingSymmetric(vertical: 8),
                              commonRow(
                                title: "AS",
                                subTitle: "Dsf",
                              ).paddingSymmetric(vertical: 8),
                            ],
                          ),
                        ),
                      ],
                    ).paddingAll(16.w),
                  ),
                )
              : walletController.earningDetailsError.value
              ? NoDataWidget(
                  icon: ImagesAsset.noData,
                  title: AppString.noDataAvailable.tr,
                  subTitle: AppString.weNotFindAnything.tr,
                  onTap: () {
                    if ((model.bookingCode ?? "").isNotEmpty) {
                      walletController.getEarningDetailsData(
                        bookingCode: model.bookingCode ?? "",
                      );
                    } else {
                      if (model.type == 2) {
                        walletController.getEarningCancellationFee(
                          transactionId: model.transactionId ?? "",
                        );
                      } else {
                        walletController.getEarningRefund(
                          transactionId: model.transactionId ?? "",
                        );
                      }
                    }
                  },
                )
              : model.type == 1
              ? Column(
                  children: [
                    24.verticalSpace,
                    Container(
                      padding: EdgeInsets.all(16.w),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.textFieldBorderColor,
                        ),
                        color: AppColors.whiteColor,
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16.w),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: AppColors.textFieldBorderColor,
                              ),
                              color: AppColors.whiteColor,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CommonText(
                                  string: Utils.formatCurrency(
                                    walletController
                                        .earningDetailsModel
                                        .value
                                        ?.data
                                        ?.totalEarning
                                        .toString(),
                                  ),
                                  fontSize: 24.sp,
                                ),
                                16.verticalSpace,
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 10.w,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    color: getBgColor(""),
                                    border: Border.all(color: getTextColor("")),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomImage(
                                        image: getIcon("completed"),
                                        color: getTextColor(""),
                                      ),
                                      4.horizontalSpace,
                                      CommonText(
                                        string:
                                            "${walletController.earningDetailsModel.value?.data?.paymentType ?? ""}",
                                      ),
                                    ],
                                  ),
                                ),
                                16.verticalSpace,
                                IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: CommonColumn(
                                          title:
                                              "${walletController.earningDetailsModel.value?.data?.bookingId}",
                                          subTitle: AppString.tripId.tr,
                                        ),
                                      ),
                                      VerticalDivider(
                                        color: AppColors.textFieldBorderColor,
                                      ),
                                      Expanded(
                                        child: CommonColumn(
                                          title:
                                              "${walletController.earningDetailsModel.value?.data?.distance}",
                                          subTitle: AppString.distance.tr,
                                        ),
                                      ),
                                      VerticalDivider(
                                        color: AppColors.textFieldBorderColor,
                                      ),
                                      Expanded(
                                        child: CommonColumn(
                                          title:
                                              "${walletController.earningDetailsModel.value?.data?.duration}",
                                          subTitle: AppString.duration.tr,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          24.verticalSpace,

                          Column(
                            children: [
                              commonRow(
                                title: AppString.baseFare.tr,
                                subTitle: Utils.formatCurrency(
                                  "${walletController.earningDetailsModel.value?.data?.earningBreakdown?.baseFare}",
                                ),
                              ),
                              commonRow(
                                title: AppString.distanceFare.tr,
                                subTitle: Utils.formatCurrency(
                                  "${walletController.earningDetailsModel.value?.data?.earningBreakdown?.distanceFare}",
                                ),
                              ),
                              commonRow(
                                title: AppString.waitingCharge.tr,
                                subTitle: Utils.formatCurrency(
                                  "${walletController.earningDetailsModel.value?.data?.earningBreakdown?.waitingCharge}",
                                ),
                              ),
                              commonRow(
                                title: AppString.timeFare.tr,
                                subTitle: Utils.formatCurrency(
                                  "${walletController.earningDetailsModel.value?.data?.earningBreakdown?.timeFare}",
                                ),
                              ),
                              commonRow(
                                title: AppString.nightCharge.tr,
                                subTitle: Utils.formatCurrency(
                                  "${walletController.earningDetailsModel.value?.data?.earningBreakdown?.nightCharge}",
                                ),
                              ),
                              commonRow(
                                title: AppString.bookingFare.tr,
                                subTitle: Utils.formatCurrency(
                                  "${walletController.earningDetailsModel.value?.data?.earningBreakdown?.bookingFee}",
                                ),
                              ),
                              commonRow(
                                title: AppString.surgeCharge.tr,
                                subTitle: Utils.formatCurrency(
                                  "${walletController.earningDetailsModel.value?.data?.earningBreakdown?.surgeAmount}",
                                ),
                              ),
                              commonRow(
                                title: AppString.tax.tr,
                                subTitle:
                                    "${Utils.formatCurrency("${walletController.earningDetailsModel.value?.data?.earningBreakdown?.taxAmount}")}",
                              ),
                              commonRow(
                                title: AppString.tipReceived.tr,
                                subTitle: Utils.formatCurrency(
                                  "${walletController.earningDetailsModel.value?.data?.earningBreakdown?.tipReceived}",
                                ),
                              ),

                              DottedWidget().paddingOnly(bottom: 16.h),

                              commonRow(
                                title: AppString.totalFare.tr,
                                subTitle: Utils.formatCurrency(
                                  "${walletController.earningDetailsModel.value?.data?.earningBreakdown?.totalFare}",
                                ),
                                bigText: true,
                              ),
                              commonRow(
                                title: AppString.platformFee.tr,
                                subTitle:
                                    "-${Utils.formatCurrency("${walletController.earningDetailsModel.value?.data?.deductionBreakdown?.platformFee}")}",
                              ),
                              commonRow(
                                title: AppString.tax.tr,
                                subTitle:
                                    "-${Utils.formatCurrency("${walletController.earningDetailsModel.value?.data?.deductionBreakdown?.tax}")}",
                              ),
                              commonRow(
                                title: AppString.lateArrivalPenalty.tr,
                                subTitle:
                                    "-${Utils.formatCurrency("${walletController.earningDetailsModel.value?.data?.deductionBreakdown?.lateArrivalPenalty}")}",
                              ),
                              commonRow(
                                title: AppString.discountAmount.tr,
                                subTitle:
                                    "-${Utils.formatCurrency("${walletController.earningDetailsModel.value?.data?.deductionBreakdown?.discount}")}",
                              ),
                              DottedWidget().paddingOnly(bottom: 16.h),
                              commonRow(
                                title: AppString.totalDeduction.tr,
                                subTitle: Utils.formatCurrency(
                                  "${walletController.earningDetailsModel.value?.data?.deductionBreakdown?.totalDeduction}",
                                ),
                                bigText: true,
                              ),
                              DottedWidget().paddingOnly(bottom: 16.h),

                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: AppColors.successColor,
                                  ),
                                  color: AppColors.sucessContainer,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CommonText(
                                      string: AppString.totalTripEarning.tr,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16.sp,
                                    ),
                                    CommonText(
                                      string:
                                          "${walletController.earningDetailsModel.value?.data?.finalEarning}",
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    16.verticalSpace,
                  ],
                ).paddingSymmetric(horizontal: 16.w)
              : model.type == 2
              ? Column(
                  children: [
                    24.verticalSpace,
                    Container(
                      padding: EdgeInsets.all(16.w),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.textFieldBorderColor,
                        ),
                        color: AppColors.whiteColor,
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16.w),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: AppColors.textFieldBorderColor,
                              ),
                              color: AppColors.whiteColor,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CommonText(
                                  string: Utils.formatCurrency(
                                    walletController
                                        .earningCancelModel
                                        .value
                                        ?.data
                                        ?.amount
                                        .toString(),
                                  ),
                                  fontSize: 24.sp,
                                ),
                                if ((model.bookingCode ?? "").isEmpty)
                                  CommonText(
                                    string:
                                        "Transaction ID: ${walletController.earningCancelModel.value?.data?.transactionId ?? ""}",
                                    fontSize: 12.sp,
                                  ).paddingOnly(top: 4.h),
                                16.verticalSpace,
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 10.w,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    color: getBgColor("failed"),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomImage(
                                        image: getIcon("failed"),
                                        color: getTextColor("failed"),
                                      ),
                                      4.horizontalSpace,
                                      CommonText(
                                        string:
                                            "${walletController.earningCancelModel.value?.data?.type ?? ""}",
                                        color: getTextColor("failed"),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          24.verticalSpace,

                          Column(
                            children: [
                              commonRow(
                                title: "${AppString.tripId.tr} : ",
                                subTitle:
                                    "${walletController.earningCancelModel.value?.data?.bookingCode ?? ""}",
                              ),
                              commonRow(
                                title: "${AppString.date.tr} : ",
                                subTitle:
                                    "${walletController.earningCancelModel.value?.data?.date ?? ""}",
                              ),
                              commonRow(
                                title: "${AppString.amount.tr} : ",
                                subTitle:
                                    "${walletController.earningCancelModel.value?.data?.amount ?? ""}",
                              ),
                              12.verticalSpace,
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: AppColors.successColor,
                                  ),
                                  color: AppColors.sucessContainer,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CommonText(string: AppString.reason.tr),
                                    CommonText(
                                      string:
                                          "${walletController.earningCancelModel.value?.data?.reason ?? ""}",
                                      softWrap: true,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ).paddingSymmetric(horizontal: 16.w)
              : Column(
                  children: [
                    24.verticalSpace,
                    Container(
                      padding: EdgeInsets.all(16.w),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.textFieldBorderColor,
                        ),
                        color: AppColors.whiteColor,
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16.w),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: AppColors.textFieldBorderColor,
                              ),
                              color: AppColors.whiteColor,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CommonText(
                                  string: Utils.formatCurrency(
                                    "${walletController.earningRefundModel.value?.data?.amount}",
                                  ),
                                  fontSize: 24.sp,
                                ),
                                if ((model.bookingCode ?? "").isEmpty)
                                  CommonText(
                                    string:
                                        "${walletController.earningRefundModel.value?.data?.description ?? ""}",
                                    softWrap: true,
                                    fontSize: 12.sp,
                                    textAlign: TextAlign.center,
                                  ).paddingOnly(top: 4.h),
                                16.verticalSpace,
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 10.w,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    color: getBgColor("completed"),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomImage(
                                        image: getIcon("completed"),
                                        color: getTextColor("completed"),
                                      ),
                                      4.horizontalSpace,
                                      CommonText(
                                        string:
                                            "${walletController.earningRefundModel.value?.data?.status ?? ""}",
                                        color: getTextColor("completed"),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          24.verticalSpace,


                          Column(
                            children: [
                              commonRow(
                                title: "${AppString.creditedIntoWallet.tr} : ",
                                subTitle:
                                    "${walletController.earningRefundModel.value?.data?.amount ?? ""}",
                              ),
                              commonRow(
                                title: "${AppString.reviewBy.tr} : ",
                                subTitle:
                                    "${walletController.earningRefundModel.value?.data?.reviewedBy ?? ""}",
                              ),
                              commonRow(
                                title: "${AppString.creditedBy.tr} : ",
                                subTitle:
                                    "${walletController.earningRefundModel.value?.data?.creditedOn ?? ""}",
                              ),
                              commonRow(
                                title: "${AppString.referenceId.tr} : ",
                                subTitle:
                                    "${walletController.earningRefundModel.value?.data?.referenceId ?? ""}",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    16.verticalSpace,
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.textFieldBorderColor,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        color: AppColors.whiteColor,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomImage(
                            image: IconAsset.infoCircle,
                            color: AppColors.blackColor,
                            ht: 24.h,
                            wt: 24.h,
                          ),
                          6.horizontalSpace,
                          Expanded(
                            child: CommonText(
                              string:
                                  "Refund typically Tack 3-5 Business Day to Appear into  Your Account Depanding Your Bank Processing Time",
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).paddingSymmetric(horizontal: 16.w),
        ),
      ),
    );
  }

  Widget commonRow({
    required String title,
    required String subTitle,
    bool bigText = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CommonText(
          string: title,
          fontSize: bigText ? 16.sp : 14.sp,
          fontWeight: bigText ? FontWeight.w600 : FontWeight.w400,
        ),
        CommonText(
          string: subTitle,
          fontSize: bigText ? 16.sp : 14.sp,
          fontWeight: bigText ? FontWeight.w600 : FontWeight.w400,
        ),
      ],
    ).paddingOnly(bottom: 12.h);
  }

  String getIcon(String value) {
    switch (value) {
      case "completed":
        return IconAsset.walletCheck;
      case "failed":
        return IconAsset.walletCancel;
      default:
        return IconAsset.walletCheck;
    }
  }

  Color getTextColor(String value) {
    switch (value) {
      case "completed":
        return AppColors.successColor;
      case "failed":
        return AppColors.errorColor;
      default:
        return AppColors.mainPrimaryColor;
    }
  }

  Color getBgColor(String value) {
    switch (value) {
      case "completed":
        return AppColors.sucessContainer;
      case "failed":
        return AppColors.errorBgColor;
      default:
        return AppColors.primaryContainer;
    }
  }
}
