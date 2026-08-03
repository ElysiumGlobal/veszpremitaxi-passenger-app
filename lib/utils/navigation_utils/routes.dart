import 'package:e_taxi/feature/account/pages/account_screen.dart';
import 'package:e_taxi/feature/account/pages/edit_profile.dart';
import 'package:e_taxi/feature/auth/pages/account_review.dart';
import 'package:e_taxi/feature/auth/pages/auth/otp_verify_screen.dart';
import 'package:e_taxi/feature/auth/pages/driver_login_screen.dart';
import 'package:e_taxi/feature/auth/pages/document_screen.dart';
import 'package:e_taxi/feature/auth/pages/location_setup/location_set_screen.dart';
import 'package:e_taxi/feature/auth/pages/location_setup/manual_location_screen.dart';
import 'package:e_taxi/feature/auth/pages/profile_setup_screen.dart';
import 'package:e_taxi/feature/auth/pages/uploading_screen.dart';
import 'package:e_taxi/feature/auth/pages/vehicle_setup_screen.dart';
import 'package:e_taxi/feature/home/pages/account_deactive_screen.dart';
import 'package:e_taxi/feature/home/pages/cash_collect.dart';
import 'package:e_taxi/feature/home/pages/chat_screen.dart';
import 'package:e_taxi/feature/home/pages/home_screen.dart';
import 'package:e_taxi/feature/home/pages/review_screen.dart';
import 'package:e_taxi/feature/onboarding/pages/onboarding_screen.dart';
import 'package:e_taxi/feature/trip_activity/pages/trip_activity_screen.dart';
import 'package:e_taxi/feature/wallet/page/earning_screen.dart';
import 'package:get/get.dart';

import '../../feature/account/pages/documentScreen.dart';
import '../../feature/account/pages/driver_preference.dart';
import '../../feature/account/pages/language_screen.dart';
import '../../feature/account/pages/notification_screen.dart';
import '../../feature/account/pages/preference_screen.dart';
import '../../feature/account/pages/refer_earn_screen.dart';
import '../../feature/account/pages/save_location_screen.dart';
import '../../feature/account/widget/search_address.dart';
import '../../feature/auth/pages/forgot_pasword.dart';
import '../../feature/help_center/pages/helpcenter_screen.dart';
import '../../feature/help_center/pages/raise_ticket.dart';
import '../../feature/home/pages/cancel_requestScreen.dart';
import '../../feature/home/pages/navigation_screen.dart';
import '../../feature/home/pages/otp_verify_screen.dart';
import '../../feature/home/pages/trip_confirmation_screen.dart';
import '../../feature/incentive/page/incentive_screen.dart';
import '../../feature/onboarding/binding.dart';
import '../../feature/splace/page/splace_screen.dart';
import '../../feature/trip_activity/pages/trip_activity_details.dart';
import '../../feature/trip_activity/pages/trip_support.dart';
import '../../feature/wallet/page/add_bank_account.dart';
import '../../feature/wallet/page/earning_transaction_details_screen.dart';
import '../../feature/wallet/page/earning_transaction_screen.dart';
import '../../feature/wallet/page/wallet_report.dart';
import '../../feature/wallet/page/wallet_transaction_details_screen.dart';
import '../../feature/wallet/page/wallet_transaction_screen.dart';

mixin Routes {
  static const defaultTransition = Transition.fadeIn;

  static const String splash = '/splash';
  static const String onboardingScreen = '/OnboardingScreen';
  static const String registerScreen = '/RegisteSrcreen';
  static const String otpVerifyScreen = '/OtpVerifyScreen';
  static const String locationSetScreen = '/LocationSetScreen';
  static const String manualLocationScreen = '/ManualLocationScreen';
  static const String profileSetUpScreen = '/ProfileSetUpScreen';
  static const String vehicleSetupScreen = '/VehicleSetupScreen';
  static const String accountReview = '/AccountReviewScreen';
  static const String documentScreen = '/DocumentScreen';
  static const String uploadScreen = '/UploadScreen';
  static const String tripActivityScreen = '/TripActivityScreen';
  static const String homeScreen = '/HomeScreen';
  static const String accountDeActiveScreen = '/AccountDeactiveScreen';
  static const String tripActivityDetailScreen = '/TripActivityDetails';
  static const String tripSupportScreen = '/TripSupportScreen';
  static const String earningScreen = '/EarningScreen';
  static const String accountScreen = '/AccountScreen';
  static const String cancelRequestScreen = '/CancelRequestscreen';
  static const String mapNavigationScreen = '/MapNavigationScreen';
  static const String customerOtpVerify = '/CustomerOtpVerify';
  static const String cashCollectScreen = '/CashCollectScreen';
  static const String reviewScreen = '/ReviewScreen';
  static const String tripConfirmationScreen = '/TripConfirmationScreen';
  static const String editProfileScreen = '/EditProfileScreen';
  static const String referEarnScreen = '/ReferEarnScreen';
  static const String languageScreen = '/LanguageScreen';
  static const String documentProfileScreen = '/DocumentProfileScreen';
  static const String bankAccountAddScreen = '/BankAccountAddScreen';
  static const String walletTransactionScreen = '/WalletTransactionScreen';
  static const String earningTransactionScreen = '/EarningTransactionScreen';
  static const String earningDetailsScreen = '/EarningDetailsScreen';
  static const String walletDetailsScreen = '/WalletDetailsScreen';
  static const String walletReportScreen = '/WalletReportScreen';
  static const String searchAddressScreen = '/SearchAddressScreen';
  static const String saveLocationScreen = '/SaveLocationScreen';
  static const String helpCenterScreen = '/HelpCenterScreen';
  static const String driverPreference = '/DriverPreference';
  static const String preferenceScreen = '/PreferenceScreen';
  static const String notificationScreen = '/NotificationScreen';
  static const String chatScreen = '/ChatScreen';
  static const String forgotPasswordScreen = '/ForgotPasswordScreen';
  static const String incentiveScreen = '/IncentiveScreen';
  static const String raiseTickerScreen = '/RaiseTickerScreen';

  static List<GetPage<dynamic>> pages = [
    GetPage<dynamic>(
      name: splash,
      page: () => const SplaceScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: onboardingScreen,
      page: () => const OnboardingScreen(),
      transition: defaultTransition,
      bindings: [OnboardingBinding()],
    ),
    GetPage<dynamic>(
      name: registerScreen,
      page: () => const DriverLoginScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: otpVerifyScreen,
      page: () => const OtpVerifyScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: locationSetScreen,
      page: () => const LocationSetScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: manualLocationScreen,
      page: () => const ManualLocationScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: profileSetUpScreen,
      page: () => const ProfileSetupScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: vehicleSetupScreen,
      page: () => const VehicleSetupScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: uploadScreen,
      page: () => const UploadingScreen(),
      transition: defaultTransition,
    ),

    GetPage<dynamic>(
      name: documentScreen,
      page: () => const DocumentScreen(),
      transition: defaultTransition,
    ),

    GetPage<dynamic>(
      name: accountReview,
      page: () => const AccountReviewScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: tripActivityScreen,
      page: () => const TripActivityScreen(),
      transition: defaultTransition,
    ),

    GetPage<dynamic>(
      name: homeScreen,
      page: () => const HomeScreen(),
      transition: defaultTransition,
    ),

    GetPage<dynamic>(
      name: accountDeActiveScreen,
      page: () => const AccountDeactiveScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: tripActivityDetailScreen,
      page: () => const TripActivityDetails(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: tripSupportScreen,
      page: () => const TripSupportScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: earningScreen,
      page: () => const EarningScreen(),
      transition: defaultTransition,
    ),

    GetPage<dynamic>(
      name: accountScreen,
      page: () => const AccountScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: cancelRequestScreen,
      page: () => const CancelRequestscreen(),
      transition: defaultTransition,
    ),

    GetPage<dynamic>(
      name: mapNavigationScreen,
      page: () => const MapNavigationScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: customerOtpVerify,
      page: () => const CustomerOtpVerify(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: cashCollectScreen,
      page: () => const CashCollectScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: reviewScreen,
      page: () => const ReviewScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: tripConfirmationScreen,
      page: () => const TripConfirmationScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: editProfileScreen,
      page: () => const EditProfileScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: referEarnScreen,
      page: () => const ReferEarnScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: languageScreen,
      page: () => const LanguageScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: documentProfileScreen,
      page: () => const DocumentProfileScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: bankAccountAddScreen,
      page: () => const BankAccountAddScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: walletTransactionScreen,
      page: () => const WalletTransactionScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: earningTransactionScreen,
      page: () => const EarningTransactionScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: earningDetailsScreen,
      page: () => const EarningDetailsScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: walletDetailsScreen,
      page: () => const WalletDetailsScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: walletReportScreen,
      page: () => WalletReportScreen(
        bookingId: Get.parameters['bookingId'] ?? "",
        tranactionId: Get.parameters['transactionId'] ?? "",
      ),
      transition: defaultTransition,
    ),

    GetPage<dynamic>(
      name: searchAddressScreen,
      page: () => const SearchAddressScreen(),
      transition: defaultTransition,
    ),

    GetPage<dynamic>(
      name: saveLocationScreen,
      page: () => const SaveLocationScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: helpCenterScreen,
      page: () => const HelpCenterScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: driverPreference,
      page: () => const DriverPreference(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: preferenceScreen,
      page: () => const PreferenceScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: notificationScreen,
      page: () => const NotificationScreen(),
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

    GetPage<dynamic>(
      name: incentiveScreen,
      page: () => IncentiveScreen(),
      transition: defaultTransition,
    ),

    GetPage<dynamic>(
      name: raiseTickerScreen,
      page: () => RaiseTickerScreen(
        title: Get.parameters['title'] ?? "",
        subject: Get.parameters['subject'] ?? "",
      ),
      transition: defaultTransition,
    ),
  ];
}
