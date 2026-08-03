import 'package:e_taxi/feature/wallet/controller/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_string.dart';
import '../../../utils/assets.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/common_widget.dart';
import '../../../widgets/custom_textfeild.dart';
import '../../../widgets/custome_img.dart';
import '../../../widgets/no_data_widget.dart';
import '../../trip_activity/widget/checkBox.dart';
import '../widget/tansaction_widget.dart';

class EarningTransactionScreen extends StatefulWidget {
  const EarningTransactionScreen({super.key});

  @override
  State<EarningTransactionScreen> createState() =>
      _EarningTransactionScreenState();
}

class _EarningTransactionScreenState extends State<EarningTransactionScreen> {
  final walletController = Get.find<WalletController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    walletController.getEarningTransactionList();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          walletController.earningPaginationLoading.value == false &&
          walletController.isMoreEarningAvailable) {
        walletController.earningPaginationLoading(true);
        walletController.getEarningTransactionList(isFirstTime: false);
      }
    });
  }

  ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    // TODO: implement dispose
    walletController.clearEarningFilter();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppString.earning.tr, centerTitle: false),
      body: SafeArea(
        bottom: Utils().checkPlatForm,

        child: Obx(
          () => Column(
            children: [
              Skeletonizer(
                enabled: walletController.earingTransactionLoading.value,
                child: Padding(
                  padding: EdgeInsets.only(left: 16.w, top: 16.w, bottom: 16.w),
                  child: SizedBox(
                    height: 40.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filterList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            filterTap(index);
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 16.w),
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.textFieldBorderColor,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                              color: AppColors.whiteColor,
                            ),
                            child: Row(
                              children: [
                                CommonText(string: filterList[index].tr),
                                4.horizontalSpace,
                                CustomImage(
                                  image: IconAsset.arrowDown,
                                  ht: 16.h,
                                  wt: 16.h,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              Expanded(
                child: walletController.earingTransactionLoading.value
                    ? ListView.separated(
                        itemBuilder: (context, index) {
                          return Container(
                            height: 100,
                            width: double.infinity,
                            color: AppColors.whiteColor,
                          );
                        },
                        separatorBuilder: (context, index) => 16.verticalSpace,
                        itemCount: 4,
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await walletController.getEarningTransactionList();
                        },
                        child: walletController.earningTransactionList.isEmpty
                            ? NoDataWidget(
                                icon: ImagesAsset.noData,
                                title: AppString.noDataAvailable.tr,
                                subTitle: AppString.weNotFindAnything.tr,
                                onTap: () {
                                  walletController.getEarningTransactionList();
                                },
                              )
                            : ListView.separated(
                                physics: AlwaysScrollableScrollPhysics(),
                                separatorBuilder: (context, index) =>
                                    16.verticalSpace,
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                itemBuilder: (context, index) {
                                  final data = walletController
                                      .earningTransactionList[index];
                                  return Container(
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
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(12.w),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                            color: AppColors.whiteGrey,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              CommonText(
                                                string: data.date ?? "",
                                                fontWeight: FontWeight.w600,
                                              ),
                                              CommonText(
                                                string:
                                                    "${data.dailyTotalEarnings?.toStringAsFixed(2) ?? ""}",
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ],
                                          ),
                                        ),
                                        12.verticalSpace,
                                        ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          separatorBuilder: (context, index) =>
                                              16.verticalSpace,
                                          itemCount:
                                              (data.transactions ?? []).length,
                                          itemBuilder: (context, subIndex) {
                                            final transaction =
                                                data.transactions?[subIndex];
                                            return TransactionWidget1(
                                              data: transaction,
                                              onTap: () {
                                                if ((transaction?.bookingCode ??
                                                            "")
                                                        .isNotEmpty ||
                                                    ("${transaction?.transactionId ?? ""}")
                                                        .isNotEmpty) {
                                                  Navigation.pushNamed(
                                                    Routes.earningDetailsScreen,
                                                    arg: EarningDetailsDataModel(
                                                      bookingCode:
                                                          transaction
                                                              ?.bookingCode ??
                                                          "",
                                                      transactionId:
                                                          "${transaction?.transactionId ?? ""}",
                                                      type:
                                                          (transaction?.bookingCode ??
                                                                  "")
                                                              .isNotEmpty
                                                          ? 1
                                                          : (transaction?.isApprove ??
                                                                    0) ==
                                                                0
                                                          ? 2
                                                          : 3,
                                                    ),
                                                  );
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                itemCount: walletController
                                    .earningTransactionList
                                    .length,
                              ),
                      ),
              ),
              16.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  List<String> filterList = [
    AppString.paymentSource,
    AppString.earningType,
    AppString.amount,
  ];

  void filterTap(int index) {
    if (index == 0) {
      List<String> list = [
        AppString.walletEarning,
        AppString.cashEarning,
        AppString.incentiveReward,
        AppString.deduction,
      ];

      CustomWidget.commonBottomSheetWidget(
        title: AppString.paymentSource.tr,
        onTap: () {
          Get.back();
          walletController.earningFilterOn.value = true;
          walletController.getEarningTransactionList();
        },
        child: [
          ...List.generate(list.length, (index) {
            return Obx(
              () => CheckboxWidget(
                onTap: (bool value) {
                  walletController.earningPaymentF.value = index;
                },
                title: list[index].tr,
                select: walletController.earningPaymentF.value == index,
              ).paddingOnly(bottom: 21.h),
            );
          }).toList(),
        ],
      );
    } else if (index == 1) {
      List<String> list = [
        AppString.ride,
        AppString.riderTrip,
        AppString.rafralBonus,
        AppString.pickHourBonus,
        AppString.cancelationPanlty,
        AppString.serviceFee,
      ];

      CustomWidget.commonBottomSheetWidget(
        title: AppString.paymentSource.tr,
        onTap: () {
          Get.back();
          walletController.earningFilterOn.value = true;
          walletController.getEarningTransactionList();
        },
        child: [
          ...List.generate(list.length, (index) {
            return Obx(
              () => CheckboxWidget(
                onTap: (bool value) {
                  walletController.earningTypeF.value = index;
                },
                title: list[index].tr,
                select: walletController.earningTypeF.value == index,
              ).paddingOnly(bottom: 21.h),
            );
          }).toList(),
        ],
      );
    } else if (index == 2) {
      List amaountList = [
        ">${Utils.formatCurrency("25")}",
        "${Utils.formatCurrency("25")} - ${Utils.formatCurrency("50")}",
        "${Utils.formatCurrency("50")} - ${Utils.formatCurrency("100")}",
        ">${Utils.formatCurrency("100")}",
        AppString.customRange.tr,
      ];

      TextEditingController minController = TextEditingController(
        text: walletController.earningMinAmount,
      );
      TextEditingController maxController = TextEditingController(
        text: walletController.earningMaxAmount,
      );
      CustomWidget.commonBottomSheetWidget(
        title: AppString.amount.tr,
        onTap: () {
          walletController.earningFilterOn.value = true;

          if (walletController.earningAmountF.value == 4) {
            var min = num.parse(
              walletController.earningMinAmount.isEmpty
                  ? "0"
                  : walletController.earningMinAmount,
            );
            var max = num.parse(
              walletController.earningMaxAmount.isEmpty
                  ? "0"
                  : walletController.earningMaxAmount,
            );

            if (min >= max) {
              AppSnackBar.showErrorSnackBar(
                message: "Adj meg érvényes maximális összeget.",
                isError: true,
              );
            } else {
              Get.back();
              walletController.getEarningTransactionList();
            }
          } else {
            Get.back();
            walletController.getEarningTransactionList();
          }
        },
        child: [
          ...List.generate(amaountList.length, (index) {
            return Obx(
              () => CheckboxWidget(
                onTap: (va) {
                  walletController.earningAmountF.value = index;
                  if (walletController.earningAmountF.value != 4) {
                    walletController.earningMinAmount = '';
                    walletController.earningMaxAmount = '';
                  }
                },
                title: amaountList[index],
                select: walletController.earningAmountF.value == index,
              ).paddingOnly(bottom: 21.h),
            );
          }).toList(),
          Obx(
            () => walletController.earningAmountF.value == 4
                ? Row(
                    children: [
                      16.horizontalSpace,
                      Expanded(
                        child: CustomTextField(
                          hintText: AppString.enterMinAmount.tr,
                          controller: minController,

                          textinputformate: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (v) {
                            walletController.earningMinAmount = v;
                          },
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                      ),

                      16.horizontalSpace,

                      Expanded(
                        child: CustomTextField(
                          hintText: AppString.enterMaxAmount.tr,
                          controller: maxController,

                          textinputformate: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (v) {
                            walletController.earningMaxAmount = v;
                          },
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                      16.horizontalSpace,
                    ],
                  )
                : SizedBox.shrink(),
          ),
        ],
      );
    }
  }
}

class EarningDetailsDataModel {
  String? bookingCode;
  String? transactionId;
  int? type;

  EarningDetailsDataModel({this.bookingCode, this.transactionId, this.type});
}
