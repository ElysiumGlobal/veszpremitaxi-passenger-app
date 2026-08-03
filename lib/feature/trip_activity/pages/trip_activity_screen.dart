import 'package:e_taxi/feature/home/pages/home_screen.dart';
import 'package:e_taxi/utils/navigation_utils/navigation.dart';
import 'package:e_taxi/utils/navigation_utils/routes.dart';
import 'package:e_taxi/feature/trip_activity/controller/trip_activity_controller.dart';
import 'package:e_taxi/feature/trip_activity/model/trip_activity_model.dart';
import 'package:e_taxi/feature/trip_activity/widget/support_widget.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_preferences.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../widgets/app_snackbar.dart';
import '../../../widgets/common_widget.dart';
import '../../../widgets/no_data_widget.dart';
import '../../auth/widget/subtitle_title_widget.dart';
import '../widget/checkBox.dart';
import '../widget/ride_details_widget.dart';


class _ActiveRideAddress extends StatelessWidget {
  const _ActiveRideAddress({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: AppColors.mainPrimaryColor, size: 20.sp),
        10.horizontalSpace,
        Expanded(
          child: CommonText(
            string: text.isEmpty ? 'Cím betöltése…' : text,
            color: AppColors.whiteColor.withValues(alpha: .86),
            fontSize: 13.sp,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}

class TripActivityScreen extends StatefulWidget {
  const TripActivityScreen({super.key});

  @override
  State<TripActivityScreen> createState() => _TripActivityScreenState();
}

class _TripActivityScreenState extends State<TripActivityScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    Future.microtask(() {
      tripController.getTodayTrip();
      tripController.getWeekTrip();
    });

    todayScrollController.addListener(() {
      if (todayScrollController.position.pixels >=
              todayScrollController.position.maxScrollExtent - 300 &&
          tripController.isMoreTodayAvailable &&
          tripController.todayPaginationLoading.value == false) {
        tripController.todayPaginationLoading(true);
        tripController.getTodayTrip(isFirstTime: false);
      }
    });

    weeklyScrollController.addListener(() {
      if (weeklyScrollController.position.pixels >=
              weeklyScrollController.position.maxScrollExtent - 300 &&
          tripController.weeklyMoreAvailable &&
          tripController.weeklyPaginationLoading.value == false) {
        tripController.weeklyPaginationLoading(true);
        tripController.getWeekTrip(isFirstTime: false);
      }
    });
  }

  ScrollController todayScrollController = ScrollController();
  ScrollController weeklyScrollController = ScrollController();

  final tripController = Get.find<TripController>();

  @override
  void dispose() {
    _tabController.dispose();

    todayScrollController.dispose();
    weeklyScrollController.dispose();
    tripController.clearWeeklyFilter();
    tripController.clearTodayFilter();

    super.dispose();
  }

  List<String> todayFilterList = [
    AppString.tripType,
    AppString.paymentMode,
    AppString.amount,
    AppString.distance,
  ];
  List<String> weeklyFilterList = [
    AppString.date,
    AppString.tripType,
    AppString.paymentMode,
    AppString.amount,
    AppString.distance,
  ];

  void getToken() {
    // Biztonsági okból a hozzáférési tokent soha nem írjuk naplóba.
  }

  DateTime now = DateTime.now();

  RxInt currentWeek = 0.obs;

  String _activeRideStatusLabel(String status) {
    return switch (status.toLowerCase()) {
      'accepted' => 'Úton az utashoz',
      'arrived' => 'Megérkezett az utashoz',
      'started' => 'Fuvar folyamatban',
      _ => 'Aktív fuvar',
    };
  }

  Widget _buildActiveRideCard() {
    final ride = rideDataModel.value;
    final booking = ride?.booking;
    final status = (booking?.status ?? '').toLowerCase().trim();
    const activeStatuses = <String>{'accepted', 'arrived', 'started'};
    if (ride == null || booking == null || !activeStatuses.contains(status)) {
      return const SizedBox.shrink();
    }

    final String bookingId = (ride.bookingId ?? booking.id ?? '').toString();
    final String passengerName =
        (ride.customer?.customerName ?? ride.passenger?.name ?? 'Utas').trim();
    final String phone = (ride.passenger?.phone ?? booking.user?.phone ?? '').trim();
    final String pickup = (ride.pickup?.address ?? booking.pickupAddress ?? '').trim();
    final String dropoff = (ride.dropoff?.address ?? booking.dropoffAddress ?? '').trim();
    final String etaMinutes = (booking.driverEtaMinutes ??
            ride.driverEtaMinutes?.toString() ??
            '')
        .trim();
    final String expectedRaw = (booking.driverExpectedArrivalAt ??
            ride.driverExpectedArrivalAt ??
            '')
        .trim();
    final DateTime? expected = DateTime.tryParse(expectedRaw)?.toLocal();
    final String expectedText = expected == null
        ? ''
        : '${expected.hour.toString().padLeft(2, '0')}:${expected.minute.toString().padLeft(2, '0')}';
    final String eta = expectedText.isNotEmpty
        ? 'Várható felvétel: $expectedText${etaMinutes.isEmpty ? '' : ' ($etaMinutes perc)'}'
        : etaMinutes.isNotEmpty
            ? '$etaMinutes perc vállalt érkezés'
            : 'Érkezési idő egyeztetve';

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 4.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF071329),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.mainPrimaryColor, width: 1.4),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: .12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.mainPrimaryColor,
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: CommonText(
                  string: 'ÉLŐ FUVAR',
                  color: AppColors.titleTextColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 11.sp,
                ),
              ),
              10.horizontalSpace,
              Expanded(
                child: CommonText(
                  string: _activeRideStatusLabel(status),
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
              Icon(Icons.circle, color: AppColors.successColor, size: 12.sp),
            ],
          ),
          14.verticalSpace,
          CommonText(
            string: passengerName.isEmpty ? 'Utas' : passengerName,
            color: AppColors.whiteColor,
            fontWeight: FontWeight.w800,
            fontSize: 20.sp,
          ),
          6.verticalSpace,
          CommonText(
            string: eta,
            color: AppColors.mainPrimaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 13.sp,
          ),
          14.verticalSpace,
          _ActiveRideAddress(icon: Icons.trip_origin_rounded, text: pickup),
          8.verticalSpace,
          _ActiveRideAddress(icon: Icons.location_on_rounded, text: dropoff),
          16.verticalSpace,
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: phone.isEmpty ? null : () => Utils().launchDialer(phone),
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Hívás'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.whiteColor,
                    side: BorderSide(color: Colors.white.withValues(alpha: .4)),
                  ),
                ),
              ),
              8.horizontalSpace,
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: bookingId.isEmpty
                      ? null
                      : () => Navigation.pushNamed(
                            Routes.chatScreen,
                            params: <String, String>{'bookingId': bookingId},
                          ),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.whiteColor,
                    side: BorderSide(color: Colors.white.withValues(alpha: .4)),
                  ),
                ),
              ),
              8.horizontalSpace,
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigation.pushNamed(Routes.mapNavigationScreen),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Megnyitás'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.mainPrimaryColor,
                    foregroundColor: AppColors.titleTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBarSize: 120.h,
        title: AppString.tripActivity.tr,
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
                Tab(text: AppString.today.tr),
                Tab(text: AppString.weekly.tr),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: Utils().checkPlatForm,
        child: Column(
          children: <Widget>[
            Obx(_buildActiveRideCard),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
            Obx(
              () => Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    margin: EdgeInsets.symmetric(vertical: 24.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: AppColors.whiteColor,
                      border: Border.all(color: AppColors.textFieldBorderColor),
                    ),
                    child: Skeletonizer(
                      enabled: tripController.todayTripLoading.value,
                      child: SubtitleTitleWidget(
                        subTitle: AppString.earning.tr,
                        secsubTitle: AppString.timeOnline.tr,
                        thirdsubTitle: AppString.ride.tr,
                        title: Utils.formatCurrency(
                          tripController
                              .todayTripModel
                              .value
                              .data
                              ?.summary
                              ?.totalEarnings
                              .toString(),
                        ),
                        sectitle:
                            tripController
                                .todayTripModel
                                .value
                                .data
                                ?.summary
                                ?.totalOnlineHours ??
                            "",
                        thirdtitle:
                            tripController
                                .todayTripModel
                                .value
                                .data
                                ?.summary
                                ?.totalTrips ??
                            "",
                        topBlackColor: true,
                      ),
                    ),
                  ),

                  Skeletonizer(
                    enabled: tripController.todayTripLoading.value,
                    child: SizedBox(
                      height: 40.h,
                      child: ListView.separated(
                        separatorBuilder: (context, index) =>
                            10.horizontalSpace,

                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              todayFilterTap(index);
                            },
                            child: Container(
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
                                  CommonText(string: todayFilterList[index].tr),
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
                  16.verticalSpace,
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        tripController.clearTodayFilter();
                        await tripController.getTodayTrip(isFirstTime: true);
                      },

                      child: tripController.todayTripLoading.value
                          ? ListView.separated(
                              itemBuilder: (context, index) => Skeletonizer(
                                enabled: true,
                                child: RideDetailsLoadingWidget(
                                  bgColor: AppColors.sucessContainer,
                                  mainColor: AppColors.successColor,
                                ),
                              ),
                              separatorBuilder: (context, index) =>
                                  16.verticalSpace,
                              itemCount: 3,
                            )
                          : (tripController.todayTripModel.value.data?.trips ??
                                    [])
                                .isEmpty
                          ? NoDataWidget(
                              icon: ImagesAsset.noData,
                              title: AppString.noDataAvailable.tr,
                              subTitle: AppString.weNotFindAnything.tr,
                              onTap: () {
                                tripController.getTodayTrip();
                              },
                            )
                          : ListView.separated(
                              controller: todayScrollController,
                              itemBuilder: (context, index) {
                                Trip? data = tripController
                                    .todayTripModel
                                    .value
                                    .data
                                    ?.trips?[index];
                                return RideDetailsWidget(trip: data);
                              },
                              separatorBuilder: (context, index) =>
                                  16.verticalSpace,
                              itemCount:
                                  (tripController
                                              .todayTripModel
                                              .value
                                              .data
                                              ?.trips ??
                                          [])
                                      .length,
                            ),
                    ),
                  ),

                  24.verticalSpace,
                ],
              ).paddingSymmetric(horizontal: 16.w),
            ),
            Obx(
              () => Column(
                children: [
                  containerWidgetTrip(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  currentWeek.value += 1;
                                  tripController.weeklyFilterOn.value = true;

                                  tripController.weeklyStartDateF.value =
                                      Utils().getWeekRange(
                                        currentWeek.value,
                                      )['start'] ??
                                      "";
                                  tripController.weeklyEndDateF.value =
                                      Utils().getWeekRange(
                                        currentWeek.value,
                                      )['end'] ??
                                      "";

                                  tripController.weeklyDateF.value = 3;
                                  await Future.delayed(
                                    Duration(milliseconds: 50),
                                  );

                                  tripController.getWeekTrip();
                                },
                                child: Icon(Icons.arrow_back_ios_new),
                              ),
                              CommonText(
                                string: Utils().dateMonthWeek(
                                  currentWeek.value,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (currentWeek.value != 0) {
                                    currentWeek.value -= 1;
                                    tripController.weeklyFilterOn.value = true;
                                    tripController.weeklyStartDateF.value =
                                        Utils().getWeekRange(
                                          currentWeek.value,
                                        )['start'] ??
                                        "";
                                    tripController.weeklyEndDateF.value =
                                        Utils().getWeekRange(
                                          currentWeek.value,
                                        )['end'] ??
                                        "";
                                    tripController.weeklyDateF.value = 3;

                                    tripController.getWeekTrip();
                                  }
                                },
                                child: Icon(Icons.arrow_forward_ios),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: AppColors.textFieldBorderColor,
                        ).paddingSymmetric(vertical: 8.h),

                        SubtitleTitleWidget(
                          subTitle: AppString.earning.tr,
                          secsubTitle: AppString.timeOnline.tr,
                          thirdsubTitle: AppString.ride.tr,
                          title: Utils.formatCurrency(
                            tripController
                                .weeklyTripModel
                                .value
                                .data
                                ?.summary
                                ?.totalEarnings,
                          ),
                          sectitle:
                              "${tripController.weeklyTripModel.value.data?.summary?.totalOnlineHours ?? 0} Hr",
                          thirdtitle:
                              "${tripController.weeklyTripModel.value.data?.summary?.totalTrips ?? 0}",
                          topBlackColor: true,
                        ),
                      ],
                    ),
                  ).paddingOnly(top: 24.h, bottom: 16.h),

                  Skeletonizer(
                    enabled: tripController.weeklyTripLoading.value,
                    child: SizedBox(
                      height: 36.h,
                      child: ListView.separated(
                        padding: EdgeInsets.only(left: 16.w),
                        separatorBuilder: (context, index) =>
                            16.horizontalSpace,
                        scrollDirection: Axis.horizontal,
                        itemCount: weeklyFilterList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              weeklyFiterTap(index);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                color: AppColors.whiteColor,
                                border: Border.all(
                                  color: AppColors.textFieldBorderColor,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                children: [
                                  CommonText(
                                    string: weeklyFilterList[index].tr,
                                  ),
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

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        tripController.weeklyFilterOn.value = false;
                        tripController.clearWeeklyFilter();
                        currentWeek.value = 0;
                        tripController.getWeekTrip();
                      },

                      child: tripController.weeklyTripLoading.value
                          ? ListView.separated(
                              physics: AlwaysScrollableScrollPhysics(),
                              itemBuilder: (context, index) => Skeletonizer(
                                enabled: true,
                                child: RideDetailsLoadingWidget(
                                  bgColor: AppColors.sucessContainer,
                                  mainColor: AppColors.successColor,
                                ),
                              ),
                              separatorBuilder: (context, index) =>
                                  16.verticalSpace,
                              itemCount: 3,
                            )
                          : (tripController.weeklyTripModel.value.data?.trips ??
                                    [])
                                .isEmpty
                          ? NoDataWidgetss(
                              onTap: () {
                                tripController.weeklyFilterOn.value = false;
                                tripController.clearWeeklyFilter();
                                currentWeek.value = 0;
                                tripController.getWeekTrip();
                              },
                            )
                          : ListView.separated(
                              controller: weeklyScrollController,
                              padding: EdgeInsets.symmetric(vertical: 16.w),
                              itemBuilder: (context, index) {
                                Trip? data = tripController
                                    .weeklyTripModel
                                    .value
                                    .data
                                    ?.trips?[index];
                                return RideDetailsWidget(trip: data);
                              },
                              separatorBuilder: (context, index) =>
                                  16.verticalSpace,
                              itemCount:
                                  (tripController
                                              .weeklyTripModel
                                              .value
                                              .data
                                              ?.trips ??
                                          [])
                                      .length,
                            ),
                    ),
                  ),
                ],
              ).paddingSymmetric(horizontal: 16.w),
            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void todayFilterTap(int index) {
    if (index == 0) {
      List<String> typeList = [
        AppString.completed,
        AppString.cancelByDriver,
        AppString.cancelByRaider,
      ];

      CustomWidget.commonBottomSheetWidget(
        title: AppString.tripType.tr,
        onTap: () {
          tripController.todayFilterOn.value = true;
          tripController.getTodayTrip();
          Get.back();
        },
        child: [
          ...List.generate(typeList.length, (index) {
            return Obx(
              () => CheckboxWidget(
                onTap: (val) {
                  if (tripController.todayTripTypeF.value == index) {
                    tripController.todayTripTypeF.value = -1;
                  } else {
                    tripController.todayTripTypeF.value = index;
                  }
                },
                title: typeList[index].tr,
                select: tripController.todayTripTypeF.value == index,
              ).paddingOnly(bottom: 21.h),
            );
          }).toList(),
        ],
      );
    } else if (index == 1) {
      List<String> checkBoxString = [
        AppString.cashPayment,
        AppString.walletPayment,
        AppString.onlinePayment,
      ];

      CustomWidget.commonBottomSheetWidget(
        title: todayFilterList[index].tr,
        child: [
          ...List.generate(3, (index) {
            return Obx(
              () => CheckboxWidget(
                title: checkBoxString[index].tr,
                select: tripController.todayPaymentModeF.value == index,
                onTap: (bool value) {
                  if (tripController.todayPaymentModeF.value == index) {
                    tripController.todayPaymentModeF.value = -1;
                  } else {
                    tripController.todayPaymentModeF.value = index;
                  }
                },
              ).paddingOnly(bottom: 21.h),
            );
          }).toList(),
        ],
        onTap: () {
          Get.back();

          tripController.todayFilterOn.value = true;

          tripController.getTodayTrip();
        },
      );
    } else if (index == 2) {
      List amaountList = [
        "<${Utils.formatCurrency("25")}",
        "${Utils.formatCurrency("25")} - ${Utils.formatCurrency("50")}",
        "${Utils.formatCurrency("50")} - ${Utils.formatCurrency("100")}",
        ">${Utils.formatCurrency("100")}",
        AppString.customRange.tr,
      ];

      TextEditingController minController = TextEditingController(
        text: tripController.todayMinAmountF,
      );
      TextEditingController maxController = TextEditingController(
        text: tripController.todayMaxAmountF,
      );

      CustomWidget.commonBottomSheetWidget(
        title: AppString.amount.tr,
        onTap: () {
          tripController.todayFilterOn.value = true;

          if (tripController.todayAmountF.value == 4) {
            var min = num.parse(
              tripController.todayMinAmountF.isEmpty
                  ? "0"
                  : tripController.todayMinAmountF,
            );
            var max = num.parse(
              tripController.todayMaxAmountF.isEmpty
                  ? "0"
                  : tripController.todayMaxAmountF,
            );

            if (min >= max) {
              AppSnackBar.showErrorSnackBar(
                message: "Adj meg érvényes maximális összeget.",
                isError: true,
              );
            } else {
              tripController.getTodayTrip();
              Get.back();
            }
          } else {
            Get.back();
            tripController.getTodayTrip();
          }
        },
        child: [
          ...List.generate(amaountList.length, (index) {
            return Obx(
              () => CheckboxWidget(
                onTap: (va) {
                  if (tripController.todayAmountF.value == index) {
                    tripController.todayAmountF.value = -1;
                  } else {
                    tripController.todayAmountF.value = index;
                  }
                },
                title: amaountList[index],
                select: tripController.todayAmountF.value == index,
              ).paddingOnly(bottom: 21.h),
            );
          }).toList(),
          Obx(
            () => tripController.todayAmountF.value == 4
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
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                            tripController.todayMinAmountF = v;
                          },
                        ),
                      ),

                      16.horizontalSpace,

                      Expanded(
                        child: CustomTextField(
                          hintText: AppString.enterMaxAmount.tr,
                          controller: maxController,
                          keyboardType: TextInputType.number,
                          textinputformate: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (v) {
                            tripController.todayMaxAmountF = v;
                          },
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
      List<String> distanceList = ["0-5 KM", "5-10 KM", "10-15 KM", ">15 KM"];

      CustomWidget.commonBottomSheetWidget(
        title: AppString.distance.tr,
        onTap: () {
          Get.back();
          tripController.todayFilterOn.value = true;
          tripController.getTodayTrip();
        },
        child: [
          ...List.generate(distanceList.length, (index) {
            return Obx(
              () => CheckboxWidget(
                onTap: (v) {
                  if (tripController.todayDistanceF.value == index) {
                    tripController.todayDistanceF.value = -1;
                  } else {
                    tripController.todayDistanceF.value = index;
                  }
                },
                title: distanceList[index],
                select: tripController.todayDistanceF.value == index,
                radius: 30.r,
              ).paddingOnly(bottom: 21.h),
            );
          }).toList(),
        ],
      );
    }
  }

  void weeklyFiterTap(int index) {
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
          tripController.weeklyFilterOn.value = true;
          tripController.getWeekTrip();
          Get.back();
        },
        child: [
          ...List.generate(list.length, (index) {
            return Obx(
              () => CheckboxWidget(
                onTap: (bool value) {
                  if (tripController.weeklyDateF.value == index) {
                    tripController.weeklyDateF.value = -1;
                  } else {
                    tripController.weeklyDateF.value = index;
                  }
                },
                title: list[index],
                select: tripController.weeklyDateF.value == index,
              ).paddingOnly(bottom: 21.h),
            );
          }).toList(),
          Obx(
            () => tripController.weeklyDateF.value == 3
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
                              tripController.weeklyEndDateF.value = "";
                              tripController.weeklyStartDateF.value = Utils()
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
                                        tripController
                                            .weeklyStartDateF
                                            .value
                                            .isNotEmpty
                                        ? tripController.weeklyStartDateF.value
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
                                tripController.weeklyStartDateF.value.isEmpty,
                            child: GestureDetector(
                              onTap: () async {
                                final selectedDate = await showDatePicker(
                                  context: context,
                                  firstDate:
                                      Utils().calenderDate(
                                        tripController.weeklyStartDateF.value,
                                      ) ??
                                      DateTime.now(),
                                  lastDate: DateTime.now(),
                                );
                                if (selectedDate != null) {
                                  tripController.weeklyEndDateF.value = Utils()
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
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Obx(
                                      () => CommonText(
                                        string:
                                            tripController
                                                .weeklyEndDateF
                                                .value
                                                .isNotEmpty
                                            ? tripController
                                                  .weeklyEndDateF
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
      List<String> typeList = [
        AppString.completed,
        AppString.cancelByDriver,
        AppString.cancelByRaider,
      ];

      CustomWidget.commonBottomSheetWidget(
        title: AppString.tripType.tr,
        onTap: () {
          tripController.weeklyFilterOn.value = true;
          tripController.getWeekTrip();
          Get.back();
        },
        child: [
          ...List.generate(typeList.length, (index) {
            return Obx(
              () => CheckboxWidget(
                onTap: (val) {
                  if (tripController.weeklyTripTypeF.value == index) {
                    tripController.weeklyTripTypeF.value = -1;
                  } else {
                    tripController.weeklyTripTypeF.value = index;
                  }
                },
                title: typeList[index].tr,
                select: tripController.weeklyTripTypeF.value == index,
              ).paddingOnly(bottom: 21.h),
            );
          }).toList(),
        ],
      );
    } else if (index == 2) {
      List<String> checkBoxString = [
        AppString.cashPayment,
        AppString.walletPayment,
        AppString.onlinePayment,
      ];

      CustomWidget.commonBottomSheetWidget(
        title: todayFilterList[index].tr,
        child: [
          ...List.generate(3, (index) {
            return Obx(
              () => CheckboxWidget(
                title: checkBoxString[index].tr,
                select: tripController.weeklyPaymentModeF.value == index,
                onTap: (bool value) {
                  if (tripController.weeklyPaymentModeF.value == index) {
                    tripController.weeklyPaymentModeF.value = -1;
                  } else {
                    tripController.weeklyPaymentModeF.value = index;
                  }
                },
              ).paddingOnly(bottom: 21.h),
            );
          }).toList(),
        ],
        onTap: () {
          tripController.weeklyFilterOn.value = true;
          tripController.getWeekTrip();
          Get.back();
        },
      );
    } else if (index == 3) {
      List amaountList = [
        "<${Utils.formatCurrency("25")}",
        "${Utils.formatCurrency("25")} - ${Utils.formatCurrency("50")}",
        "${Utils.formatCurrency("50")} - ${Utils.formatCurrency("100")}",
        ">${Utils.formatCurrency("100")}",
        AppString.customRange.tr,
      ];

      TextEditingController minController = TextEditingController(
        text: tripController.weeklyMinAmountF,
      );
      TextEditingController maxController = TextEditingController(
        text: tripController.weeklyMaxAmountF,
      );
      CustomWidget.commonBottomSheetWidget(
        title: AppString.amount.tr,
        onTap: () {
          tripController.weeklyFilterOn.value = true;
          if (tripController.weeklyAmountF.value == 4) {
            var min = num.parse(
              tripController.weeklyMinAmountF.isEmpty
                  ? "0"
                  : tripController.weeklyMinAmountF,
            );
            var max = num.parse(
              tripController.weeklyMaxAmountF.isEmpty
                  ? "0"
                  : tripController.weeklyMaxAmountF,
            );

            if (min >= max) {
              AppSnackBar.showErrorSnackBar(
                message: "Adj meg érvényes maximális összeget.",
                isError: true,
              );
            } else {
              tripController.getWeekTrip();
              Get.back();
            }
          } else {
            tripController.getWeekTrip();
            Get.back();
          }
        },
        child: [
          ...List.generate(amaountList.length, (index) {
            return Obx(
              () => CheckboxWidget(
                onTap: (va) {
                  if (tripController.weeklyAmountF.value == index) {
                    tripController.weeklyAmountF.value = -1;
                  } else {
                    tripController.weeklyAmountF.value = index;
                  }

                  if (tripController.weeklyAmountF.value != 4) {
                    tripController.weeklyMinAmountF = '';
                    tripController.weeklyMaxAmountF = '';
                  }
                },
                title: amaountList[index],
                select: tripController.weeklyAmountF.value == index,
              ).paddingOnly(bottom: 21.h),
            );
          }).toList(),
          Obx(
            () => tripController.weeklyAmountF.value == 4
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
                            tripController.weeklyMinAmountF = v;
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
                            tripController.weeklyMaxAmountF = v;
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
    } else if (index == 4) {
      List<String> distanceList = ["0-5 KM", "5-10 KM", "10-15 KM", ">15 KM"];
      CustomWidget.commonBottomSheetWidget(
        title: AppString.distance.tr,
        onTap: () {
          tripController.weeklyFilterOn.value = true;
          tripController.getWeekTrip();
          Get.back();
        },
        child: [
          ...List.generate(distanceList.length, (index) {
            return Obx(
              () => CheckboxWidget(
                onTap: (v) {
                  if (tripController.weeklyDistanceF.value == index) {
                    tripController.weeklyDistanceF.value = -1;
                  } else {
                    tripController.weeklyDistanceF.value = index;
                  }
                },
                title: distanceList[index],
                select: tripController.weeklyDistanceF.value == index,
                radius: 30.r,
              ).paddingOnly(bottom: 21.h),
            );
          }).toList(),
        ],
      );
    }
  }
}
