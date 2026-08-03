import 'package:e_taxi/feature/wallet/controller/wallet_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/constants.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../utils/app_string.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/dotted_widget.dart';
import '../../../widgets/no_data_widget.dart';
import '../../../widgets/webview_screen.dart';

class WalletDetailsScreen extends StatefulWidget {
  const WalletDetailsScreen({super.key});

  @override
  State<WalletDetailsScreen> createState() => _WalletDetailsScreenState();
}

class _WalletDetailsScreenState extends State<WalletDetailsScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Get.arguments != null) {
      Future.microtask(() {
        walletController.getWalletTransactionDetails(
          transactionId: Get.arguments.toString(),
        );
      });
    }
  }

  final walletController = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppString.transactionDetails.tr,
        centerTitle: false,

        actions: [
          if ((walletController
                      .walletDetailsModel
                      .value
                      ?.data
                      ?.transaction
                      ?.downloadLink ??
                  "")
              .isNotEmpty)
            GestureDetector(
              onTap: () {
                final box = context.findRenderObject() as RenderBox?;

                SharePlus.instance.share(
                  ShareParams(
                    title: "Report Pdf",
                    uri: Uri.parse(
                      "${walletController.walletDetailsModel.value?.data?.transaction?.downloadLink ?? ""}",
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
      body: SafeArea(
        child: Obx(
          () => walletController.walletDetailsLoading.value
              ? Center(child: CircularProgressIndicator())
              : walletController.walletDetailsError.value
              ? NoDataWidget(
                  icon: ImagesAsset.tryAgain,
                  title: AppString.noDataAvailable.tr,
                  subTitle: AppString.weNotFindAnything.tr,
                  onTap: () {
                    walletController.getWalletTransactionDetails(
                      transactionId: Get.arguments.toString(),
                    );
                  },
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                    .walletDetailsModel
                                    .value
                                    ?.data
                                    ?.transaction
                                    ?.amount
                                    .toString(),
                              ),
                              fontSize: 24.sp,
                            ),
                            4.verticalSpace,
                            CommonText(
                              string:
                                  "Transaction ID: ${walletController.walletDetailsModel.value?.data?.transaction?.transactionId ?? ""}",
                              fontSize: 12.sp,
                            ),
                            16.verticalSpace,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.w,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                color: getBgColor(
                                  walletController
                                          .walletDetailsModel
                                          .value
                                          ?.data
                                          ?.transaction
                                          ?.status ??
                                      "",
                                ),
                                border: Border.all(
                                  color: getTextColor(
                                    walletController
                                            .walletDetailsModel
                                            .value
                                            ?.data
                                            ?.transaction
                                            ?.status ??
                                        "",
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomImage(
                                    image: getIcon(
                                      walletController
                                              .walletDetailsModel
                                              .value
                                              ?.data
                                              ?.transaction
                                              ?.status ??
                                          "",
                                    ),
                                    color: getTextColor(
                                      walletController
                                              .walletDetailsModel
                                              .value
                                              ?.data
                                              ?.transaction
                                              ?.status ??
                                          "",
                                    ),
                                  ),
                                  4.horizontalSpace,
                                  CommonText(
                                    string:
                                        walletController
                                                .walletDetailsModel
                                                .value
                                                ?.data
                                                ?.transaction
                                                ?.timeline
                                                ?.first
                                                .isRefund ==
                                            1
                                        ? "Refund"
                                        : "${walletController.walletDetailsModel.value?.data?.transaction?.status ?? ""}",
                                    color: getTextColor(
                                      walletController
                                              .walletDetailsModel
                                              .value
                                              ?.data
                                              ?.transaction
                                              ?.status ??
                                          "",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      16.verticalSpace,
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.textFieldBorderColor,
                          ),
                          color: AppColors.whiteColor,
                        ),
                        child: Column(
                          children: [
                            if ((walletController
                                        .walletDetailsModel
                                        .value
                                        ?.data
                                        ?.transaction
                                        ?.status ??
                                    "") ==
                                "completed")
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  commonWidget(
                                    icon: IconAsset.paypal,
                                    title:
                                        "${walletController.walletDetailsModel.value?.data?.transaction?.timeline?.first.event}",
                                    step: 0,
                                    subTitle:
                                        "${walletController.walletDetailsModel.value?.data?.transaction?.timeline?.first.timestamp}",
                                  ),
                                  Divider(
                                    color: AppColors.textFieldBorderColor,
                                  ).paddingSymmetric(vertical: 8.h),
                                  commonWidget(
                                    icon: IconAsset.walletSearch,
                                    title:
                                        "${walletController.walletDetailsModel.value?.data?.transaction?.timeline?[1].event}",
                                    step: 0,
                                    subTitle:
                                        "${walletController.walletDetailsModel.value?.data?.transaction?.timeline?[1].timestamp}",
                                  ),
                                  Divider(
                                    color: AppColors.textFieldBorderColor,
                                  ).paddingSymmetric(vertical: 8.h),
                                  commonWidget(
                                    icon: IconAsset.walletCheck,
                                    title:
                                        "${walletController.walletDetailsModel.value?.data?.transaction?.timeline?.last.event}",
                                    step: 0,
                                    subTitle:
                                        "${walletController.walletDetailsModel.value?.data?.transaction?.timeline?.last.timestamp}",
                                  ),
                                ],
                              ),

                            if ((walletController
                                        .walletDetailsModel
                                        .value
                                        ?.data
                                        ?.transaction
                                        ?.status ??
                                    "") ==
                                "pending")
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  commonWidget(
                                    icon: IconAsset.paypal,
                                    title:
                                        "${walletController.walletDetailsModel.value?.data?.transaction?.timeline?.first.event}",
                                    step: 0,
                                    subTitle:
                                        "${walletController.walletDetailsModel.value?.data?.transaction?.timeline?.first.timestamp}",
                                  ),
                                  Divider(
                                    color: AppColors.textFieldBorderColor,
                                  ).paddingSymmetric(vertical: 8.h),
                                  commonWidget(
                                    icon: IconAsset.walletSearch,
                                    title:
                                        "${walletController.walletDetailsModel.value?.data?.transaction?.timeline?.last.event}",
                                    step: 0,
                                    subTitle:
                                        "${walletController.walletDetailsModel.value?.data?.transaction?.timeline?.last.statusText ?? ""}",
                                  ),
                                ],
                              ),
                            if ((walletController
                                        .walletDetailsModel
                                        .value
                                        ?.data
                                        ?.transaction
                                        ?.status ??
                                    "") ==
                                "failed")
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  commonWidget(
                                    icon: IconAsset.paypal,
                                    title:
                                        "${walletController.walletDetailsModel.value?.data?.transaction?.timeline?.first.event}",
                                    step: 0,
                                    subTitle:
                                        "${walletController.walletDetailsModel.value?.data?.transaction?.timeline?.first.timestamp}",
                                  ),
                                  Divider(
                                    color: AppColors.textFieldBorderColor,
                                  ).paddingSymmetric(vertical: 8.h),
                                  commonWidget(
                                    icon: IconAsset.walletSearch,
                                    title:
                                        "${walletController.walletDetailsModel.value?.data?.transaction?.timeline?.last.event}",
                                    step: 0,
                                    subTitle:
                                        "${walletController.walletDetailsModel.value?.data?.transaction?.timeline?.last.statusText ?? ""}",
                                    isFailed: true,
                                  ),
                                ],
                              ),

                            16.verticalSpace,
                            DottedWidget(),
                            8.verticalSpace,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if ((walletController
                                                .walletDetailsModel
                                                .value
                                                ?.data
                                                ?.transaction
                                                ?.tripId ??
                                            "")
                                        .isNotEmpty &&
                                    walletController
                                            .walletDetailsModel
                                            .value
                                            ?.data
                                            ?.transaction
                                            ?.tripId !=
                                        "-")
                                  CommonText(
                                    string:
                                        "Trip ID : ${walletController.walletDetailsModel.value?.data?.transaction?.tripId ?? ""}",
                                    fontSize: 12.sp,
                                  ),
                                Spacer(),
                                CommonText(
                                  string:
                                      "Date: ${walletController.walletDetailsModel.value?.data?.transaction?.date ?? ""} • ${walletController.walletDetailsModel.value?.data?.transaction?.time ?? ""}",
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      if ((walletController
                                  .walletDetailsModel
                                  .value
                                  ?.data
                                  ?.transaction
                                  ?.rejectReason ??
                              "")
                          .isNotEmpty)
                        Align(
                          alignment: Alignment.topLeft,
                          child: CommonText(
                            string:
                                '${AppString.reason.tr} : ${walletController.walletDetailsModel.value?.data?.transaction?.rejectReason ?? ""}',
                            softWrap: true,
                            color: AppColors.errorColor,
                          ),
                        ).paddingOnly(top: 6.h),
                    ],
                  ).paddingSymmetric(horizontal: 16.w, vertical: 16.w),
                ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        bottom: Utils().checkPlatForm,

        child: Obx(
          () => Skeletonizer(
            enabled: walletController.walletDetailsLoading.value,
            child: CustomButton(
              text:
                  walletController
                          .walletDetailsModel
                          .value
                          ?.data
                          ?.transaction
                          ?.status ==
                      "completed"
                  ? AppString.downloadReceipt.tr
                  : AppString.contactSupport.tr,
              onTap: walletController.walletDetailsLoading.value
                  ? null
                  : () {
                      if (walletController
                              .walletDetailsModel
                              .value
                              ?.data
                              ?.transaction
                              ?.status ==
                          "completed") {
                        Utils().downloadPdf(
                          walletController
                                  .walletDetailsModel
                                  .value
                                  ?.data
                                  ?.transaction
                                  ?.downloadLink ??
                              "",
                          '${walletController.walletDetailsModel.value?.data?.transaction?.transactionId}',
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
    );
  }

  Widget commonWidget({
    required int step,
    required String title,
    required String subTitle,
    required String icon,
    bool isFailed = false,
  }) {
    return Row(
      children: [
        Container(
          height: 40.h,
          width: 40.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: isFailed ? AppColors.errorBgColor : AppColors.transparent,
          ),
          alignment: Alignment.center,
          child: CustomImage(
            image: icon,
            color: isFailed ? AppColors.errorColor : AppColors.blackColor,
          ),
        ),
        8.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                string: title,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isFailed
                    ? AppColors.errorColor
                    : AppColors.titleTextColor,
                softWrap: true,
              ),
              4.verticalSpace,
              CommonText(
                string: subTitle,
                color: isFailed
                    ? AppColors.errorColor
                    : AppColors.textCaptionColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String getIcon(String value) {
    switch (value) {
      case "completed":
        return IconAsset.walletCheck;
      case "failed":
        return IconAsset.walletCancel;
      default:
        return IconAsset.walletSearch;
    }
  }

  Color getTextColor(String value) {
    switch (value) {
      case "completed":
        return AppColors.successColor;
      case "failed":
        return AppColors.errorColor;
      default:
        return AppColors.warningColor;
    }
  }

  Color getBgColor(String value) {
    switch (value) {
      case "completed":
        return AppColors.sucessContainer;
      case "failed":
        return AppColors.errorBgColor;
      default:
        return AppColors.warningBgColor;
    }
  }
}
