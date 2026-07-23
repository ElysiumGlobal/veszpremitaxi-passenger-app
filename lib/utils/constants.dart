import 'package:e_taxi/utils/api_constants.dart';
import 'package:get/get.dart';

class Constants {
  static const String fontFamily = "Outfit";
}

class AppConstant {
  AppConstant._();

  static AppConstant internal = AppConstant._();

  factory AppConstant() => internal;

  String userLoginType = "";
  String bookingId = "";
  RxString reportString = "".obs;

  String socketId = "";

  String aboutUs = "${ApiConstants.domain}/page/about-us";
  String termsCondition = "${ApiConstants.domain}/page/terms-conditions";
  String privacyPolicy = "${ApiConstants.domain}/page/privacy-policy";
  String contactUs = "${ApiConstants.domain}/page/contact-us";
  String appName = "Veszprémi Taxi";
  String local = "hu_HU";
  String currency = "HUF";
  String androidLink = "";
  String iosLink = "";
  String appStoreId = "";
}
