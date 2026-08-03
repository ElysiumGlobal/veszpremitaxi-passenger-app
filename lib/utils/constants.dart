import 'package:e_taxi/utils/api_constants.dart';
import 'package:get/get.dart';

class Constants {

  Constants._();
  factory Constants() {
    return _internal;
  }
  static Constants _internal=Constants._();


  static const String fontFamily = "Typography";
  static String userLoginType = "";


  static String bookingId = "";
  static RxString transactionId = "".obs;
  static RxString paymentMode = "".obs;

  static String socketId = "";

  String aboutUs = "${ApiConstants.domain}/page/about-us";
  String termsCondition = "${ApiConstants.domain}/page/terms-conditions";
  String privacyPolicy = "${ApiConstants.domain}/page/privacy-policy";
  String contactUs = "${ApiConstants.domain}/page/contact-us";
  String appName = "Veszprémi Taxi Sofőr";
  String local = "hu_HU";
  String currency = "HUF";
  String androidLink="";
  String iosLink="";
  String appStoreId="";
}