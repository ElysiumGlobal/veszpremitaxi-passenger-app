class ApiConstants {
  static const String domain = "https://api.veszpremitaxi.hu";
  static const String baseUrl = "$domain/api";
  static const String otpSend = "/driver/send-otp";
  static const String verifyOtp = "/driver/login/otp";
  static const String emailLogin = "/driver/login/password";
  static const String register = "/driver/register";
  static const String requiredDocument = "/driver/required-documents";

  static const String onlineOffline = "/driver/attendance/attendance-status";


  static const String getUserProfile = "/driver/profile";

  static const String driverLocationUpdate = "/driver/location";

  static const String updateBookingRideStatus = "/driver/bookings/";
  static const String pendingRideOffer = "/driver/bookings/offers/pending";
  static const String driverDebugEvent = "/vtaxi-driver-flow-debug-29c7.php";
  static const String customerOtpVerify = "/driver/bookings/match-otp";
  static const String reviewDriver = "/driver/bookings/review-customer";
  static const String collectCash = "/driver/bookings/collect-cash";
  static const String driverPaymentAccept =
      "/payments/driver/cash-payment/update";


  static const String getTripDetails = "/driver/trip-activity/";
  static const String rideTypeList = "/ride-types";
  static const String tripSupportTicket = "/support/tickets";

  static const String reportIssue = "/issues/report";

  static const String withDrawMoney = "/payments/driver/withdrawal/process";
  static const String addMoneyWallet = "/payments/wallet/add";
  static const String addBankAccount = "/payments/driver/bank-account/add";
  static const String showBank = "/payments/driver/bank-account/info";
  static const String addUpiId = "/payments/driver/upi/add";

  static const String getWalletTransactionList =
      "/payments/driver/wallet/transactions";
  static const String getWalletTransactionDetails =
      "/payments/driver/transaction/details";



  static const String walletOverView = "/payments/driver/wallet/overview";
  static const String getEarningTransactionList =
      "/payments/driver/earnings/list";
  static const String earningReportIssue = "/cancellation-fee-disputes/submit";
  static const String earningDetails = "/payments/driver/earning/details";
  static const String earningCancelDetails =
      "/payments/driver/cancellation-fee/details";
  static const String earningRefundApprove = "/payments/driver/refund/details";


  static const String earningOverview = "/payments/driver/earnings/overview";


  static const String addEmergency = "/driver/emergency-contacts";
  static const String getEmergency = "/driver/emergency-contacts";
  static const String deleteEmergency = "/driver/emergency-contacts/";


  static const String contactSupport = "/driver/support/help-center";
  static const String getSupportDetails = "/driver/support/tickets/";


  static const String accountDelete = "/driver/delete-account";
  static const String accountLogout = "/driver/logout";


  static const String driverPaymentConfirm =
      "/payments/driver/cash-payment/update";

  static const String getNotificationList = "/notifications?page=";


  static const String getPerformanceList = "/driver/performance";


  static const String saveLocation = "/driver/saved-locations";


  static const String socketAuthentication = "/websocket-direct/authenticate";
  static const String driverAuthentication = "/driver-location-booking/auth";
  static const String getChatHistory = "/chat/list?booking_id=";
  static const String sendChatMessage = "/chat/send";
  static const String markChatRead = "/chat/mark-read";
  static const String deleteChatMessage = "/chat/message/";
  static const String cashCollection = "/cash-collection-points";


  static const String incentive = "/driver/incentives?daily=";
  static const String setting = "/settings";

  static const String licenceUpdate = "/driver/update-registration-number";
  static const String emailCheck = "/user/check-email";
}
