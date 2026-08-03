import 'package:e_taxi/feature/wallet/controller/wallet_controller.dart';
import 'package:e_taxi/feature/wallet/widget/tansaction_widget.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
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
import '../../../widgets/appbar.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/common_widget.dart';
import '../../../widgets/custom_textfeild.dart';
import '../../../widgets/custome_img.dart';
import '../../../widgets/no_data_widget.dart';
import '../../trip_activity/widget/checkBox.dart';

class WalletTransactionScreen extends StatefulWidget {
  const WalletTransactionScreen({super.key});

  @override
  State<WalletTransactionScreen> createState() =>
      _WalletTransactionScreenState();
}

class _WalletTransactionScreenState extends State<WalletTransactionScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    walletController.getWalletTransactionList();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    walletController.clearWalletTransaction();
    super.dispose();
  }

  final walletController = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppString.walletTransaction.tr,
        centerTitle: false,
      ),
      body: SafeArea(
        bottom: Utils().checkPlatForm,

        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeletonizer(
                enabled: walletController.walletTransactionLoading.value,
                child: Padding(
                  padding: EdgeInsets.only(left: 16.w, top: 16.w, bottom: 16.w),
                  child: SizedBox(
                    height: 40.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: walletController.walletTransactionLoading.value
                              ? null
                              : () {
                                  filteTap(index);
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
                child: walletController.walletTransactionLoading.value
                    ? Container(
                        padding: EdgeInsets.all(16.w),
                        margin: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: ListView.separated(
                          itemBuilder: (context, index) {
                            return Skeletonizer(
                              child: Container(
                                height: 70.h,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.whiteGrey,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              16.verticalSpace,
                          itemCount: 3,
                        ),
                      )
                    : (walletController
                                  .walletTransactionModel
                                  .value
                                  ?.data
                                  ?.transactions ??
                              [])
                          .isEmpty
                    ? NoDataWidgetss(
                        onTap: () async {
                          await walletController.clearWalletTransaction();
                          walletController.getWalletTransactionList();
                        },
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          walletController.clearWalletTransaction();
                          await walletController.getWalletTransactionList();
                        },
                        child: ListView.separated(
                          physics: AlwaysScrollableScrollPhysics(),
                          separatorBuilder: (context, index) =>
                              16.verticalSpace,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemBuilder: (context, index) {
                            final data = walletController
                                .walletTransactionModel
                                .value
                                ?.data
                                ?.transactions?[index];
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
                                      borderRadius: BorderRadius.circular(12.r),
                                      color: AppColors.whiteGrey,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CommonText(
                                          string: data?.date ?? "",
                                          fontWeight: FontWeight.w600,
                                        ),
                                        CommonText(
                                          string: "${data?.dailyTotal ?? ""}",
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ],
                                    ),
                                  ),
                                  12.verticalSpace,
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    separatorBuilder: (context, index) =>
                                        16.verticalSpace,
                                    itemCount:
                                        (data?.transactions ?? []).length,
                                    itemBuilder: (context, subIndex) {
                                      final transction =
                                          data?.transactions?[subIndex];
                                      return TransactionWidget2(
                                        data: transction,
                                        onTap: () {
                                          Navigation.pushNamed(
                                            Routes.walletDetailsScreen,
                                            arg: transction?.id,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          itemCount:
                              (walletController
                                          .walletTransactionModel
                                          .value
                                          ?.data
                                          ?.transactions ??
                                      [])
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
    AppString.date,
    AppString.transactionType,
    AppString.amount,
    AppString.status,
  ];

  void filteTap(int index) {
    if (index == 0) {
      List list = [
        AppString.thisMonth,
        AppString.last30,
        AppString.last90,
        AppString.chooseDate,
      ];

      CustomWidget.commonBottomSheetWidget(
        title: AppString.date.tr,
        onTap: () {
          Get.back();

          walletController.walletTransactionFiterOn.value = true;

          walletController.getWalletTransactionList();
        },
        child: [
          ...List.generate(list.length, (index) {
            return Obx(
              () => CheckboxWidget(
                onTap: (bool value) {
                  if (walletController.walletDateF.value == index) {
                    walletController.walletDateF.value = -1;
                  } else {
                    walletController.walletDateF.value = index;
                  }
                },
                title: list[index],
                select: walletController.walletDateF.value == index,
              ).paddingOnly(bottom: 21.h),
            );
          }).toList(),
          Obx(
            () => walletController.walletDateF.value == 3
                ? Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            DateTime? selectedDate = await showDatePicker(
                              context: context,
                              firstDate: DateTime.now().subtract(
                                Duration(days: 365 * 5),
                              ),
                              lastDate: DateTime.now(),
                            );
                            if (selectedDate != null) {
                              walletController.walletEndDateF.value = "";
                              walletController.walletStartDateF.value = Utils()
                                  .serverDesDate(selectedDate);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.textFieldBorderColor,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Obx(
                                  () => CommonText(
                                    string:
                                        walletController
                                            .walletStartDateF
                                            .value
                                            .isNotEmpty
                                        ? walletController
                                              .walletStartDateF
                                              .value
                                        : AppString.from.tr,
                                  ),
                                ),
                                CustomImage(
                                  image: IconAsset.calender,
                                  ht: 16.h,
                                  wt: 16.h,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      12.horizontalSpace,
                      Expanded(
                        child: Obx(
                          () => IgnorePointer(
                            ignoring:
                                walletController.walletStartDateF.value.isEmpty,
                            child: GestureDetector(
                              onTap: () async {
                                final selectedDate = await showDatePicker(
                                  context: context,
                                  firstDate:
                                      Utils().calenderDate(
                                        walletController.walletStartDateF.value,
                                      ) ??
                                      DateTime.now(),
                                  lastDate: DateTime.now(),
                                );
                                if (selectedDate != null) {
                                  walletController.walletEndDateF.value =
                                      Utils().serverDesDate(selectedDate);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.textFieldBorderColor,
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Obx(
                                      () => CommonText(
                                        string:
                                            walletController
                                                .walletEndDateF
                                                .value
                                                .isNotEmpty
                                            ? walletController
                                                  .walletEndDateF
                                                  .value
                                            : AppString.to.tr,
                                      ),
                                    ),
                                    CustomImage(
                                      image: IconAsset.calender,
                                      ht: 16.h,
                                      wt: 16.h,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
          ),
        ],
      );
    } else if (index == 1) {
      List<String> list = [
        AppString.credit,
        AppString.debit,
        AppString.referralBonus,
        AppString.driverCommission,
        AppString.promoCredit,
        AppString.adjustment,
      ];
      CustomWidget.commonBottomSheetWidget(
        title: AppString.paymentSource.tr,
        onTap: () {
          Get.back();
          walletController.walletTransactionFiterOn.value = true;
          walletController.getWalletTransactionList();
        },
        child: [
          ...List.generate(list.length, (index) {
            return Obx(
              () => CheckboxWidget(
                onTap: (bool value) {
                  if (walletController.walletTypeF.value == index) {
                    walletController.walletTypeF.value = -1;
                  } else {
                    walletController.walletTypeF.value = index;
                  }
                },
                title: list[index].tr,
                select: walletController.walletTypeF.value == index,
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
        text: walletController.walletMinAmount,
      );
      TextEditingController maxController = TextEditingController(
        text: walletController.walletMaxAmount,
      );
      CustomWidget.commonBottomSheetWidget(
        title: AppString.amount.tr,
        onTap: () {
          walletController.walletTransactionFiterOn.value = true;

          if (walletController.walletAmountF.value == 4) {
            var min = num.parse(
              walletController.walletMinAmount.isEmpty
                  ? "0"
                  : walletController.walletMinAmount,
            );
            var max = num.parse(
              walletController.walletMaxAmount.isEmpty
                  ? "0"
                  : walletController.walletMaxAmount,
            );

            if (min >= max) {
              AppSnackBar.showErrorSnackBar(
                message: "Adj meg érvényes maximális összeget.",
                isError: true,
              );
            } else {
              Get.back();
              walletController.getWalletTransactionList();
            }
          } else {
            Get.back();

            walletController.getWalletTransactionList();
          }
        },
        child: [
          ...List.generate(amaountList.length, (index) {
            return Obx(
              () => CheckboxWidget(
                onTap: (va) {
                  if (walletController.walletAmountF.value == index) {
                    walletController.walletAmountF.value = -1;
                  } else {
                    walletController.walletAmountF.value = index;
                    if (walletController.walletAmountF.value != 4) {
                      walletController.walletMinAmount = "";
                      walletController.walletMaxAmount = "";
                    }
                  }
                },
                title: amaountList[index],
                select: walletController.walletAmountF.value == index,
              ).paddingOnly(bottom: 21.h),
            );
          }).toList(),
          Obx(
            () => walletController.walletAmountF.value == 4
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
                            walletController.walletMinAmount = v;
                          },
                          keyboardType: TextInputType.number,
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
                            walletController.walletMaxAmount = v;
                          },
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      16.horizontalSpace,
                    ],
                  )
                : SizedBox.shrink(),
          ),
        ],
      );
    } else if (index == 3) {
      List<String> list = [
        AppString.completed,
        AppString.pending,
        AppString.failed,
      ];

      CustomWidget.commonBottomSheetWidget(
        title: AppString.paymentSource.tr,
        onTap: () {
          Get.back();
          walletController.walletTransactionFiterOn.value = true;
          walletController.getWalletTransactionList();
        },
        child: [
          ...List.generate(list.length, (index) {
            return Obx(
              () => CheckboxWidget(
                onTap: (bool value) {
                  if (walletController.walletStatusF.value == index) {
                    walletController.walletStatusF.value = -1;
                  } else {
                    walletController.walletStatusF.value = index;
                  }
                },
                title: list[index].tr,
                select: walletController.walletStatusF.value == index,
              ).paddingOnly(bottom: 21.h),
            );
          }).toList(),
        ],
      );
    }
  }
}
