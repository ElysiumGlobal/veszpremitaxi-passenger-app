import 'package:e_taxi/feature/wallet/controller/wallet_controller.dart';
import 'package:e_taxi/utils/validation_utils.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_string.dart';
import '../../../utils/utils.dart';
import '../../../widgets/appbar.dart';

class BankAccountAddScreen extends StatefulWidget {
  const BankAccountAddScreen({super.key});

  @override
  State<BankAccountAddScreen> createState() => _BankAccountAddScreenState();
}

class _BankAccountAddScreenState extends State<BankAccountAddScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        currentPage.value = _tabController.index == 0 ? 0 : 1;
      });

    if (walletController.accountDetails.value != null) {
      nameController.text =
          walletController.accountDetails.value?.accountHolderName ?? "";
      accountController.text =
          walletController.accountDetails.value?.accountNumber ?? "";
      ifscController.text =
          walletController.accountDetails.value?.ifscCode ?? "";
      bankController.text =
          walletController.accountDetails.value?.bankName ?? "";
      upiController.text = walletController.accountDetails.value?.upiId ?? "";
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController accountController = TextEditingController();
  TextEditingController ifscController = TextEditingController();
  TextEditingController bankController = TextEditingController();

  TextEditingController upiController = TextEditingController();

  RxInt currentPage = 0.obs;

  final walletController = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBarSize: 120.h,
        title: AppString.addAccount.tr,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 56.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              border: Border(
                top: BorderSide(color: AppColors.textFieldBorderColor),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: AppColors.mainPrimaryColor,
              labelColor: AppColors.mainPrimaryColor,
              unselectedLabelColor: AppColors.textCaptionColor,
              dividerColor: AppColors.transparent,
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: AppColors.textCaptionColor,
              ),
              labelStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(text: AppString.bankAccount.tr),
                Tab(text: AppString.upiId.tr),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: Utils().checkPlatForm,

        child: TabBarView(
          controller: _tabController,
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${walletController.accountDetails.value?.accountHolderName}",
                  ),

                  CommonText(
                    string:
                        "Your earnings will be automatically transferred to this bank account. Make sure it's active and correct to receive payouts without delays",
                    softWrap: true,
                    color: AppColors.bodyText,
                  ),

                  16.verticalSpace,
                  CustomTextField(
                    controller: nameController,
                    title: AppString.nameOfHolder.tr,
                    hintText: "Michal Clark",
                  ),
                  20.verticalSpace,
                  CustomTextField(
                    controller: accountController,
                    title: AppString.accountNumber.tr,
                    hintText: "99887766550000",

                    keyboardType: TextInputType.number,
                    textinputformate: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                    ],
                  ),
                  20.verticalSpace,
                  CustomTextField(
                    controller: ifscController,
                    title: AppString.ifscCode.tr,
                    hintText: "BANKXDEMO",
                  ),
                  20.verticalSpace,
                  CustomTextField(
                    controller: bankController,
                    title: AppString.bankName.tr,
                    hintText: "Demo Bank",
                  ),
                ],
              ).paddingAll(16.w),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  CommonText(
                    string:
                        "Your earnings will be sent to this UPI ID. Amount Will be Transferred to the UPI Linked Account",
                    softWrap: true,
                    color: AppColors.bodyText,
                  ),
                  16.verticalSpace,

                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: AppColors.whiteColor,
                      border: Border.all(color: AppColors.textFieldBorderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          string: AppString.addUpiAccount.tr,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        12.verticalSpace,
                        CustomTextField(
                          controller: upiController,
                          title: AppString.enterUpiId.tr,
                          hintText: "9988776655@Demo",
                        ),
                        12.verticalSpace,
                        CommonText(
                          string:
                              "It should follow the format: username@provider — like user123@upi or ankit@ybl.",
                          color: AppColors.textCaptionColor,
                          softWrap: true,
                          fontSize: 12.sp,
                        ),
                      ],
                    ),
                  ),
                ],
              ).paddingSymmetric(horizontal: 16.w),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Obx(
          () => CustomButton(
            text: currentPage.value == 0
                ? AppString.verifyBankAccount.tr
                : AppString.verifyUpi.tr,
            onTap: () async {
              if (currentPage.value == 0) {
                if (nameController.text.trim().textDataIsNotValid(
                      AppString.pleaseEnterValidAccountName.tr,
                    ) ||
                    accountController.text.trim().textDataIsNotValid(
                      AppString.pleaseEnterValidAccountNumber.tr,
                    ) ||
                    ifscController.text.trim().textDataIsNotValid(
                      AppString.pleaseEnterValidIfscCode.tr,
                    ) ||
                    bankController.text.trim().textDataIsNotValid(
                      AppString.pleaseEnterValidBankName.tr,
                    )) {
                  return;
                }

                final res = await walletController.addBankDetails(
                  name: nameController.text.trim(),
                  accNumber: accountController.text.trim(),
                  ifscCode: ifscController.text.trim(),
                  bank: bankController.text.trim(),
                );

                if (res.isNotEmpty) {
                  Get.back();
                  AppSnackBar.showErrorSnackBar(message: res['message']);
                }
              } else {
                if (upiController.text.trim().textDataIsNotValid(
                  AppString.pleaseEnterValidUpiId.tr,
                )) {
                  return;
                }

                final res = await walletController.addUpiId(
                  upiId: upiController.text.trim(),
                );

                if (res.isNotEmpty) {
                  Get.back();
                  AppSnackBar.showErrorSnackBar(message: res['message']);
                }
              }
            },
          ).paddingOnly(left: 16.w, right: 16.w, bottom: 16.w),
        ),
      ),
    );
  }
}
