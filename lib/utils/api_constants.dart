class ApiConstants {
  static const String domain = "https://api.veszpremitaxi.hu";
  static const String baseUrl = "$domain/api/";
  static const String flowDebugEvent =
      "$domain/vtaxi-driver-flow-debug-29c7.php";

  static const String otpSend = "user/send-otp";
  static const String verifyOtp = "user/login/otp";
  static const String registerUser = "user/register";
  static const String emailLogin = "user/login/password";
  static const String firebaseSession = "user/firebase-session";
  static const String completePhone = "user/complete-phone";

  static const String userProfile = "user/profile";
  static const String addAddress = "locations/save";
  static const String getAddress = "locations/saved";
  static const String updateProfile = "user/update-profile";

  static const String rideTypeList = "ride-types";

  static const String bookingEstimate = "bookings/estimate";
  static const String bookingCreate = "bookings/create";
  static const String bookingPrefix = "bookings/";
  static const String vehicleBook = "bookings/select-ride-type";
  static const String cancelRide = "bookings/cancel";
  static const String paymentModeUpdate = "bookings/update-payment-method";

  static const String getTripList = "trips/trip-info?page=";
  static const String refundRequest = "refunds/request";

  static const String getOfferList = "offers/list?page=";
  static const String promoCodeApply = "offers/apply";
  static const String removePromoCode = "offers/remove";

  static const String banner = "banners";

  static const String addEmergency = "emergency-contacts/create";
  static const String getEmergency = "emergency-contacts";
  static const String deleteEmergency = "emergency-contacts/delete/";

  static const String driverRating = "bookings/review-driver";

  static const String onlinePaymentInt = "payments/init-transaction";
  static const String verifyPayment = "payments/verify-transaction";

  static const String getWalletData = "wallet/wallet-info-transactions";
  static const String stripeWalletTopupConfig =
      "payments/wallet/stripe/config";
  static const String stripeWalletTopup = "payments/wallet/stripe/topup";
  static const String stripeQrPayment = "payments/stripe/qr";

  static const String getNotificationList = "notifications?page=";

  static const String socketAuthentication = "websocket-direct/authenticate";
  static const String supportSocketAuthentication = "support-websocket/auth";
  static const String sendSupportChatMessage = "support-websocket/message";
  static const String getChatHistory = "chat/list?booking_id=";
  static const String sendChatMessage = "chat/send";
  static const String markChatRead = "chat/mark-read";
  static const String deleteChatMessage = "chat/message/";
  static const String supportChatHistory = "support/messages_list?booking_id=";

  static const String setting = "settings";
  static const String getAppLanguage = "get-app-language";
  static const String updateLanguagePreference = "language/preference";

  static const String deleteAccount = "user/delete-account";
  static const String logOutAccount = "user/logout-safe";

  static const String forMeGetList = "booking-contacts";
  static const String forMeAdd = "booking-contacts/create";
  static const String emailCheck = "user/check-email";
}
