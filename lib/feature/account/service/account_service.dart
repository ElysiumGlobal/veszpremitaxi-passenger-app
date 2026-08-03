import 'dart:convert';

import 'package:e_taxi/core/api/api.dart';
import 'package:e_taxi/core/api/responce_handler.dart';
import 'package:e_taxi/utils/api_constants.dart';
import 'package:e_taxi/utils/log_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../widgets/app_snackbar.dart';
import '../model/cash_collection_model.dart';
import '../model/location_list_model.dart';
import '../model/notification_model.dart';
import '../model/performer_model.dart';
import '../model/user_model.dart';

class AccountService {
  static Future<UserDataModel> getUserProfile() async {
    try {
      final response = await Api().get(ApiConstants.getUserProfile);
      await ResponseHandler.checkResponseError(response);

      return UserDataModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("PROFILE GET ERROR::$e , $st");
      rethrow;
    }
  }

  static Future updateProfile({
    required String name,
    required String email,
    required String dob,
    required String imagePath,
  }) async {
    List<String> imagePathList = [];
    if (imagePath.isNotEmpty) {
      imagePathList.add(imagePath);
    }
    try {
      final res = await Api().sendMultipartRequestPost1(
        ApiConstants.register,
        imageName: ['driver_profile_image'],
        profileImage: imagePathList,
        bodyData: {
          "step": '1',
          "name": name,
          "email": email,
          "date_of_birth": dob,
        },
      );
      if (res['success'] == false) {
        AppSnackBar.showErrorSnackBar(message: res['message'], isError: true);
        throw "ERROR::$res";
      }
      return res;
    } catch (e, st) {
      LogUtils.printError("PROFILE Update ERROR::$e , $st");

      return;
    }
  }

  static Future accountDelete() async {
    try {
      final response = await Api().post(ApiConstants.accountDelete);
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e, st) {
      LogUtils.printError("Delete  ERROR::$e , $st");
      rethrow;
    }
  }

  static Future accountLogout() async {
    try {
      final response = await Api().post(ApiConstants.accountLogout);
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e, st) {
      LogUtils.printError("Delete  ERROR::$e , $st");
      rethrow;
    }
  }

  static Future<NotificationModel> getNotificationList({int page = 1}) async {
    try {
      final response = await Api().get(
        "${ApiConstants.getNotificationList}$page",
      );

      await ResponseHandler.checkResponseError(response);

      return NotificationModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("Notification Data Error:::$e, $st");

      rethrow;
    }
  }

  static Future<PerformerDataModel> getPerformancedata() async {
    try {
      final response = await Api().get(ApiConstants.getPerformanceList);
      await ResponseHandler.checkResponseError(response);
      return PerformerDataModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("PErformance Error :$e, $st");
      rethrow;
    }
  }

  static Future addLocationData({
    required String title,
    required String address,
    required LatLng latLang,
    required String name,
  }) async {
    try {
      final response = await Api().post(
        ApiConstants.saveLocation,
        bodyData: {
          "name": name,
          "address": address,
          "latitude": latLang.latitude,
          "longitude": latLang.longitude,
          "type": title,
          "is_default": 1,
        },
      );
      await ResponseHandler.checkResponseError(response);

      return jsonDecode(response.body);
    } catch (e, st) {
      LogUtils.printError("ADD LOCATION ::$e, $st");
      rethrow;
    }
  }

  static Future<LocationDataModel> getLocationList() async {
    try {
      final response = await Api().get(ApiConstants.saveLocation);
      await ResponseHandler.checkResponseError(response);
      return LocationDataModel.fromJson(jsonDecode(response.body));
    } catch (em, st) {
      LogUtils.printError("GEt Location Error ;;$em, $st");
      rethrow;
    }
  }

  static Future<CashCollectedModel> getCashCollectionPoint() async {
    try {
      final response = await Api().get(ApiConstants.cashCollection);
      await ResponseHandler.checkResponseError(response);
      return CashCollectedModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("CASH COLLECT ERROR ::$e , $st");
      rethrow;
    }
  }

  static Future licenceUpdate({required String licence}) async {
    try {
      final response = await Api().post(
        ApiConstants.licenceUpdate,
        bodyData: {"registration_number": licence},
      );
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }
}
