import 'package:e_taxi/feature/wallet/controller/wallet_controller.dart';
import 'package:e_taxi/core/localization/vtaxi_localization_service.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:e_taxi/utils/navigation_utils/navigation.dart';
import 'package:e_taxi/utils/navigation_utils/routes.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/no_data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
              ? _loadingSkeleton()
              : Column(
                  children: [
                    _balanceCard(),
                    12.verticalSpace,
                    _topupCard(),
                    12.verticalSpace,
                    _bankCardManagementCard(),
                    16.verticalSpace,
                    Expanded(child: _transactionCard()),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _loadingSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 120.h,
            width: double.infinity,
            color: AppColors.whiteColor,
          ),
          12.verticalSpace,
          Container(
            height: 72.h,
            width: double.infinity,
            color: AppColors.whiteColor,
          ),
          12.verticalSpace,
          Container(
            height: 76.h,
            width: double.infinity,
            color: AppColors.whiteColor,
          ),
          16.verticalSpace,
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppColors.whiteColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: AppColors.brandNavy,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            string: VTaxiLocalizationService.text('vtaxi.wallet.available_balance', 'Elérhető egyenleg'),
            color: AppColors.whiteColor.withValues(alpha: .78),
            fontSize: 14.sp,
          ),
          6.verticalSpace,
          CommonText(
            string: Utils.formatCurrency(
              '${walletController.walletModel.value?.data?.walletInfo?.availableBalance ?? '0'}',
            ),
            color: AppColors.whiteColor,
            fontSize: 30.sp,
            fontWeight: FontWeight.w700,
          ),
          6.verticalSpace,
          CommonText(
            string: VTaxiLocalizationService.text('vtaxi.wallet.full_rides_only', 'Ebből az összegből teljes fuvarokat fizethetsz.'),
            color: AppColors.whiteColor.withValues(alpha: .72),
            fontSize: 12.sp,
            softWrap: true,
          ),
        ],
      ),
    );
  }

  Widget _topupCard() {
    if (walletController.stripeConfigLoading.value) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.textFieldBorderColor),
          color: AppColors.whiteColor,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20.w,
              height: 20.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            12.horizontalSpace,
            Expanded(
              child: CommonText(
                string: VTaxiLocalizationService.text('vtaxi.wallet.card_topup_loading', 'Bankkártyás feltöltés betöltése…'),
                softWrap: true,
              ),
            ),
          ],
        ),
      );
    }

    if (!walletController.stripeTopupEnabled.value) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.textFieldBorderColor),
        color: AppColors.whiteColor,
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.add_card_rounded,
              color: AppColors.brandNavy,
              size: 24.sp,
            ),
          ),
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  string: VTaxiLocalizationService.text('vtaxi.wallet.topup_balance', 'Egyenleg feltöltése'),
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
                3.verticalSpace,
                CommonText(
                  string: VTaxiLocalizationService.text('vtaxi.wallet.card_or_google_pay', 'Bankkártyával vagy Google Pay-jel'),
                  color: AppColors.textCaptionColor,
                  fontSize: 12.sp,
                ),
              ],
            ),
          ),
          8.horizontalSpace,
          SizedBox(
            width: 108.w,
            child: CustomButton(
              height: 44.h,
              text: VTaxiLocalizationService.text('vtaxi.wallet.topup', 'Feltöltés'),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              onTap: _openTopupSheet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bankCardManagementCard() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigation.pushNamed(Routes.bankCardScreen);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.textFieldBorderColor),
          color: AppColors.whiteColor,
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.credit_card_rounded,
                color: AppColors.brandNavy,
                size: 24.sp,
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    string: AppString.bankCard.tr,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                  3.verticalSpace,
                  CommonText(
                    string: AppString.bankCardIntro.tr,
                    color: AppColors.textCaptionColor,
                    fontSize: 12.sp,
                    softWrap: true,
                  ),
                ],
              ),
            ),
            8.horizontalSpace,
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textCaptionColor,
              size: 26.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _transactionCard() {
    final transactionGroups =
        walletController.walletModel.value?.data?.transactions?.data ?? [];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.textFieldBorderColor),
        color: AppColors.whiteColor,
      ),
      child: transactionGroups.isEmpty
          ? RefreshIndicator(
              onRefresh: () async {
                await walletController.getWalletData();
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Spacer(),
                            NoDataWidget(
                              icon: ImagesAsset.noData,
                              title: AppString.noDataAvailable.tr,
                              subTitle: AppString.weNotFindAnything.tr,
                              onTap: () {},
                            ),
                            const Spacer(),
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
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: transactionGroups.length,
                itemBuilder: (context, index) {
                  final model = transactionGroups[index];
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.textFieldBorderColor,
                          ),
                          color: AppColors.whiteGrey,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: CommonText(
                                string: model.month ?? '',
                                fontWeight: FontWeight.w500,
                                fontSize: 14.sp,
                              ),
                            ),
                            CommonText(
                              string: Utils.formatCurrency(model.totalAmount),
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                            ),
                          ],
                        ),
                      ),
                      12.verticalSpace,
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, subIndex) {
                          final data = model.transactions?[subIndex];
                          return Row(
                            key: ValueKey('$index $subIndex'),
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CommonText(
                                      string: data?.description ?? '',
                                      fontSize: 14.sp,
                                      softWrap: true,
                                    ),
                                    4.verticalSpace,
                                    CommonText(
                                      string: '${data?.date ?? ''}, ${data?.time ?? ''}',
                                      fontSize: 14.sp,
                                      color: AppColors.textCaptionColor,
                                    ),
                                  ],
                                ),
                              ),
                              8.horizontalSpace,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  CommonText(
                                    string: Utils.formatCurrency(data?.amount),
                                    fontSize: 16.sp,
                                    color: ((data?.isRefunded ?? 0) == 1 ||
                                            (data?.referralBonus ?? 0) == 1)
                                        ? AppColors.successColor
                                        : AppColors.titleTextColor,
                                  ),
                                  if ((data?.status ?? '') == 'failed')
                                    CommonText(
                                      string: 'Sikertelen',
                                      fontSize: 12.sp,
                                      color: AppColors.errorColor,
                                    ),
                                ],
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (context, index) => 12.verticalSpace,
                        itemCount: (model.transactions ?? []).length,
                      ),
                      16.verticalSpace,
                    ],
                  );
                },
              ),
            ),
    );
  }

  Future<void> _openTopupSheet() async {
    await walletController.loadStripeTopupConfig(force: true);
    if (!mounted || !walletController.stripeTopupEnabled.value) return;

    final amounts = walletController.allowedTopupAmounts.toList();
    if (amounts.isEmpty) return;

    var selectedAmount = amounts.first;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
                child: Obx(
                  () => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                      18.verticalSpace,
                      CommonText(
                        string: VTaxiLocalizationService.text('vtaxi.wallet.modal_title', 'Tárca feltöltése'),
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      6.verticalSpace,
                      CommonText(
                        string:
                            VTaxiLocalizationService.text('vtaxi.wallet.modal_help', 'Válaszd ki az összeget. A teljes kiválasztott összeg kerül jóváírásra a tárcádban.'),
                        color: AppColors.textCaptionColor,
                        fontSize: 13.sp,
                        softWrap: true,
                      ),
                      if (walletController.stripeMode.value == 'test') ...[
                        10.verticalSpace,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 7.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: CommonText(
                            string: VTaxiLocalizationService.text('vtaxi.wallet.test_mode', 'TESZT MÓD – valódi pénzt nem von le'),
                            color: AppColors.brandNavy,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      18.verticalSpace,
                      Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: amounts.map((amount) {
                          final selected = selectedAmount == amount;
                          return InkWell(
                            borderRadius: BorderRadius.circular(10.r),
                            onTap: walletController.isTopupLoading.value
                                ? null
                                : () {
                                    setModalState(() {
                                      selectedAmount = amount;
                                    });
                                  },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.brandNavy
                                    : AppColors.whiteGrey,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.brandNavy
                                      : AppColors.textFieldBorderColor,
                                ),
                              ),
                              child: CommonText(
                                string: Utils.formatCurrency('$amount'),
                                color: selected
                                    ? AppColors.whiteColor
                                    : AppColors.titleTextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 15.sp,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      20.verticalSpace,
                      CustomButton(
                        text:
                            '${Utils.formatCurrency('$selectedAmount')} feltöltése',
                        isLoader: walletController.isTopupLoading.value,
                        isDisabled: walletController.isTopupLoading.value,
                        onTap: () async {
                          final success = await walletController
                              .startStripeWalletTopup(selectedAmount);
                          if (success && sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                      ),
                      10.verticalSpace,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 16.sp,
                            color: AppColors.textCaptionColor,
                          ),
                          7.horizontalSpace,
                          Expanded(
                            child: CommonText(
                              string:
                                  VTaxiLocalizationService.text('vtaxi.wallet.card_data_notice', 'A bankkártyaadatokat a Stripe kezeli; a Veszprémi Taxi nem tárolja a kártyaszámot.'),
                              color: AppColors.textCaptionColor,
                              fontSize: 11.sp,
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
