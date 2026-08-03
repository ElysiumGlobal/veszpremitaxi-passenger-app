import 'package:e_taxi/core/debug/passenger_flow_debug.dart';
import 'package:e_taxi/feature/home/controller/home_controller.dart';
import 'package:e_taxi/feature/wallet/controller/wallet_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/assets.dart';
import '../../../utils/log_utils.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custome_img.dart';
import '../../profile/controller/profile_controller.dart';

class PaymentSelectScreen extends StatefulWidget {
  const PaymentSelectScreen({super.key});

  @override
  State<PaymentSelectScreen> createState() => _PaymentSelectScreenState();
}

class _PaymentSelectScreenState extends State<PaymentSelectScreen> {
  var arg = {};

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      arg = Get.arguments;
      isPaymentSelect = arg['paymentSelection'] ?? false;
      amount = arg['amount'] ?? arg['finalAmount'] ?? '0.0';
      isCompletedRide = arg['completedRide'] == true;

      if (arg['method'] != null) {
        if (arg['isRideBook'] == null || arg['isRideBook'] == false) {
          changePaymentMethod = true;
        }
        int index = checkName.indexWhere(
          (element) => element == arg['method'].toString().toLowerCase(),
        );
        if (index != -1 && index < 3) {
          selectedIndex.value = index;
        }
      }
    }
  }

  bool changePaymentMethod = false;
  bool isCompletedRide = false;
  bool isPaymentSelect =
      false; // true then change selection & false then go for online payment

  dynamic amount = "0.0";

  RxInt selectedIndex = (-1).obs;

  List imageList = [
    IconAsset.wallet,
    // IconAsset.paytm,
    IconAsset.razorPay,
    IconAsset.stripe,
  ];

  List paymentName = [
    AppString.cash,
    // AppString.paytm,
    AppString.razorpay,
    AppString.stripe,
  ];

  List checkName = ["cash", "razorpay", "stripe", "wallet"];
  final homeController = Get.find<HomeController>();
  final profileController = Get.find<ProfileController>();
  final walletController = Get.find<WalletController>();

  RxBool selectWallet = false.obs;

  TextEditingController tipController = TextEditingController();

  RxInt selectedTip = (-1).obs;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isPaymentSelect || isCompletedRide,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop == false) {
          if (isPaymentSelect || isCompletedRide) {
            Get.back();
          } else {
            Navigation.popupUtil(Routes.dashboardScreen);
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.whiteGrey,
        appBar: CustomAppBar(
          centerTitle: false,
          title: isPaymentSelect
              ? AppString.selectPayment.tr
              : AppString.payment.tr,
          onBackTap: () {
            if (isPaymentSelect || isCompletedRide) {
              Get.back();
            } else {
              Navigation.popupUtil(Routes.dashboardScreen);
            }
          },
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText(
                      string: AppString.totalAmount.tr,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),

                    CommonText(
                      string: isPaymentSelect
                          ? Utils.formatCurrency(amount.toString())
                          : Utils.formatCurrency(
                              arg['finalAmount'] ??
                                  riderBookingModel
                                      .value
                                      ?.data
                                      ?.fare
                                      ?.totalAmount ??
                                  "0",
                            ),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
                20.verticalSpace,
                GestureDetector(
                  onTap: () {
                    selectWallet.value = true;
                    if (selectedIndex.value == 0) {
                      selectedIndex.value = -1;
                    }

                    if ((double.parse(
                          isPaymentSelect
                              ? amount
                              : "${arg['finalAmount'] ?? riderBookingModel.value?.data?.fare?.totalAmount ?? "0"}",
                        )) <=
                        double.parse(
                          walletController
                                  .walletModel
                                  .value
                                  ?.data
                                  ?.walletInfo
                                  ?.availableBalance
                                  .toString() ??
                              '0',
                        )) {
                      selectedIndex.value = -1;
                    }
                  },
                  child: Obx(
                    () => Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectWallet.value == true
                              ? AppColors.mainPrimaryColor
                              : AppColors.textFieldBorderColor,
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonText(
                                  string: AppString.wallet.tr,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.sp,
                                ),
                                CommonText(
                                  string:
                                      "${AppString.availableBalance.tr}: ${Utils.formatCurrency(walletController.walletModel.value?.data?.walletInfo?.availableBalance.toString())}",
                                  color:
                                      (double.parse(
                                            isPaymentSelect
                                                ? amount
                                                : arg['finalAmount'] ??
                                                      riderBookingModel
                                                          .value
                                                          ?.data
                                                          ?.fare
                                                          ?.totalAmount ??
                                                      "0",
                                          )) <=
                                          double.parse(
                                            walletController
                                                    .walletModel
                                                    .value
                                                    ?.data
                                                    ?.walletInfo
                                                    ?.availableBalance
                                                    .toString() ??
                                                '0',
                                          )
                                      ? AppColors.successColor
                                      : AppColors.errorColor,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 24.w,
                            width: 24.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.mainPrimaryColor,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Obx(
                              () => selectWallet.value == true
                                  ? Container(
                                      height: 16.w,
                                      width: 16.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.mainPrimaryColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.mainPrimaryColor,
                                        ),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),

                  child: CommonText(
                    string: AppString.paymentOnline.tr,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => 8.verticalSpace,
                  itemCount: _payment.length,
                  itemBuilder: (context, index) {
                    return (profileController.userModel.value?.availablePayment
                                ?.contains(checkName[index]) ??
                            false)
                        ? GestureDetector(
                            onTap: () {
                              selectedIndex.value = index;
                              if (index == 0) {
                                selectWallet.value = false;
                              }

                              if (selectWallet.value &&
                                  (double.parse(
                                        isPaymentSelect
                                            ? amount
                                            : "${arg['finalAmount'] ?? riderBookingModel.value?.data?.fare?.totalAmount ?? "0"}",
                                      )) <=
                                      double.parse(
                                        walletController
                                                .walletModel
                                                .value
                                                ?.data
                                                ?.walletInfo
                                                ?.availableBalance
                                                .toString() ??
                                            '0',
                                      )) {
                                selectWallet.value = false;
                              }
                            },
                            child: Obx(
                              () => Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  color: AppColors.whiteColor,
                                  border: Border.all(
                                    color: selectedIndex.value == index
                                        ? AppColors.mainPrimaryColor
                                        : AppColors.transparent,
                                  ),
                                ),

                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24.h,
                                      child: CustomImage(
                                        image: imageList[index],
                                        ht: 24.h,
                                        wt: 24.h,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    40.horizontalSpace,
                                    CommonText(
                                      string: paymentName[index],
                                      fontSize: 16.sp,
                                    ),
                                    Spacer(),
                                    Container(
                                      height: 24.w,
                                      width: 24.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.mainPrimaryColor,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Obx(() {
                                        return selectedIndex.value == index
                                            ? Container(
                                                height: 16.w,
                                                width: 16.w,
                                                decoration: BoxDecoration(
                                                  color: AppColors
                                                      .mainPrimaryColor,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppColors
                                                        .mainPrimaryColor,
                                                  ),
                                                ),
                                              )
                                            : SizedBox.shrink();
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SizedBox.shrink();
                  },
                ),
                16.verticalSpace,

                if (isPaymentSelect == false)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        string: AppString.tipYourDriver.tr,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      12.verticalSpace,
                      Wrap(
                        direction: Axis.horizontal,
                        spacing: 10.w,
                        runSpacing: 10.w,

                        children: [
                          ...List.generate(tipAmountName.length, (index) {
                            return Obx(
                              () => GestureDetector(
                                onTap: () {
                                  selectedTip.value = index;
                                  if (index != tipAmountName.length - 1) {
                                    tipController.text = tipAmount[index];
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: selectedTip.value == index
                                          ? AppColors.mainPrimaryColor
                                          : AppColors.textFieldBorderColor,
                                    ),
                                  ),
                                  child: CommonText(
                                    string: tipAmountName[index],
                                    color: selectedTip.value == index
                                        ? AppColors.mainPrimaryColor
                                        : AppColors.textPrimaryColor,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      Obx(
                        () => Column(
                          children: [
                            if (selectedTip.value == tipAmountName.length - 1)
                              CustomTextField(
                                controller: tipController,
                                hintText: "Tip Amount",
                                textinputformate: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                keyboardType: TextInputType.number,
                              ).paddingOnly(top: 8.h),

                            if (selectedTip.value != -1)
                              GestureDetector(
                                onTap: () {
                                  selectedTip.value = -1;
                                  tipController.clear();
                                },
                                child: Align(
                                  alignment: AlignmentGeometry.centerRight,
                                  child: CommonText(
                                    string: AppString.clearTip.tr,
                                    fontSize: 18.sp,
                                    color: AppColors.redColor,
                                  ),
                                ).paddingOnly(top: 6.h),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                // CustomTextField(controller: tipController,
                //
                // hintText: "Tip amount",),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          bottom: Utils().checkPlatForm,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: CustomButton(
              text: AppString.continueString.tr,
              onTap: () async {
                final String bookingId =
                    '${arg['bookingId'] ?? riderBookingModel.value?.data?.booking?.id ?? ''}'
                        .trim();
                final double finalAmount = double.tryParse(
                      '${arg['finalAmount'] ?? amount ?? resolveTotalAmount()}'
                          .replaceAll(',', ''),
                    ) ??
                    0;

                if (isCompletedRide) {
                  if (bookingId.isEmpty || bookingId == 'null') {
                    PassengerFlowDebug.send(
                      'completed_payment_submit_blocked',
                      data: <String, dynamic>{'reason': 'missing_booking_id'},
                    );
                    AppSnackBar.showErrorSnackBar(
                      message: 'A fuvar azonosítója hiányzik. Frissítsd az oldalt.',
                      isError: true,
                    );
                    return;
                  }
                  if (selectedIndex.value == -1 && !selectWallet.value) {
                    AppSnackBar.showErrorSnackBar(
                      message: AppString.selectPaymentMethod.tr,
                      isError: true,
                    );
                    return;
                  }

                  final String method = selectWallet.value
                      ? 'wallet'
                      : _payment[selectedIndex.value].toString();
                  PassengerFlowDebug.send(
                    'completed_payment_method_submitted',
                    bookingId: bookingId,
                    data: <String, dynamic>{
                      'method': method,
                      'amount': finalAmount,
                    },
                  );

                  if (method == 'cash') {
                    final bool saved = await homeController
                        .selectCashForCompletedRide(bookingId: bookingId);
                    if (saved && mounted) Get.back(result: 'cash');
                    return;
                  }

                  if (finalAmount <= 0) {
                    AppSnackBar.showErrorSnackBar(
                      message: 'A fizetendő összeg hibás. Frissítsd az oldalt.',
                      isError: true,
                    );
                    return;
                  }
                  await homeController.paymentInt(
                    bookingId: bookingId,
                    amount: finalAmount,
                    method: method,
                    isSplit: false,
                    tip: tipController.text.trim(),
                  );
                  return;
                }

                if (isPaymentSelect) {
                  if (changePaymentMethod) {
                    String paymentMode = "wallet";
                    if (selectedIndex.value != -1) {
                      paymentMode = _payment[selectedIndex.value].toString();
                    }
                    if (paymentMode == arg['method']) {
                      Get.back();
                    } else {
                      if (selectedIndex.value == -1) {
                        double wallet = double.parse(
                          walletController
                                  .walletModel
                                  .value
                                  ?.data
                                  ?.walletInfo
                                  ?.availableBalance
                                  .toString() ??
                              "0.0",
                        );
                        double tripAmount = double.parse(amount);

                        if (tripAmount > wallet) {
                          AppSnackBar.showErrorSnackBar(
                            message: AppString.notEnoughBalance.tr,
                            isError: true,
                          );
                          return;
                        }
                      }
                      Map result = await homeController.updatePaymentMode(
                        paymentMode: paymentMode.toLowerCase(),
                        bookingId: arg['bookingId'],
                      );
                      LogUtils.printAction("RESULT ++$result");
                      if (result.isNotEmpty) {
                        Get.back(result: paymentMode);
                        AppSnackBar.showErrorSnackBar(
                          message: result['message'],
                        );
                      }
                    }
                  } else {
                    String paymentMode = "wallet";
                    if (selectedIndex.value != -1) {
                      paymentMode = _payment[selectedIndex.value].toString();
                    }
                    Get.back(result: paymentMode);
                  }
                } else if (selectedIndex.value == -1) {
                  if (selectWallet.value == false) {
                    AppSnackBar.showErrorSnackBar(
                      message: AppString.selectPaymentMethod.tr,
                      isError: true,
                    );
                    return;
                  }

                  if (selectedTip.value != -1 &&
                      tipController.text.trim().isEmpty) {
                    AppSnackBar.showErrorSnackBar(
                      message: AppString.pleaseAddTipAmount.tr,
                      isError: true,
                    );

                    return;
                  }

                  double wallet = double.parse(
                    walletController
                            .walletModel
                            .value
                            ?.data
                            ?.walletInfo
                            ?.availableBalance
                            .toString() ??
                        "0.0",
                  );
                  double tripAmount =
                      double.parse(
                        arg['finalAmount'] ??
                            riderBookingModel.value?.data?.fare?.totalAmount ??
                            "0.0",
                      ) +
                      double.parse(
                        tipController.text.trim().isEmpty
                            ? "0"
                            : tipController.text.trim(),
                      );

                  if (tripAmount > wallet) {
                    AppSnackBar.showErrorSnackBar(
                      message: AppString.notEnoughBalance.tr,
                      isError: true,
                    );
                    return;
                  }
                  await homeController.paymentInt(
                    bookingId: riderBookingModel.value?.data?.booking?.id ?? "",
                    amount: double.parse(
                      arg['finalAmount'] ??
                          riderBookingModel.value?.data?.fare?.totalAmount ??
                          "0.0",
                    ),
                    method: "wallet",
                    isSplit: false,
                    tip: tipController.text.trim(),
                  );
                } else {
                  if (selectedTip.value != -1 &&
                      tipController.text.trim().isEmpty) {
                    AppSnackBar.showErrorSnackBar(
                      message: AppString.pleaseAddTipAmount.tr,
                      isError: true,
                    );

                    return;
                  }

                  await homeController.paymentInt(
                    bookingId: riderBookingModel.value?.data?.booking?.id ?? "",
                    amount: double.parse(
                      arg['finalAmount'] ??
                          riderBookingModel.value?.data?.fare?.totalAmount ??
                          "0",
                    ),
                    method: _payment[selectedIndex.value],
                    isSplit: selectWallet.value,
                    tip: tipController.text.trim(),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  List tipAmountName = [
    Utils.formatCurrency("10"),
    Utils.formatCurrency("20"),
    Utils.formatCurrency("30"),
    "Custom",
  ];

  List tipAmount = ["10", "20", "30"];

  List _payment = [
    "cash",
    // "paytm",
    "razorpay",
    "stripe",
  ];
}
