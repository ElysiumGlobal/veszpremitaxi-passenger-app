import 'package:e_taxi/feature/account/controller/account_controller.dart';
import 'package:e_taxi/feature/wallet/controller/wallet_controller.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/constants.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_string.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/dotted_widget.dart';
import '../../../widgets/webview_screen.dart';
import '../../account/pages/cash_point_screen.dart';
import '../widget/tansaction_widget.dart';

class EarningScreen extends StatefulWidget {
  const EarningScreen({super.key});

  @override
  State<EarningScreen> createState() => _EarningScreenState();
}

class _EarningScreenState extends State<EarningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (Get.arguments != null) {
      _tabController.animateTo(
        Get.arguments,
        curve: Curves.bounceInOut,
        duration: Duration(milliseconds: 100),
      );
    }
    walletController.getWalletTransaction();
    walletController.getEarningOverView(0);
    walletController.getBankInfo();
  }

  final walletController = Get.find<WalletController>();
  final accountController = Get.find<AccountController>();

  RxInt currentWeek = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBarSize: 120.h,
        title: AppString.earning.tr,
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
                Tab(text: AppString.wallet.tr),
                Tab(text: AppString.earning.tr),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: Utils().checkPlatForm,
        child: TabBarView(
          controller: _tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            RefreshIndicator(
              onRefresh: () async {
                walletController.getWalletTransaction();
                await walletController.getBankInfo(isRefresh: true);
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
                        child: Obx(
                          () => Skeletonizer(
                            enabled: walletController.walletLoading.value,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                24.verticalSpace,
                                commonContainer(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      CommonText(
                                        string: Utils.formatCurrency(
                                          walletController
                                              .recentTransactionList
                                              .value
                                              ?.data
                                              ?.currentBalance
                                              .toString(),
                                        ),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 32.sp,
                                      ),
                                      8.verticalSpace,
                                      CommonText(
                                        string:
                                            "${AppString.yourPayoutScheduled.tr} ${walletController.recentTransactionList.value?.data?.scheduledPayout ?? ""}",
                                        color: AppColors.textCaptionColor,
                                      ),
                                      DottedWidget().paddingSymmetric(
                                        vertical: 16.h,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CustomButton(
                                              text: AppString.withDraw.tr,
                                              onTap: () {
                                                withDrawMoney();
                                              },
                                            ),
                                          ),
                                          16.horizontalSpace,
                                          Expanded(
                                            child: CustomButton(
                                              buttonColor:
                                                  AppColors.transparent,
                                              borderColor: AppColors.blackColor,
                                              text: AppString.add.tr,
                                              onTap: () {
                                                addMoney();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                commonContainer(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: CommonText(
                                          string:
                                              "⚠️ ${AppString.addBankAccount.tr}",
                                          fontWeight: FontWeight.w500,
                                          softWrap: true,
                                        ),
                                      ),
                                      8.horizontalSpace,
                                      GestureDetector(
                                        onTap: () {
                                          Navigation.pushNamed(
                                            Routes.bankAccountAddScreen,
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16.w,
                                            vertical: 8.h,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                            color: AppColors.mainPrimaryColor,
                                          ),
                                          child: CommonText(
                                            string: AppString.linkNow.tr,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ).paddingSymmetric(vertical: 16.h),
                                CommonText(
                                  string: AppString.recentTransaction.tr,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                ),
                                16.verticalSpace,
                                commonContainer(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ...List.generate(
                                        (walletController
                                                    .recentTransactionList
                                                    .value
                                                    ?.data
                                                    ?.recentTransactions ??
                                                [])
                                            .length,
                                        (index) {
                                          final data = walletController
                                              .recentTransactionList
                                              .value
                                              ?.data
                                              ?.recentTransactions?[index];
                                          return GestureDetector(
                                            onTap: () {
                                              Navigation.pushNamed(
                                                Routes.walletDetailsScreen,
                                                arg: "${data?.id ?? ""}",
                                              );
                                            },
                                            behavior:
                                                HitTestBehavior.translucent,
                                            child: TransactionWidget(
                                              data: data,
                                            ),
                                          ).paddingOnly(bottom: 12.w);
                                        },
                                      ),

                                      16.verticalSpace,

                                      CustomButton(
                                        text:
                                            AppString.viewTransactionHistory.tr,
                                        buttonColor: AppColors.primaryContainer,
                                        borderColor: AppColors.mainPrimaryColor,
                                        sufixIconWidget: true,
                                        onTap: () {
                                          Navigation.pushNamed(
                                            Routes.walletTransactionScreen,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ).paddingOnly(left: 16.w, right: 16.w, bottom: 16.w),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            RefreshIndicator(
              onRefresh: () async {
                await walletController.getEarningOverView(0);
                currentWeek.value = 0;
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Obx(
                  () => Skeletonizer(
                    enabled: walletController.earningOverViewLoading.value,
                    child: IgnorePointer(
                      ignoring: walletController.earningOverViewLoading.value,
                      child: Column(
                        children: [
                          Skeletonizer(
                            enabled:
                                walletController.earningOverViewLoading.value,
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              width: double.maxFinite,
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
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.whiteGrey,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CommonText(
                                          string:
                                              walletController
                                                  .earningOverViewModel
                                                  .value
                                                  ?.data
                                                  ?.weeklySummary
                                                  ?.dateRange ??
                                              "",
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    color: AppColors.textFieldBorderColor,
                                  ).paddingSymmetric(vertical: 8.h),
                                  Obx(
                                    () => Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            currentWeek.value += 1;
                                            walletController.getEarningOverView(
                                              currentWeek.value,
                                            );
                                          },
                                          child: Icon(Icons.arrow_back_ios),
                                        ),
                                        Column(
                                          children: [
                                            CommonText(
                                              string:
                                                  walletController
                                                      .earningOverViewModel
                                                      .value
                                                      ?.data
                                                      ?.weeklySummary
                                                      ?.totalEarningThisWeek ??
                                                  "",
                                              fontWeight: FontWeight.w600,
                                              fontSize: 22.sp,
                                            ),
                                            4.verticalSpace,
                                            CommonText(
                                              string:
                                                  "Total Earning ${Utils().dateMonthWeek(currentWeek.value)}",
                                              color: AppColors.bodyText,
                                              softWrap: true,
                                              fontSize: 12.sp,
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            if (currentWeek.value != 0) {
                                              currentWeek.value -= 1;
                                              walletController
                                                  .getEarningOverView(
                                                    currentWeek.value,
                                                  );
                                            }
                                          },
                                          child: Icon(Icons.arrow_forward_ios),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          16.verticalSpace,
                          Container(
                            padding: EdgeInsets.all(16.w),
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: AppColors.textFieldBorderColor,
                              ),
                              color: AppColors.whiteColor,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (walletController
                                        .earningOverViewLoading
                                        .value ||
                                    double.parse(
                                          walletController
                                                  .earningOverViewModel
                                                  .value
                                                  ?.data
                                                  ?.weeklySummary
                                                  ?.totalEarningThisWeek ??
                                              "0.0",
                                        ).toInt() !=
                                        0)
                                  Skeletonizer(
                                    enabled: walletController
                                        .earningOverViewLoading
                                        .value,
                                    child: SizedBox(
                                      height: 300.h,
                                      child: WeeklyEarningChart(
                                        totalEarning: double.parse(
                                          walletController
                                                  .earningOverViewModel
                                                  .value
                                                  ?.data
                                                  ?.weeklySummary
                                                  ?.totalEarningThisWeek ??
                                              "0",
                                        ),
                                        days:
                                            (walletController
                                                        .earningOverViewModel
                                                        .value
                                                        ?.data
                                                        ?.dailyEarningsChart
                                                        ?.dailyData ??
                                                    [])
                                                .map((e) => e.day ?? "")
                                                .toList(),
                                        dates:
                                            (walletController
                                                        .earningOverViewModel
                                                        .value
                                                        ?.data
                                                        ?.dailyEarningsChart
                                                        ?.dailyData ??
                                                    [])
                                                .map((e) => e.date ?? "")
                                                .toList(),
                                        weeklyEarnings:
                                            (walletController
                                                        .earningOverViewModel
                                                        .value
                                                        ?.data
                                                        ?.dailyEarningsChart
                                                        ?.dailyData ??
                                                    [])
                                                .map((e) => e.earning ?? 0.0)
                                                .toList(),
                                        maxY:
                                            (walletController
                                                        .earningOverViewModel
                                                        .value
                                                        ?.data
                                                        ?.dailyEarningsChart
                                                        ?.yAxisMax ??
                                                    100)
                                                .toDouble(),
                                        minY:
                                            (walletController
                                                        .earningOverViewModel
                                                        .value
                                                        ?.data
                                                        ?.dailyEarningsChart
                                                        ?.yAxisMin ??
                                                    300)
                                                .toDouble(),
                                      ),
                                    ),
                                  ),

                                commonRow(
                                  title: AppString.walletEarning.tr,
                                  subTitle:
                                      "${walletController.earningOverViewModel.value?.data?.detailedEarningBreakdown?.walletEarning ?? "0"}",
                                ),
                                Divider(
                                  color: AppColors.textFieldBorderColor,
                                ).paddingSymmetric(vertical: 8.h),
                                commonRow(
                                  title: AppString.cashEarning.tr,
                                  subTitle:
                                      "${walletController.earningOverViewModel.value?.data?.detailedEarningBreakdown?.cashEarning ?? "0"}",
                                ),

                                Divider(
                                  color: AppColors.textFieldBorderColor,
                                ).paddingSymmetric(vertical: 8.h),
                                commonRow(
                                  title: AppString.incentiveReward.tr,
                                  subTitle:
                                      "${walletController.earningOverViewModel.value?.data?.detailedEarningBreakdown?.incentiveReward ?? "0"}",
                                ),
                                Divider(
                                  color: AppColors.textFieldBorderColor,
                                ).paddingSymmetric(vertical: 8.h),
                                commonRow(
                                  title: AppString.deduction.tr,
                                  subTitle:
                                      "${walletController.earningOverViewModel.value?.data?.detailedEarningBreakdown?.deduction ?? "0"}",
                                  isError: true,
                                ),

                                Divider(
                                  color: AppColors.textFieldBorderColor,
                                ).paddingSymmetric(vertical: 8.h),
                                commonRow(
                                  title: AppString.totalEarning.tr,
                                  subTitle:
                                      "${walletController.earningOverViewModel.value?.data?.detailedEarningBreakdown?.totalEarningForDay ?? "0"}",
                                ),

                                24.verticalSpace,

                                CustomButton(
                                  text: AppString.viewEarningHistory.tr,
                                  buttonColor: AppColors.primaryContainer,
                                  borderColor: AppColors.mainPrimaryColor,
                                  sufixIconWidget: true,
                                  onTap: () {
                                    Navigation.pushNamed(
                                      Routes.earningTransactionScreen,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          16.verticalSpace,
                          Align(
                            alignment: AlignmentGeometry.topLeft,
                            child: CommonText(
                              string: AppString.rideSummary.tr,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          16.verticalSpace,
                          Container(
                            padding: EdgeInsets.all(16.w),
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: AppColors.textFieldBorderColor,
                              ),
                              color: AppColors.whiteColor,
                            ),
                            child: Column(
                              children: [
                                IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: commonColumn(
                                          title:
                                              "${walletController.earningOverViewModel.value?.data?.rideSummary?.timeOnlineHrs ?? ""}",
                                          subTitle: AppString.timeOnline.tr,
                                        ),
                                      ),
                                      VerticalDivider(
                                        color: AppColors.textFieldBorderColor,
                                      ).paddingSymmetric(horizontal: 16.w),
                                      Expanded(
                                        child: commonColumn(
                                          title:
                                              "${walletController.earningOverViewModel.value?.data?.rideSummary?.totalRides ?? ""}",
                                          subTitle: AppString.totalRide.tr,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: AppColors.textFieldBorderColor,
                                ).paddingSymmetric(vertical: 12.h),
                                IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: commonColumn(
                                          title:
                                              "${walletController.earningOverViewModel.value?.data?.rideSummary?.completedRides ?? ""}",
                                          subTitle: AppString.completed.tr,
                                        ),
                                      ),
                                      VerticalDivider(
                                        color: AppColors.textFieldBorderColor,
                                      ),
                                      Expanded(
                                        child: commonColumn(
                                          title:
                                              "${walletController.earningOverViewModel.value?.data?.rideSummary?.completionRatePercent ?? ""}",
                                          subTitle: AppString.completionRate.tr,
                                        ),
                                      ),
                                      VerticalDivider(
                                        color: AppColors.textFieldBorderColor,
                                      ),
                                      Expanded(
                                        child: commonColumn(
                                          title:
                                              "${walletController.earningOverViewModel.value?.data?.rideSummary?.averageRating ?? ""}",
                                          subTitle: AppString.avgRating.tr,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          16.verticalSpace,
                          CustomButton(
                            prefixIconWidget: CustomImage(
                              image: IconAsset.support24,
                            ).paddingOnly(right: 8.w),
                            text: AppString.needSupport.tr,
                            buttonColor: AppColors.whiteColor,
                            borderColor: AppColors.textFieldBorderColor,
                            onTap: () {
                              Get.to(
                                () => WebviewScreen(
                                  webUrl: Constants().contactUs,
                                ),
                              );
                            },
                          ),
                        ],
                      ).paddingSymmetric(horizontal: 16.w, vertical: 24.w),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget commonRow({
    required String title,
    required String subTitle,
    bool isError = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CommonText(string: title, fontWeight: FontWeight.w600, fontSize: 16.sp),
        CommonText(
          string: Utils.formatCurrency(subTitle),
          color: isError ? AppColors.errorColor : AppColors.successColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }

  Widget commonColumn({required String title, required String subTitle}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CommonText(string: title, fontWeight: FontWeight.w500, fontSize: 16.sp),
        CommonText(
          string: subTitle,
          fontSize: 12.sp,
          color: AppColors.headlineColor,
        ),
      ],
    );
  }

  List imageList = [IconAsset.razorPay, IconAsset.stripe];

  List _payment = ["razorpay", "stripe"];
  List paymentName = [AppString.razorpay, AppString.stripe];

  void withDrawMoney() {
    TextEditingController moneyController = TextEditingController();
    List money = ["20", "50", "100"];
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.all(16.w),
            height: Get.height * 0.6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              color: AppColors.whiteColor,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 8.w,
                        width: 40.w,
                        decoration: BoxDecoration(
                          color: AppColors.textFieldBorderColor,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    24.verticalSpace,
                    CommonText(
                      string: Utils.formatCurrency(
                        "${walletController.recentTransactionList.value?.data?.currentBalance ?? "0.0"}",
                      ),
                      fontWeight: FontWeight.w600,
                      fontSize: 22.sp,
                    ),
                    4.verticalSpace,
                    CommonText(
                      string:
                          "${AppString.maxAmountWithDraw.tr} ${Utils.formatCurrency("100")}",
                      color: AppColors.bodyText,
                    ),
                    Divider(
                      color: AppColors.textFieldBorderColor,
                    ).paddingSymmetric(vertical: 8.h),
                    Align(
                      alignment: Alignment.topLeft,
                      child: CommonText(
                        string: AppString.addMoneyToWithDraw.tr,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: AppColors.whiteGrey,
                        border: Border.all(
                          color: AppColors.textFieldBorderColor,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 100.w,
                        child: TextField(
                          controller: moneyController,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 24.sp,
                            color: AppColors.titleTextColor,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(5),
                          ],
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ).paddingSymmetric(vertical: 12.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(3, (index) {
                          return GestureDetector(
                            onTap: () {
                              moneyController.text = money[index];
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                right: index == 2 ? 0 : 20.w,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 8.h,
                              ),

                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(
                                  color: AppColors.textFieldBorderColor,
                                ),
                              ),
                              child: CommonText(string: money[index]),
                            ),
                          );
                        }),
                      ],
                    ),
                    12.verticalSpace,
                    GestureDetector(
                      onTap: () {
                        Get.back();
                        Get.to(() => CashCollectionPointScreen());
                      },
                      child: Align(
                        alignment: AlignmentGeometry.centerLeft,
                        child: CommonText(
                          string: AppString.getCashCollectionPoint.tr,
                          fontWeight: FontWeight.w600,
                          fontSize: 22.sp,
                        ),
                      ),
                    ),

                    if ((walletController.accountDetails.value?.accountNumber ??
                            "")
                        .isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: AlignmentGeometry.centerLeft,
                            child: CommonText(
                              string: AppString.depositTo.tr,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ).paddingOnly(top: 6.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 14.h,
                            ).copyWith(right: 14.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              color: AppColors.whiteGrey,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 30.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(10),
                                      bottom: Radius.circular(10),
                                    ),
                                    color: AppColors.mainPrimaryColor,
                                  ),
                                ),
                                10.horizontalSpace,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CommonText(
                                        string:
                                            "${walletController.accountDetails.value?.bankName ?? ""}",
                                        color: AppColors.bodyText,
                                      ),
                                      CommonText(
                                        string:
                                            "${(walletController.accountDetails.value?.accountNumber ?? "").isEmpty ? "" : 'XXXX XXXX ${walletController.accountDetails.value?.accountNumber?.substring(((walletController.accountDetails.value?.accountNumber ?? "").length) - 4)}'}",
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ).paddingOnly(top: 6.h),
                        ],
                      ),
                    24.verticalSpace,
                    CustomButton(
                      text: AppString.withDrawMoney.tr,
                      onTap: () async {
                        if (moneyController.text.trim().isEmpty) {
                          AppSnackBar.showErrorSnackBar(
                            message: AppString.pleaseEnterAmount.tr,
                          );
                          return;
                        }
                        double wallet = double.parse(
                          walletController
                                  .recentTransactionList
                                  .value
                                  ?.data
                                  ?.currentBalance
                                  .toString() ??
                              "0.0",
                        );
                        double enterMoney = double.parse(
                          moneyController.text.trim(),
                        );

                        if (wallet < enterMoney) {
                          AppSnackBar.showErrorSnackBar(
                            message: AppString.notSufficientAmount.tr,
                          );
                          return;
                        }

                        if ((walletController
                                    .accountDetails
                                    .value
                                    ?.accountNumber ??
                                "")
                            .isEmpty) {
                          AppSnackBar.showErrorSnackBar(
                            message: AppString.enterBankDetails.tr,
                          );

                          return;
                        }

                        final res = await walletController.withDrawMoney(
                          amount: moneyController.text.trim(),
                          accountId:
                              (walletController.accountDetails.value?.id ?? "")
                                  .toString(),
                        );

                        if (res.isNotEmpty) {
                          Get.back();
                          AppSnackBar.showErrorSnackBar(
                            message: res['message'],
                          );
                          walletController.getWalletTransaction();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void addMoney() {
    TextEditingController moneyController = TextEditingController();
    List money = ["50", "100", "200"];

    RxInt selectedIndex = 0.obs;
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.all(16.w),
            height: Get.height * 0.6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              color: AppColors.whiteColor,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      string: AppString.addMoney.tr,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                    Divider(
                      color: AppColors.textFieldBorderColor,
                    ).paddingSymmetric(vertical: 8.h),

                    16.verticalSpace,
                    Align(
                      alignment: Alignment.topLeft,
                      child: CommonText(
                        string: AppString.addMoneyToWallet.tr,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: AppColors.whiteGrey,
                        border: Border.all(
                          color: AppColors.textFieldBorderColor,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 100.w,
                        child: TextField(
                          controller: moneyController,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 24.sp,
                            color: AppColors.titleTextColor,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(5),
                          ],
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ).paddingSymmetric(vertical: 12.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(3, (index) {
                          return GestureDetector(
                            onTap: () {
                              moneyController.text = money[index];
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                right: index == 2 ? 0 : 20.w,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 8.h,
                              ),

                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(
                                  color: AppColors.textFieldBorderColor,
                                ),
                              ),
                              child: CommonText(string: money[index]),
                            ),
                          );
                        }),
                      ],
                    ),
                    12.verticalSpace,

                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) => 8.verticalSpace,
                      itemCount: _payment.length,
                      itemBuilder: (context, index) {
                        return (accountController
                                    .userModel
                                    .value
                                    ?.availablePayment
                                    ?.contains(_payment[index]) ??
                                false)
                            ? GestureDetector(
                                onTap: () {
                                  selectedIndex.value = index;
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
                                        CustomImage(
                                          image: imageList[index],
                                          ht: 24.h,
                                          wt: 24.h,
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

                    CustomButton(
                      text: AppString.addMoney.tr,
                      onTap: () async {
                        if (moneyController.text.trim().isEmpty) {
                          AppSnackBar.showErrorSnackBar(
                            message: AppString.pleaseEnterAmount.tr,
                          );
                          return;
                        }

                        await walletController.addMoney(
                          amount: moneyController.text.trim(),
                          method: _payment[selectedIndex.value],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget commonContainer({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: AppColors.whiteColor,
        border: Border.all(color: AppColors.textFieldBorderColor),
      ),
      child: child,
    );
  }
}

class WeeklyEarningChart extends StatefulWidget {
  const WeeklyEarningChart({
    required this.dates,
    required this.days,
    required this.weeklyEarnings,
    required this.minY,
    required this.maxY,
    required this.totalEarning,
    super.key,
  });

  final List<String> days;
  final List<String> dates;
  final List<double> weeklyEarnings;
  final double minY;
  final double maxY;
  final double totalEarning;

  @override
  State<WeeklyEarningChart> createState() => _WeeklyEarningChartState();
}

class _WeeklyEarningChartState extends State<WeeklyEarningChart> {
  int? touchedIndex;

  int checkDivider(double money) {
    switch (money) {
      case < 1000:
        return 200;
      case < 3000:
        return 500;
      case < 10000:
        return 1000;

      case < 20000:
        return 4000;

      default:
        return 5000;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1.3,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: widget.maxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          Utils.formatCurrency(rod.toY.toStringAsFixed(2)),
                          const TextStyle(
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    touchCallback: (event, response) {
                      if (response != null &&
                          response.spot != null &&
                          event.isInterestedForInteractions) {
                        setState(() {
                          touchedIndex = response.spot!.touchedBarGroupIndex;
                        });
                      } else {
                        setState(() {
                          touchedIndex = null;
                        });
                      }
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        interval: 100,
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value % checkDivider(widget.totalEarning) == 0) {
                            return CommonText(
                              string: '${value.toInt()}',
                              fontSize: 12.sp,
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50.h,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < widget.days.length) {
                            final isSelected = touchedIndex == index;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                children: [
                                  Text(
                                    widget.dates[index],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppColors.primaryContainer
                                          : AppColors.blackColor,
                                    ),
                                  ),
                                  Text(
                                    widget.days[index],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppColors.primaryContainer
                                          : AppColors.blackColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: false),

                  borderData: FlBorderData(
                    show: true,

                    border: Border(
                      bottom: BorderSide(color: AppColors.blackColor, width: 2),
                      left: BorderSide(color: AppColors.transparent),
                      right: BorderSide(color: AppColors.transparent),
                      top: BorderSide(color: AppColors.transparent),
                    ),
                  ),
                  barGroups: List.generate(widget.weeklyEarnings.length, (
                    index,
                  ) {
                    final isSelected = touchedIndex == index;
                    final baseColor = touchedIndex == null
                        ? AppColors.mainPrimaryColor
                        : AppColors.primaryContainer;
                    final highlightColor = AppColors.mainPrimaryColor;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: widget.weeklyEarnings[index],
                          color: isSelected ? highlightColor : baseColor,
                          width: 20,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.r),
                            topRight: Radius.circular(10.r),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: false,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
