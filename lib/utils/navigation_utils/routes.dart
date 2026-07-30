import 'package:e_taxi/feature/auth/page/location_screen.dart';
import 'package:e_taxi/feature/auth/page/login_screen.dart';
import 'package:e_taxi/feature/auth/page/otpverify_screen.dart';
import 'package:e_taxi/feature/auth/page/phone_required_screen.dart';
import 'package:e_taxi/feature/auth/page/register_screen.dart';
import 'package:e_taxi/feature/auth/page/term_service_screen.dart';
import 'package:e_taxi/feature/dashboard/page/dashboard_screen.dart';
import 'package:e_taxi/feature/home/page/bookvehicle_screen.dart';
import 'package:e_taxi/feature/home/page/cancel_request.dart';
import 'package:e_taxi/feature/home/page/driver_details.dart';
import 'package:e_taxi/feature/home/page/home_screen.dart';
import 'package:e_taxi/feature/home/page/offer_screen.dart';
import 'package:e_taxi/feature/home/page/pickup_point_screen.dart';
import 'package:e_taxi/feature/home/page/rate_driver_screen.dart';
import 'package:e_taxi/feature/home/page/repot_issue_screen.dart';
import 'package:e_taxi/feature/home/page/search_driver.dart';
import 'package:e_taxi/feature/home/page/search_screenfirst.dart';
import 'package:e_taxi/feature/home/page/search_screen_secound.dart';
import 'package:e_taxi/feature/home/page/trip_details.dart';
import 'package:e_taxi/feature/onboarding/page/onboarding_scrreen.dart';
import 'package:e_taxi/feature/profile/page/language_screen.dart';
import 'package:e_taxi/feature/profile/page/notification_screen.dart';
import 'package:e_taxi/feature/profile/page/profile_screen.dart';
import 'package:e_taxi/feature/profile/page/refer_earn_screen.dart';
import 'package:e_taxi/feature/profile/page/safety_screen.dart';
import 'package:e_taxi/feature/trip/page/ride_details_screen.dart';
import 'package:e_taxi/feature/trip/page/trip_screen.dart';
import 'package:e_taxi/feature/wallet/page/wallet_screen.dart';
import 'package:get/get.dart';

import '../../feature/auth/page/forgot_pasword.dart';
import '../../feature/home/page/payment_selection_screen.dart';
import '../../feature/home/widget/chat_screen.dart';
import '../../feature/profile/page/edit_profile.dart';
import '../../feature/splace/page/splace_screen.dart';
import '../../feature/trip/page/chat_support.dart';

mixin Routes {
  static const defaultTransition = Transition.fadeIn;

  static const String splash = '/splash';
  static const String onboarding = '/OnboardingScrreen';
  static const String loginScreen = '/LoginScreen';
  static const String otpVerifyScreen = '/OtpverifyScreen';
  static const String phoneRequiredScreen = '/PhoneRequiredScreen';
  static const String locationScreen = '/LocationScreen';
  static const String registerScreen = '/RegisterScreen';
  static const String termServiceScreen = '/TermServiceScreen';
  static const String dashboardScreen = '/DashboardScreen';
  static const String homeScreen = '/HomeScreen';
  static const String walletScreen = '/WalletScreen';
  static const String tripScreen = '/TripScreen';
  static const String profileScreen = '/profileScreen';
  static const String searchSecoundScreen = '/SearchSecoundScreen';
  static const String searchFirstScreen = '/SearchFirstScreen';
  static const String bookVehicleScreen = '/BookVehicleScreen';
  static const String paymentSelectScreen = '/PaymentSelectScreen';
  static const String pickupScreen = '/PickupPointScreen';
  static const String offerScreen = '/OfferScreen';
  static const String searchDriverScreen = '/SearchDriverScreen';
  static const String driverDetailsScreen = '/DriverDetailsScreen';
  static const String tripDetailsScreen = '/TripDetailsScreen';
  static const String cancelRequestScreen = '/CancelRequestScreen';
  static const String rateDriverScreen = '/RateDriverScreen';
  static const String reportIssueScreen = '/ReportIssueScreen';
  static const String rideDetailsScreen = '/RideDetailsScreen';
  static const String chatSupportScreen = '/ChatSupportScreen';
  static const String safetyScreen = '/SafetyScreen';
  static const String languageScreen = '/LanguageScreen';
  static const String notificationScreen = '/NotificationScreen';
  static const String referScreen = '/ReferScreen';
  static const String termScreen = '/TermScreen';
  static const String editProfileScreen = '/EditProfileScreen';
  static const String chatScreen = '/ChatScreen';
  static const String forgotPasswordScreen = '/ForgotPasswordScreen';

  static List<GetPage<dynamic>> pages = [
    GetPage<dynamic>(
      name: splash,
      page: () => const SplaceScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: onboarding,
      page: () => OnboardingScreens(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: loginScreen,
      page: () => LoginScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage<dynamic>(
      name: otpVerifyScreen,
      page: () => OtpverifyScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage<dynamic>(
      name: phoneRequiredScreen,
      page: () => const PhoneRequiredScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage<dynamic>(
      name: locationScreen,
      page: () => LocationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage<dynamic>(
      name: registerScreen,
      page: () => RegisterScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage<dynamic>(
      name: termServiceScreen,
      page: () => TermServiceScreen(),
      transition: Transition.rightToLeft,
    ),

    GetPage<dynamic>(
      name: dashboardScreen,
      page: () => DashboardScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: homeScreen,
      page: () => HomeScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: walletScreen,
      page: () => WalletScreen(),
      transition: defaultTransition,
    ),

    GetPage<dynamic>(
      name: tripScreen,
      page: () => TripScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: profileScreen,
      page: () => ProfileScreen(),
      transition: defaultTransition,
    ),

    GetPage<dynamic>(
      name: searchFirstScreen,
      page: () => SearchFirstScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: searchSecoundScreen,
      page: () => SearchSecoundScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: bookVehicleScreen,
      page: () => BookVehicleScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: paymentSelectScreen,
      page: () => PaymentSelectScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: pickupScreen,
      page: () => PickupPointScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: offerScreen,
      page: () => OfferScreen(
        offerCode: Get.parameters['offerCode'] ?? "",
        vehicleId: Get.parameters['vehicleId'] ?? "",
      ),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: searchDriverScreen,
      page: () => SearchDriverScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: driverDetailsScreen,
      page: () => DriverDetailsScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: tripDetailsScreen,
      page: () => TripDetailsScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: cancelRequestScreen,
      page: () => CancelRequestScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: rateDriverScreen,
      page: () => RateDriverScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: reportIssueScreen,
      page: () => ReportIssueScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: rideDetailsScreen,
      page: () => RideDetailsScreen(index: Get.parameters['index'] ?? "0"),
      transition: defaultTransition,
    ),

    GetPage<dynamic>(
      name: chatSupportScreen,
      page: () => ChatSupportScreen(
        bookingId: Get.parameters['bookingId'] ?? "",
        title: Get.parameters['title'] ?? "",
      ),
      transition: defaultTransition,
    ),

    GetPage<dynamic>(
      name: safetyScreen,
      page: () => SafetyScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: languageScreen,
      page: () => LanguageScreen(),
      transition: defaultTransition,
    ),

    GetPage<dynamic>(
      name: referScreen,
      page: () => ReferEarnScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: termScreen,
      page: () => TermServiceScreen(),
      transition: defaultTransition,
    ),

    GetPage<dynamic>(
      name: notificationScreen,
      page: () => NotificationScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: editProfileScreen,
      page: () => EditProfileScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: chatScreen,
      page: () => ChatScreen(bookingId: Get.parameters['bookingId'] ?? ""),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: forgotPasswordScreen,
      page: () => ForgotPasswordScreen(),
      transition: defaultTransition,
    ),
  ];
}
