import 'dart:convert';

import 'package:e_taxi/core/api/api.dart';
import 'package:e_taxi/core/api/responce_handler.dart';
import 'package:e_taxi/utils/api_constants.dart';
import 'package:e_taxi/utils/log_utils.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../model/register_model.dart';
import '../model/uer_login_model.dart';

class AuthService {
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

      return jsonDecode(res.body.trim());
    } catch (e, st) {
      LogUtils.printError("error :$e, $st");

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
      return UserLoginModel.fromJson(jsonDecode(res.body.trim()));
    } catch (e, st) {
      LogUtils.printError("error :$e, $st");

      rethrow;
    }
  }

  static Future<UserLoginModel> firebasePhone({
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
          "firebase_uid": fUid,
        },
      );

      await ResponseHandler.checkResponseError(res);
      return UserLoginModel.fromJson(jsonDecode(res.body.trim()));
    } catch (e, st) {
      LogUtils.printError("error :$e, $st");

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
          "firebase_uid": fUid,
        },
      );
      await ResponseHandler.checkResponseError(res);
      return UserLoginModel.fromJson(jsonDecode(res.body));
    } catch (e, st) {
      LogUtils.printError("error :$e, $st");

      rethrow;
    }
  }

  static Future<UserLoginModel> googleLogin({
    required String fUid,
    required String email,
    required String fcmToken,
    required String type,
    String name = "",
    String id = "",
    String profileImage = "",
  }) async {
    try {
      final res = await Api().post(
        ApiConstants.emailLogin,
        bodyData: {
          "email": email,
          "device_token": fcmToken,
          "auth_provider": type,
          "name": name,
          "id": id,
          "profile_image": profileImage,
          "firebase_uid": fUid,
        },
      );
      await ResponseHandler.checkResponseError(res);
      return UserLoginModel.fromJson(jsonDecode(res.body));
    } catch (e, st) {
      LogUtils.printError("error :$e, $st");
      rethrow;
    }
  }

  static Future<RegisterModel> registerUser({
    required String fullName,
    required String email,
    required String phone,
    required String gender,
    required String referral,
    required String fcmToken,
    required String password,
    required String countryCode,
  }) async {
    try {
      final res = await Api().post(
        ApiConstants.registerUser,
        bodyData: {
          "full_name": fullName,
          "email": email,
          "phone": phone,
          "gender": gender,
          "referral_code": referral,
          "device_token": fcmToken,
          "country_code": countryCode,
        },
      );

      await ResponseHandler.checkResponseError(res);
      return RegisterModel.fromJson(jsonDecode(res.body));
    } catch (e, st) {
      LogUtils.printError("error :$e, $st");
      rethrow;
    }
  }

  static Future emailCheck({required String email}) async {
    try {
      final response = await Api().post(
        ApiConstants.emailCheck,
        bodyData: {"email": email, "role_id": 3},
      );
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }
}
