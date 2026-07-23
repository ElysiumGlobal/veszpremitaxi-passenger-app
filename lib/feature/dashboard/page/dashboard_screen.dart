import 'dart:async';

import 'package:e_taxi/feature/home/page/home_screen.dart';
import 'package:e_taxi/feature/home/widget/dialog.dart';
import 'package:e_taxi/feature/profile/controller/profile_controller.dart';
import 'package:e_taxi/feature/profile/page/profile_screen.dart';
import 'package:e_taxi/feature/trip/controller/trip_controller.dart';
import 'package:e_taxi/feature/trip/page/trip_screen.dart';
import 'package:e_taxi/feature/wallet/page/wallet_screen.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/helper/notification_service/firebase_notification_service.dart';
import '../../../core/location_utils.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_string.dart';
import '../../../utils/log_utils.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../../home/controller/home_controller.dart';
import '../../wallet/controller/wallet_controller.dart';
import '../controller/dahboard_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  final dashBoardController = Get.put(DashBoardController());

  final profileController = Get.put(ProfileController());
  final homeController = Get.put(HomeController(), permanent: true);
  final tripController = Get.put(TripController());
  final walletController = Get.put(WalletController());

  StreamSubscription<Map<String, dynamic>>? stream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    stream?.cancel();
    stream = FireBaseNotification.selectNotificationSubject.listen((value) {
      if (value.containsKey("chat_id")) {
        Future.delayed(Duration(milliseconds: 500), () {
          Navigation.pushNamed(
            Routes.chatScreen,
            params: {'bookingId': '${value['booking_id']}'},
          );
        });
      }
    });
    profileController.getUserData(isRedirect: true);

    Future.delayed(Duration(seconds: 2), () {
      FireBaseNotification().notificationPermission();
    });
  }

  RxBool isPop = false.obs;

  void tapToCallAPi(int index) {
    switch (index) {
      case 0:
        return;
      case 1:
        profileController.getUserData(isRedirect: true);
        if (tripController.tripHistoryList.isNotEmpty) {
          tripController.getTripHistory();
        }
        return;
      case 2:
        // walletController.getWalletData();
        return;
      default:
        return;
    }
  }

  bool isOpen = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    LogUtils.printAction("------ $state _______");

    if (state == AppLifecycleState.resumed) {
      if (isOpen == false) {
        LocationService().initialize(
          isopenSetting: false,
          streamDispose: true,
          askPermission: false,
        );
        isOpen = true;
      }
    } else if (state == AppLifecycleState.inactive) {
      isOpen = false;
    } else if (state == AppLifecycleState.paused) {
      isOpen = false;
    } else if (state == AppLifecycleState.detached) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ❌ cleanup
    stream?.cancel();
    FireBaseNotification().removeListner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dashBoardController.getSetting();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        // ✅ Transparent status bar
        statusBarIconBrightness: Brightness.dark,
        // ✅ For Android (black icons)
        statusBarBrightness: Brightness.light, // ✅
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop == false) {
            final result = await AppDialog.commonDialog(
              barrierDismissible: false,
              childs: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonText(
                    string: "E-Taxi",
                    fontWeight: FontWeight.w600,
                    fontSize: 26.sp,
                  ),
                  16.verticalSpace,
                  CommonText(
                    string: AppString.areYouSureExitApp.tr,
                    fontSize: 16.sp,
                    softWrap: true,
                  ),
                  24.verticalSpace,
                  CustomButton(
                    text: AppString.cancelIStay.tr,
                    onTap: () {
                      Get.back(result: false);
                    },
                  ),
                  16.verticalSpace,
                  CustomButton(
                    text: AppString.okayIGo.tr,
                    buttonColor: AppColors.transparent,
                    borderColor: AppColors.blackColor,
                    onTap: () {
                      Get.back(result: true);
                    },
                  ),
                ],
              ),
            );
            if (result) {
              SystemNavigator.pop();
            }
          }
        },
        child: Container(
          color: AppColors.whiteColor,
          child: SafeArea(
            bottom: Utils().checkPlatForm,
            child: Scaffold(
              backgroundColor: AppColors.whiteColor,
              body: Obx(
                () => IndexedStack(
                  index: dashBoardController.selectedIndex.value,
                  children: [
                    HomeScreen(),
                    TripScreen(),
                    WalletScreen(),
                    ProfileScreen(),
                  ],
                ),
              ),
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blackColor.withValues(alpha: .4),
                      offset: Offset(0, -1),
                      spreadRadius: 0,
                      blurRadius: 5,
                    ),
                  ],
                ),
                padding: EdgeInsets.only(top: 5.w),
                child: Obx(
                  () => Theme(
                    data: ThemeData(
                      splashColor: AppColors.transparent,
                      highlightColor: AppColors.transparent,
                    ),
                    child: BottomNavigationBar(
                      backgroundColor: AppColors.whiteColor,
                      currentIndex: dashBoardController.selectedIndex.value,
                      onTap: (value) {
                        if (dashBoardController.selectedIndex.value != value) {
                          dashBoardController.selectedIndex.value = value;
                          tapToCallAPi(value);
                        }
                      },
                      elevation: 0,
                      selectedItemColor: AppColors.mainPrimaryColor,
                      unselectedItemColor: AppColors.titleTextColor,
                      type: BottomNavigationBarType.fixed,

                      selectedLabelStyle: TextStyle(
                        color: AppColors.mainPrimaryColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      unselectedLabelStyle: TextStyle(
                        color: AppColors.titleTextColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                      ),

                      items: [
                        BottomNavigationBarItem(
                          icon: CustomImage(
                            image: IconAsset.bHomeUnelected,
                            ht: 24.h,
                            wt: 24.h,
                          ),
                          activeIcon: CustomImage(
                            image: IconAsset.bHome,
                            ht: 24.h,
                            wt: 24.h,
                          ),
                          label: "Home",
                        ),
                        BottomNavigationBarItem(
                          icon: CustomImage(
                            image: IconAsset.bTripUnelected,
                            ht: 24.h,
                            wt: 24.h,
                          ),
                          activeIcon: CustomImage(
                            image: IconAsset.bTrip,
                            ht: 24.h,
                            wt: 24.h,
                          ),
                          label: "Trip",
                        ),
                        BottomNavigationBarItem(
                          icon: CustomImage(
                            image: IconAsset.bWalletUnelected,
                            ht: 24.h,
                            wt: 24.h,
                          ),
                          activeIcon: CustomImage(
                            image: IconAsset.bWallet,
                            ht: 24.h,
                            wt: 24.h,
                          ),

                          label: "Wallet",
                        ),
                        BottomNavigationBarItem(
                          icon: CustomImage(
                            image: IconAsset.bProfileUnelected,
                            ht: 24.h,
                            wt: 24.h,
                          ),
                          activeIcon: CustomImage(
                            image: IconAsset.bProfile,
                            ht: 24.h,
                            wt: 24.h,
                          ),

                          label: "Profile",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
