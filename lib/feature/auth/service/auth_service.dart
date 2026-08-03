import 'dart:convert';
import 'dart:developer';

import 'package:e_taxi/core/api/api.dart';
import 'package:e_taxi/core/api/responce_handler.dart';
import 'package:e_taxi/core/service/firebase_notification_new.dart';
import 'package:e_taxi/utils/api_constants.dart';
import 'package:e_taxi/utils/log_utils.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../model/req_doc_model.dart';
import '../model/ride_type_list_model.dart';
import '../model/user_login_model.dart';

class AuthService {

  static Future<UserLoginModel> driverPasswordLogin({
    required String identifier,
    required String password,
  }) async {
    try {
      final String deviceToken =
          await FireBaseNotification().getTokenSafely();
      final res = await Api().post(
        ApiConstants.emailLogin,
        bodyData: {
          "email": identifier,
          "username": identifier,
          "identifier": identifier,
          "password": password,
          "device_token": deviceToken,
          "auth_provider": "password",
          "firebase_uid": "",
          "client_id": "veszprem_driver_app",
        },
      );

      await ResponseHandler.checkResponseError(res, showException: false);
      return UserLoginModel.fromJson(jsonDecode(res.body));
    } catch (e, st) {
      LogUtils.printError("driver password login error: $e, $st");
      rethrow;
    }
  }
  static Future sendOtp(String phoneNumber, String countryCode) async {
    try {
      final codeSignature = await SmsAutoFill().getAppSignature;

      final res = await Api().post(
        ApiConstants.otpSend,
        bodyData: {
          "phone": phoneNumber,
          "country_code": countryCode,
          "signature": codeSignature,
        },
      );

      await ResponseHandler.checkResponseError(res);

      return jsonDecode(res.body);
    } catch (e, st) {
      LogUtils.printError("error socket :$e, $st");
      rethrow;
    }
  }

  static Future<UserLoginModel> verifyOtp({
    required String otp,
    required String phone,
    required String fcm,
    required String countryCode,
  }) async {
    try {
      final res = await Api().post(
        ApiConstants.verifyOtp,
        bodyData: {
          "phone": phone,
          "otp": otp,
          "device_token": fcm,
          "country_code": countryCode,
        },
      );

      await ResponseHandler.checkResponseError(res);
      return UserLoginModel.fromJson(jsonDecode(res.body));
    } catch (e, st) {
      LogUtils.printError("error verifyOTp:$e, $st");

      rethrow;
    }
  }

  static Future<UserLoginModel> FirebaseVerifyOtp({
    required String phone,
    required String fcm,
    required String countryCode,
    required String fUid,
  }) async {
    try {
      final res = await Api().post(
        ApiConstants.verifyOtp,
        bodyData: {
          "phone": phone,
          "device_token": fcm,
          "country_code": countryCode,
          fUid: fUid,
        },
      );

      await ResponseHandler.checkResponseError(res);
      return UserLoginModel.fromJson(jsonDecode(res.body));
    } catch (e, st) {
      LogUtils.printError("error verifyOTp:$e, $st");

      rethrow;
    }
  }

  static Future<UserLoginModel> emailLogin({
    required String email,
    required String pass,
    required String fcmToken,
    required String loginType,
    required String fUid,
  }) async {
    try {
      final res = await Api().post(
        ApiConstants.emailLogin,
        bodyData: {
          "email": email,
          "password": pass,
          "device_token": fcmToken,
          "auth_provider": loginType,
          fUid: fUid,
        },
      );
      await ResponseHandler.checkResponseError(res);
      log(">>>>>AFSD>>>>>>${res.body}");
      return UserLoginModel.fromJson(jsonDecode(res.body));
    } catch (e, st) {
      LogUtils.printError("error emailLogin:$e, $st");

      rethrow;
    }
  }

  static Future emailCheck({required String email}) async {
    try {
      final response = await Api().post(
        ApiConstants.emailCheck,
        bodyData: {"email": email, "role_id": 2},
      );
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  static Future<UserLoginModel> googleLogin({
    required String email,
    required String fcmToken,
    required String type,
    String id = "",
    String name = "",
    String profileImage = "",
    required String fUid,
  }) async {
    try {
      final res = await Api().post(
        ApiConstants.emailLogin,
        bodyData: {
          "email": email,
          "device_token": fcmToken,
          "auth_provider": type,
          "id": id,
          "name": name,
          "profile_image": profileImage,
          fUid: fUid,
        },
      );
      await ResponseHandler.checkResponseError(res);
      return UserLoginModel.fromJson(jsonDecode(res.body));
    } catch (e, st) {
      log(">>>>>>>$e, $st");
      LogUtils.printError("error googleLogin:$e, $st");
      rethrow;
    }
  }

  static Future registerZero({
    required double lat,
    required double long,
  }) async {
    try {
      final res = await Api().post(
        ApiConstants.register,
        bodyData: {"step": 0, "latitude": lat, "longitude": long},
      );
      await ResponseHandler.checkResponseError(res);
      return jsonDecode(res.body);
    } catch (e, st) {
      LogUtils.printError("error registerZero:$e, $st");
      rethrow;
    }
  }

  static Future registerFirst({
    required String name,
    required String phone,
    required String dob,
    String email = "",
    String referCode = "",
    String imagePath = "",
    required String countryCode,
  }) async {
    try {
      Map<String, String> body = {
        "referral_code": referCode,
        "step": '1',
        "name": name,
        "phone": phone,
        "email": email,
        "date_of_birth": dob,
        "country_code": countryCode,
      };
      final res = await Api().sendMultipartRequestPost(
        ApiConstants.register,
        imageName: "driver_profile_image",
        profileImage: imagePath,
        bodyData: body,
      );

      if (res['success'] == false) {
        AppSnackBar.showErrorSnackBar(message: res['message'], isError: true);
        throw "ERROR::$res";
      }
      return res;
    } catch (e, st) {
      LogUtils.printError("error registerFirst:$e, $st");
      rethrow;
    }
  }

  static Future registerSecound({
    required int rideType,
    required String noPlate,
  }) async {
    try {
      final res = await Api().post(
        ApiConstants.register,
        bodyData: {
          "step": 2,
          "ride_type_id": rideType,
          "registration_number": noPlate,
        },
      );

      await ResponseHandler.checkResponseError(res);
      return jsonDecode(res.body);
    } catch (e, st) {
      LogUtils.printError("error registerSecound:$e, $st");
      rethrow;
    }
  }

  static Future registerGovIdUpload({required List<String> imageList}) async {
    try {
      final res = await Api().sendMultipartRequestPost1(
        ApiConstants.register,
        imageName: ["government_id_front", "government_id_back"],
        profileImage: imageList,
        bodyData: {"step": "3"},
      );

      if (res['success'] == false) {
        AppSnackBar.showErrorSnackBar(message: res['message'], isError: true);
        throw "ERROR::$res";
      }
      return res;
    } catch (e, st) {
      LogUtils.printError("error registerGovIdUpload:$e, $st");
      rethrow;
    }
  }

  static Future registerThird({
    required List<String> imageList,
    required String make,
    required String model,
    required String year,
    required List<String> imageFileName,
  }) async {
    try {
      print(">>>>${imageList}");
      Map<String, String> body = {"step": "3"};
      if (make.isNotEmpty) {
        body['make'] = make;
      }
      if (model.isNotEmpty) {
        body['model'] = model;
      }
      if (year.isNotEmpty) {
        body['year'] = year;
      }

      final res = await Api().sendMultipartRequestPost1(
        ApiConstants.register,
        imageName: imageFileName,
        bodyData: body,
        profileImage: imageList,
      );

      if (res['success'] == false) {
        AppSnackBar.showErrorSnackBar(message: res['message'], isError: true);
        throw "ERROR::$res";
      }
      return res;
    } catch (e, st) {
      LogUtils.printError("error registerThird:$e, $st");
      rethrow;
    }
  }

  static Future<RideTypeListModel> getRideTypeList() async {
    try {
      final response = await Api().get(ApiConstants.rideTypeList);
      await ResponseHandler.checkResponseError(response);
      return RideTypeListModel.fromJson(jsonDecode(response.body));
    } catch (e) {
      rethrow;
    }
  }

  static Future<RequiredDocModel> getRequiredDoc() async {
    try {
      final response = await Api().get(ApiConstants.requiredDocument);
      await ResponseHandler.checkResponseError(response);
      return RequiredDocModel.fromJson(jsonDecode(response.body));
    } catch (e) {
      rethrow;
    }
  }
}
